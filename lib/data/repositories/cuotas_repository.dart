import '../../core/http/api_client.dart';
import '../models/cuota_model.dart';

class CuotasRepository {
  final ApiClient _api;
  CuotasRepository(this._api);

  Future<List<Cuota>> getCuotas({String? idGestion}) async {
    var path = '/cuotas/mis-cuotas';
    if (idGestion != null) path += '?idGestion=$idGestion';
    final resp = await _api.get(path);
    final data = resp['data'] as List<dynamic>? ?? [];
    return data.map((e) => Cuota.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<PagoModel> pagar(String idCuota, double monto) async {
    final resp = await _api.post('/cuotas/pagar', body: {
      'idCuota': idCuota,
      'monto': monto,
    });
    return PagoModel.fromJson(resp['data']);
  }

  Future<List<PagoModel>> getPagos() async {
    final resp = await _api.get('/cuotas/mis-pagos');
    final data = resp['data'] as List<dynamic>? ?? [];
    return data.map((e) => PagoModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<Map<String, dynamic>> generarQr(String idCuota) async {
    final resp = await _api.post('/cuotas/$idCuota/generar-qr');
    return resp['data'] as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> consultarEstado(String idPago) async {
    final resp = await _api.get('/cuotas/pago/$idPago/estado');
    return resp['data'] as Map<String, dynamic>;
  }
}
