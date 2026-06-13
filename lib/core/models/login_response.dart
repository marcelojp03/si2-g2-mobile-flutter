class LoginResponse {
  final int codigo;
  final String mensaje;
  final LoginData? data;

  LoginResponse({required this.codigo, required this.mensaje, this.data});

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      codigo: json['codigo'] ?? 0,
      mensaje: json['mensaje'] ?? '',
      data: json['data'] != null ? LoginData.fromJson(json['data']) : null,
    );
  }
}

class LoginData {
  final String token;
  final String correo;
  final List<String> roles;

  LoginData({required this.token, required this.correo, required this.roles});

  factory LoginData.fromJson(Map<String, dynamic> json) {
    return LoginData(
      token: json['token'] ?? '',
      correo: json['correo'] ?? '',
      roles: List<String>.from(json['roles'] ?? []),
    );
  }
}
