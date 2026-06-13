import 'dart:convert';
import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/api_service.dart';

class AuthProvider extends ChangeNotifier {
  final ApiService _api = ApiService();
  UserModel? _user;
  bool _loading = true;
  String? _error;

  UserModel? get user => _user;
  bool get loading => _loading;
  bool get isLoggedIn => _user != null;
  String? get error => _error;
  bool get isStudent => _user?.esEstudiante ?? false;
  bool get isTutor => _user?.esTutor ?? false;

  Future<void> tryAutoLogin() async {
    _loading = true;
    notifyListeners();
    final token = await _api.getToken();
    if (token != null) {
      final userData = await _api.getUser();
      if (userData != null) {
        _user = UserModel.fromJson(userData, token: token);
      }
    }
    _loading = false;
    notifyListeners();
  }

  Future<bool> login(String correo, String contrasena) async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      final data = await _api.login(correo, contrasena);
      if (data['codigo'] == 200) {
        final loginData = data['data'];
        final token = loginData['token'];
        final userMap = {
          'id': loginData['sub'] ?? loginData['id'] ?? '',
          'correo': loginData['correo'] ?? correo,
          'nombres': loginData['nombres'] ?? '',
          'apellidos': loginData['apellidos'] ?? '',
          'roles': List<String>.from(loginData['roles'] ?? []),
          'idInstitucion': loginData['id_institucion'],
          'idEstudiante': loginData['id_estudiante'],
          'idTutor': loginData['id_tutor'],
        };
        await _api.saveUser(userMap);
        _user = UserModel.fromJson(userMap, token: token);
        _loading = false;
        notifyListeners();
        return true;
      } else {
        _error = data['mensaje'] ?? 'Error al iniciar sesion';
        _loading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'Error de conexion: $e';
      _loading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    await _api.logout();
    _user = null;
    notifyListeners();
  }
}
