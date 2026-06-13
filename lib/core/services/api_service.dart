import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';

class ApiService {
  static const _storage = FlutterSecureStorage();
  static const _tokenKey = 'jwt_token';
  static const _userKey = 'user_data';

  Future<Map<String, dynamic>> login(String correo, String contrasena) async {
    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}${ApiConfig.login}'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'correo': correo, 'contrasena': contrasena}),
    );
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    if (response.statusCode == 200 && data['codigo'] == 200) {
      final token = data['data']['token'] as String;
      await _storage.write(key: _tokenKey, value: token);
    }
    return data;
  }

  Future<void> saveUser(Map<String, dynamic> userData) async {
    await _storage.write(key: _userKey, value: jsonEncode(userData));
  }

  Future<Map<String, dynamic>?> getUser() async {
    final data = await _storage.read(key: _userKey);
    if (data == null) return null;
    return jsonDecode(data) as Map<String, dynamic>;
  }

  Future<void> logout() async {
    await _storage.delete(key: _tokenKey);
    await _storage.delete(key: _userKey);
  }

  Future<String?> getToken() => _storage.read(key: _tokenKey);

  Future<bool> registrarFcmToken(String fcmToken) async {
    final jwt = await getToken();
    if (jwt == null) return false;
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/api/notificaciones/fcm-token'),
        headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $jwt'},
        body: jsonEncode({'fcmToken': fcmToken, 'plataforma': 'android'}),
      );
      return response.statusCode == 200;
    } catch (e) {
      debugPrint('[ApiService] Error registrando FCM: $e');
      return false;
    }
  }

  Future<http.Response> get(String path) async {
    final jwt = await getToken();
    return http.get(Uri.parse('${ApiConfig.baseUrl}$path'), headers: _headers(jwt));
  }

  Future<http.Response> post(String path, Map<String, dynamic> body) async {
    final jwt = await getToken();
    return http.post(Uri.parse('${ApiConfig.baseUrl}$path'), headers: _headers(jwt), body: jsonEncode(body));
  }

  Future<http.Response> put(String path, Map<String, dynamic> body) async {
    final jwt = await getToken();
    return http.put(Uri.parse('${ApiConfig.baseUrl}$path'), headers: _headers(jwt), body: jsonEncode(body));
  }

  Map<String, String> _headers(String? jwt) => {
    'Content-Type': 'application/json',
    if (jwt != null) 'Authorization': 'Bearer $jwt',
  };
}
