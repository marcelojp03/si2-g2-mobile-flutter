import '../../core/http/api_client.dart';
import '../models/historial_models.dart';

class EstudianteRepository {
  final ApiClient _api;
  EstudianteRepository(this._api);

  Future<HistorialAcademico> getHistorial(String idEstudiante, {String? idGestion}) async {
    final params = <String, dynamic>{};
    if (idGestion != null) params['idGestion'] = idGestion;
    final qs = params.entries.map((e) => '${e.key}=${e.value}').join('&');
    final path = '/estudiantes/$idEstudiante/historial${qs.isNotEmpty ? '?$qs' : ''}';
    final resp = await _api.get(path);
    return HistorialAcademico.fromJson(resp['data']);
  }
}
