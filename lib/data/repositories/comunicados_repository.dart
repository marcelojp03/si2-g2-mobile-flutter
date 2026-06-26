import '../../core/http/api_client.dart';

class ComunicadosRepository {
  final ApiClient _api;

  ComunicadosRepository(this._api);

  Future<List<Map<String, dynamic>>> getPublicados() async {
    final resp = await _api.get('/comunicados/publicados');
    final list = resp['data'];
    if (list is! List) return [];
    return list.cast<Map<String, dynamic>>();
  }
}
