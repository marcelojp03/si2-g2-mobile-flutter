import '../../core/http/api_client.dart';

class AuthRepository {
  final ApiClient _api;

  AuthRepository(this._api);

  Future<Map<String, dynamic>> login(String correo, String contrasena) async {
    return await _api.post('/auth/login', body: {
      'correo': correo,
      'contrasena': contrasena,
    });
  }
}
