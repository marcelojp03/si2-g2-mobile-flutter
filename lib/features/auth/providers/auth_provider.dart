import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/fcm/fcm_service.dart';
import '../../../core/http/api_client.dart';
import '../../../core/storage/storage_service.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../data/models/user_model.dart';

class AuthState {
  final UserModel? user;
  final bool loading;
  final String? error;

  AuthState({this.user, this.loading = false, this.error});
  bool get isLoggedIn => user != null;
}

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository _repo;
  final StorageService _storage;
  AuthNotifier(this._repo, this._storage) : super(AuthState(loading: false));

  Future<void> tryAutoLogin() async {
    final token = await _storage.getToken();
    if (token == null) return;
    final userData = await _storage.getUserData();
    if (userData != null) {
      final user = UserModel.fromJson(jsonDecode(userData) as Map<String, dynamic>);
      state = AuthState(user: user);
    }
  }

  Future<bool> login(String correo, String contrasena) async {
    state = AuthState(loading: true);
    try {
      final data = await _repo.login(correo, contrasena);
      if (data['codigo'] == 200) {
        final d = data['data'] as Map<String, dynamic>;
        await _storage.saveToken(d['token'] as String);
        await _storage.saveUserData(jsonEncode(d));
        state = AuthState(user: UserModel.fromJson(d));
        FcmService().registerCurrentToken();
        return true;
      }
      state = AuthState(error: data['mensaje'] ?? 'Error al iniciar');
      return false;
    } catch (e) {
      final msg = e is Exception ? e.toString().replaceFirst('Exception: ', '') : 'Error de conexion';
      state = AuthState(error: msg);
      return false;
    }
  }

  Future<void> logout() async {
    await _storage.clearAll();
    state = AuthState();
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(AuthRepository(ApiClient()), StorageService());
});
