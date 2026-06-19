class ApiException implements Exception {
  final int? statusCode;
  final String message;
  final dynamic data;

  ApiException({this.statusCode, required this.message, this.data});

  @override
  String toString() => 'ApiException($statusCode): $message';
}

class AuthException extends ApiException {
  AuthException([String message = 'No autenticado'])
      : super(statusCode: 401, message: message);
}

class NetworkException extends ApiException {
  NetworkException([String message = 'Error de conexion'])
      : super(message: message);
}

class ServerException extends ApiException {
  ServerException([String message = 'Error del servidor'])
      : super(statusCode: 500, message: message);
}

class ValidationException extends ApiException {
  final Map<String, dynamic>? errors;
  ValidationException([String message = 'Error de validacion', this.errors])
      : super(statusCode: 422, message: message);
}
