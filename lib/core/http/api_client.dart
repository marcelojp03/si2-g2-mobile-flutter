import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../storage/storage_service.dart';
import '../errors/app_exception.dart';

class ApiClient {
  static final ApiClient _instance = ApiClient._();
  factory ApiClient() => _instance;
  ApiClient._();

  static String get baseUrl => dotenv.get('API_BASE_URL', fallback: 'http://10.0.2.2:2026/api');

  late final Dio dio;
  final _storage = StorageService();

  void init() {
    dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {'Content-Type': 'application/json'},
    ));

    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await _storage.getToken();
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options);
      },
      onError: (error, handler) async {
        if (error.response?.statusCode == 401) {
          await _storage.clearAll();
          // El authProvider detectará que no hay token y redirigirá al login
        }
        handler.next(error);
      },
    ));
  }

  Future<Map<String, dynamic>> get(String path) async {
    try {
      final resp = await dio.get(path);
      return resp.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> post(String path, {Map<String, dynamic>? body}) async {
    try {
      final resp = await dio.post(path, data: body);
      return resp.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  ApiException _handleError(DioException e) {
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      return NetworkException('Tiempo de espera agotado');
    }
    if (e.type == DioExceptionType.connectionError) {
      return NetworkException('Sin conexion a internet');
    }
    final statusCode = e.response?.statusCode;
    final data = e.response?.data as Map<String, dynamic>?;
    if (statusCode == 401) {
      return AuthException(data?['mensaje'] ?? 'Token invalido o expirado');
    }
    if (statusCode == 422) {
      return ValidationException(data?['mensaje'] ?? 'Error de validacion', data?['errors']);
    }
    if (statusCode != null && statusCode >= 500) {
      return ServerException(data?['mensaje'] ?? 'Error interno del servidor');
    }
    return ApiException(
      statusCode: statusCode,
      message: data?['mensaje'] ?? 'Error desconocido: ${e.message}',
    );
  }
}
