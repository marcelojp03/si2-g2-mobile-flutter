class Cuota {
  final String id;
  final int numeroCuota;
  final double monto;
  final String? fechaVencimiento;
  final String estado;
  final String nombrePlan;
  final PagoModel? ultimoPago;

  Cuota({
    required this.id,
    required this.numeroCuota,
    required this.monto,
    this.fechaVencimiento,
    required this.estado,
    required this.nombrePlan,
    this.ultimoPago,
  });

  bool get pagada => estado == 'PAGADA';
  bool get vencida {
    if (pagada || fechaVencimiento == null) return false;
    try {
      return DateTime.parse(fechaVencimiento!).isBefore(DateTime.now());
    } catch (_) {
      return false;
    }
  }

  factory Cuota.fromJson(Map<String, dynamic> json) {
    return Cuota(
      id: json['id']?.toString() ?? '',
      numeroCuota: json['numeroCuota'] ?? 0,
      monto: (json['monto'] ?? 0).toDouble(),
      fechaVencimiento: json['fechaVencimiento'],
      estado: json['estado'] ?? '',
      nombrePlan: json['nombrePlan'] ?? '',
      ultimoPago: json['ultimoPago'] != null
          ? PagoModel.fromJson(json['ultimoPago'])
          : null,
    );
  }
}

class PagoModel {
  final String id;
  final String idCuota;
  final double monto;
  final String moneda;
  final String metodoPago;
  final String? proveedor;
  final String? referenciaExterna;
  final String? qrBase64;
  final String estado;
  final String? pagadoEn;

  PagoModel({
    required this.id,
    required this.idCuota,
    required this.monto,
    this.moneda = 'BOB',
    this.metodoPago = 'QR',
    this.proveedor,
    this.referenciaExterna,
    this.qrBase64,
    this.estado = 'PENDIENTE',
    this.pagadoEn,
  });

  factory PagoModel.fromJson(Map<String, dynamic> json) {
    return PagoModel(
      id: json['id']?.toString() ?? '',
      idCuota: json['idCuota']?.toString() ?? '',
      monto: (json['monto'] ?? 0).toDouble(),
      moneda: json['moneda'] ?? 'BOB',
      metodoPago: json['metodoPago'] ?? 'QR',
      proveedor: json['proveedor'],
      referenciaExterna: json['referenciaExterna'],
      qrBase64: json['qrBase64'],
      estado: json['estado'] ?? 'PENDIENTE',
      pagadoEn: json['pagadoEn'],
    );
  }
}
