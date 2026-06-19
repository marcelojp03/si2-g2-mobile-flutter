import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/repositories/cuotas_repository.dart';
import '../../../data/models/cuota_model.dart';
import '../../../core/http/api_client.dart';

class CuotasState {
  final List<Cuota> cuotas;
  final List<PagoModel> pagos;
  final bool loading;
  final bool pagando;
  final String? error;

  CuotasState({
    this.cuotas = const [],
    this.pagos = const [],
    this.loading = false,
    this.pagando = false,
    this.error,
  });

  List<Cuota> get pendientes => cuotas.where((c) => !c.pagada).toList();
  List<Cuota> get pagadas => cuotas.where((c) => c.pagada).toList();
}

class CuotasNotifier extends StateNotifier<CuotasState> {
  final CuotasRepository _repo;
  CuotasNotifier(this._repo) : super(CuotasState());

  Future<void> load() async {
    state = CuotasState(loading: true);
    try {
      final cuotas = await _repo.getCuotas();
      final pagos = await _repo.getPagos();
      state = CuotasState(cuotas: cuotas, pagos: pagos, loading: false);
    } catch (e) {
      state = CuotasState(loading: false, error: e.toString());
    }
  }

  Future<PagoModel?> pagar(String idCuota, double monto) async {
    state = CuotasState(cuotas: state.cuotas, pagos: state.pagos, pagando: true);
    try {
      final pago = await _repo.pagar(idCuota, monto);
      await load();
      return pago;
    } catch (e) {
      state = CuotasState(cuotas: state.cuotas, pagos: state.pagos, error: e.toString());
      return null;
    }
  }
}

final cuotasProvider = StateNotifierProvider<CuotasNotifier, CuotasState>((ref) {
  return CuotasNotifier(CuotasRepository(ApiClient()));
});
