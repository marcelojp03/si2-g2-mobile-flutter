class ApiResponse<T> {
  final int codigo;
  final String mensaje;
  final T? data;

  ApiResponse({required this.codigo, required this.mensaje, this.data});

  factory ApiResponse.fromJson(Map<String, dynamic> json, [T Function(dynamic)? fromData]) {
    return ApiResponse(
      codigo: json['codigo'] ?? 0,
      mensaje: json['mensaje'] ?? '',
      data: json['data'] != null && fromData != null ? fromData(json['data']) : json['data'] as T?,
    );
  }
}
