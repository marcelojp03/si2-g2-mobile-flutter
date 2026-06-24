import 'dart:async';
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

  final String? qrBase64;
  final String? idPagoActual;
  final String? proveedor;
  final String estadoPago;
  final bool polling;

  CuotasState({
    this.cuotas = const [],
    this.pagos = const [],
    this.loading = false,
    this.pagando = false,
    this.error,
    this.qrBase64,
    this.idPagoActual,
    this.proveedor,
    this.estadoPago = '',
    this.polling = false,
  });

  List<Cuota> get pendientes => cuotas.where((c) => !c.pagada).toList();
  List<Cuota> get pagadas => cuotas.where((c) => c.pagada).toList();
}

class CuotasNotifier extends StateNotifier<CuotasState> {
  final CuotasRepository _repo;
  Timer? _pollTimer;

  CuotasNotifier(this._repo) : super(CuotasState());

  @override
  void dispose() {
    _pollTimer?.cancel();
    super.dispose();
  }

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

  Future<void> generarQr(String idCuota) async {
    state = CuotasState(
      cuotas: state.cuotas,
      pagos: state.pagos,
      loading: false,
      pagando: true,
    );
    try {
      final data = await _repo.generarQr(idCuota);
      state = CuotasState(
        cuotas: state.cuotas,
        pagos: state.pagos,
        loading: false,
        qrBase64: data['qrBase64'] as String?,
        idPagoActual: data['idPago']?.toString(),
        proveedor: data['proveedor'] as String?,
        estadoPago: 'PENDIENTE',
      );
      if (state.idPagoActual != null) {
        _startPolling(state.idPagoActual!);
      }
    } catch (e) {
      state = CuotasState(
        cuotas: state.cuotas,
        pagos: state.pagos,
        error: e.toString(),
      );
    }
  }

  void _startPolling(String idPago) {
    _pollTimer?.cancel();
    _pollTimer = Timer.periodic(const Duration(seconds: 5), (_) async {
      try {
        final data = await _repo.consultarEstado(idPago);
        final pagado = data['pagado'] == true;
        final estado = data['estadoPago'] as String? ?? '';
        state = CuotasState(
          cuotas: state.cuotas,
          pagos: state.pagos,
          loading: false,
          qrBase64: state.qrBase64,
          idPagoActual: idPago,
          proveedor: state.proveedor,
          estadoPago: estado,
          polling: true,
        );
        if (pagado || estado == 'COMPLETADO') {
          _pollTimer?.cancel();
          await load();
        }
      } catch (_) {}
    });
  }

  void cancelarPago() {
    _pollTimer?.cancel();
    state = CuotasState(
      cuotas: state.cuotas,
      pagos: state.pagos,
      loading: false,
    );
  }
}

final cuotasProvider = StateNotifierProvider<CuotasNotifier, CuotasState>((ref) {
  return CuotasNotifier(CuotasRepository(ApiClient()));
});
