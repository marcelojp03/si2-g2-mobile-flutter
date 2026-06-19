class Notificacion {
  final String id;
  final String titulo;
  final String mensaje;
  final String tipo;
  final bool leida;
  final String creadoEn;
  final String? referenciaTipo;
  final String? referenciaId;

  Notificacion({
    required this.id,
    required this.titulo,
    required this.mensaje,
    required this.tipo,
    required this.leida,
    required this.creadoEn,
    this.referenciaTipo,
    this.referenciaId,
  });

  factory Notificacion.fromJson(Map<String, dynamic> json) {
    return Notificacion(
      id: json['id'] ?? '',
      titulo: json['titulo'] ?? '',
      mensaje: json['mensaje'] ?? '',
      tipo: json['tipo'] ?? '',
      leida: json['leida'] ?? false,
      creadoEn: json['creadoEn'] ?? '',
      referenciaTipo: json['referenciaTipo'],
      referenciaId: json['referenciaId'],
    );
  }
}
