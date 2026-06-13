class ApiResponse<T> {
  final int codigo;
  final String mensaje;
  final T? data;

  ApiResponse({required this.codigo, required this.mensaje, this.data});

  bool get isOk => codigo == 200;
}
