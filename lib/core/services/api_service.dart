// lib/core/services/api_service.dart
//
// Servicio HTTP base para comunicación con el backend Spring Boot.
// Maneja JWT Bearer token, multi-tenant y registro de FCM token.

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class ApiService {
  // Cambia a la URL del App Runner en producción
  static const String _baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.0.2.2:2026', // 10.0.2.2 = localhost desde emulador Android
  );

  static const _storage = FlutterSecureStorage();
  static const _tokenKey = 'jwt_token';

  // ── Auth ────────────────────────────────────────────────────────────────────

  Future<Map<String, dynamic>> login(String correo, String contrasena) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/api/auth/login'),
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

  Future<void> logout() => _storage.delete(key: _tokenKey);

  Future<String?> getToken() => _storage.read(key: _tokenKey);

  // ── FCM Token ───────────────────────────────────────────────────────────────

  /// Registra o actualiza el FCM token del dispositivo en el backend.
  Future<bool> registrarFcmToken(String fcmToken) async {
    final jwt = await getToken();
    if (jwt == null) return false;

    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/api/notificaciones/fcm-token'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $jwt',
        },
        body: jsonEncode({
          'fcmToken': fcmToken,
          'plataforma': defaultTargetPlatform.name.toLowerCase(),
        }),
      );
      return response.statusCode == 200;
    } catch (e) {
      debugPrint('[ApiService] Error registrando FCM token: $e');
      return false;
    }
  }

  // ── HTTP Helper ─────────────────────────────────────────────────────────────

  Future<http.Response> get(String path) async {
    final jwt = await getToken();
    return http.get(
      Uri.parse('$_baseUrl$path'),
      headers: _headers(jwt),
    );
  }

  Future<http.Response> post(String path, Map<String, dynamic> body) async {
    final jwt = await getToken();
    return http.post(
      Uri.parse('$_baseUrl$path'),
      headers: _headers(jwt),
      body: jsonEncode(body),
    );
  }

  Map<String, String> _headers(String? jwt) => {
        'Content-Type': 'application/json',
        if (jwt != null) 'Authorization': 'Bearer $jwt',
      };
}
