class ComunicadoModel {
  final String id;
  final String titulo;
  final String contenido;
  final String tipo;
  final String destinatarios;
  final String estado;
  final String? publicadoEn;
  final String creadoEn;

  ComunicadoModel({
    required this.id,
    required this.titulo,
    required this.contenido,
    required this.tipo,
    required this.destinatarios,
    required this.estado,
    this.publicadoEn,
    required this.creadoEn,
  });

  factory ComunicadoModel.fromJson(Map<String, dynamic> json) {
    return ComunicadoModel(
      id: json['id'] ?? '',
      titulo: json['titulo'] ?? '',
      contenido: json['contenido'] ?? '',
      tipo: json['tipo'] ?? '',
      destinatarios: json['destinatarios'] ?? '',
      estado: json['estado'] ?? '',
      publicadoEn: json['publicadoEn'],
      creadoEn: json['creadoEn'] ?? '',
    );
  }
}
