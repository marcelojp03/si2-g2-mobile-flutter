import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/cuotas_provider.dart';
import '../../../data/models/cuota_model.dart';

class CuotasScreen extends ConsumerStatefulWidget {
  const CuotasScreen({super.key});
  @override
  ConsumerState<CuotasScreen> createState() => _CuotasScreenState();
}

class _CuotasScreenState extends ConsumerState<CuotasScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 3, vsync: this);
    Future.microtask(() => ref.read(cuotasProvider.notifier).load());
  }

  @override
  void dispose() { _pollCleanup(); _tabCtrl.dispose(); super.dispose(); }

  void _pollCleanup() => ref.read(cuotasProvider.notifier).cancelarPago();

  @override
  Widget build(BuildContext context) {
    final s = ref.watch(cuotasProvider);
    final pendientesCount = s.pendientes.length;
    return PopScope(
      onPopInvokedWithResult: (_, __) => _pollCleanup(),
      child: Scaffold(
        appBar: AppBar(title: const Text('Mis Cuotas'), bottom: TabBar(
          controller: _tabCtrl, tabs: [
          Tab(text: 'Pendientes ($pendientesCount)'),
          Tab(text: 'Pagadas (${s.pagadas.length})'),
          const Tab(text: 'Historial'),
        ])),
        body: s.loading
            ? const Center(child: CircularProgressIndicator())
            : s.error != null && s.cuotas.isEmpty
                ? Center(child: Text('Error: ${s.error}', style: const TextStyle(color: Colors.red)))
                : TabBarView(controller: _tabCtrl, children: [
                    _listado(s.pendientes, s),
                    _listado(s.pagadas, s),
                    _historial(s.pagos),
                  ]),
      ),
    );
  }

  Widget _listado(List<Cuota> items, CuotasState s) {
    if (items.isEmpty) {
      return const Center(child: Text('No hay cuotas en esta categoría'));
    }
    return RefreshIndicator(
      onRefresh: () async {
        _pollCleanup();
        await ref.read(cuotasProvider.notifier).load();
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: items.length,
        itemBuilder: (_, i) {
          final c = items[i];
          final vencida = c.vencida;
          final pagada = c.pagada;
          return Card(
            margin: const EdgeInsets.only(bottom: 8),
            elevation: pagada ? 0 : 1,
            child: ListTile(
              leading: CircleAvatar(
                radius: 22,
                backgroundColor: pagada
                    ? Colors.green.shade100
                    : vencida
                        ? Colors.red.shade100
                        : Colors.orange.shade100,
                child: Text('${c.numeroCuota}',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: pagada
                            ? Colors.green.shade800
                            : vencida
                                ? Colors.red.shade800
                                : Colors.orange.shade800)),
              ),
              title: Text(c.nombrePlan,
                  style: const TextStyle(fontWeight: FontWeight.w600)),
              subtitle: Text(
                'Cuota ${
                    c.numeroCuota}  ·  Bs ${c.monto.toStringAsFixed(2)}',
                style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
              ),
              trailing: pagada
                  ? Chip(
                      label: const Text('Pagada', style: TextStyle(fontSize: 11)),
                      backgroundColor: Colors.green.shade100,
                      padding: EdgeInsets.zero,
                      visualDensity: VisualDensity.compact)
                  : vencida
                      ? Chip(
                          label: Text('Vencida',
                              style: TextStyle(
                                  fontSize: 11, color: Colors.red.shade700)),
                          backgroundColor: Colors.red.shade50,
                          padding: EdgeInsets.zero,
                          visualDensity: VisualDensity.compact)
                      : FilledButton.tonal(
                          onPressed: s.pagando
                              ? null
                              : () => _showPaymentSheet(c),
                          style: FilledButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 8)),
                          child: s.pagando
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2))
                              : const Text('Pagar',
                                  style: TextStyle(fontSize: 13)),
                        ),
            ),
          );
        },
      ),
    );
  }

  Widget _historial(List<PagoModel> items) {
    if (items.isEmpty) {
      return const Center(child: Text('Sin pagos registrados'));
    }
    return RefreshIndicator(
      onRefresh: () async {
        _pollCleanup();
        await ref.read(cuotasProvider.notifier).load();
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: items.length,
        itemBuilder: (_, i) {
          final p = items[i];
          final completado = p.estado == 'COMPLETADO';
          return Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              leading: Icon(
                completado ? Icons.check_circle : Icons.pending,
                color: completado ? Colors.green : Colors.orange,
                size: 28,
              ),
              title: Text(
                'Bs ${p.monto.toStringAsFixed(2)}',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              subtitle: Text(
                '${p.metodoPago}${p.proveedor != null ? " via ${p.proveedor}" : ""}',
                style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
              ),
              trailing: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(p.estado,
                      style: TextStyle(
                          fontSize: 11,
                          color: completado ? Colors.green : Colors.orange,
                          fontWeight: FontWeight.w500)),
                  if (p.pagadoEn != null)
                    Text(_formatDate(p.pagadoEn!),
                        style: TextStyle(
                            fontSize: 10, color: Colors.grey.shade500)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  String _formatDate(String iso) {
    try {
      final dt = DateTime.parse(iso);
      return '${dt.day}/${dt.month}/${dt.year}';
    } catch (_) {
      return iso;
    }
  }

  void _showPaymentSheet(Cuota c) {
    final notifier = ref.read(cuotasProvider.notifier);
    notifier.generarQr(c.id);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) {
        return Consumer(builder: (context2, watch2, _) {
          final st = watch2.watch(cuotasProvider);
          final pagado = st.estadoPago == 'COMPLETADO';

          return Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context2).viewInsets.bottom,
              left: 24,
              right: 24,
              top: 24,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 16),
                Text('Pagar ${c.nombrePlan}',
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text('Cuota ${c.numeroCuota}',
                    style: TextStyle(color: Colors.grey.shade600)),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Monto: ',
                        style: TextStyle(color: Colors.grey)),
                    Text('Bs ${c.monto.toStringAsFixed(2)}',
                        style: const TextStyle(
                            fontSize: 28, fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 16),
                if (pagado) ...[
                  const Icon(Icons.check_circle,
                      size: 80, color: Colors.green),
                  const SizedBox(height: 12),
                  const Text('¡Pago confirmado!',
                      style: TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold,
                          color: Colors.green)),
                  const SizedBox(height: 8),
                  Text('Tu pago fue procesado exitosamente a través de ${st.proveedor ?? "VPay"}',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey.shade600)),
                  const SizedBox(height: 20),
                  FilledButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: const Text('Cerrar'),
                  ),
                ] else if (st.error != null) ...[
                  Icon(Icons.error_outline, size: 60, color: Colors.red.shade300),
                  const SizedBox(height: 12),
                  Text('Error: ${st.error}',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.red.shade600)),
                  const SizedBox(height: 16),
                  FilledButton.tonal(
                    onPressed: () => notifier.generarQr(c.id),
                    child: const Text('Reintentar'),
                  ),
                ] else if (st.qrBase64 != null) ...[
                  _qrImage(st.qrBase64!),
                  const SizedBox(height: 12),
                  Chip(
                    avatar: Icon(Icons.qr_code_scanner, size: 18, color: Colors.blue.shade700),
                    label: Text('Escanea con tu app bancaria',
                        style: TextStyle(fontSize: 12, color: Colors.blue.shade700)),
                    backgroundColor: Colors.blue.shade50,
                  ),
                  const SizedBox(height: 12),
                  if (st.polling)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 14, height: 14,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.orange.shade600),
                        ),
                        const SizedBox(width: 8),
                        Text('Esperando confirmación...',
                            style: TextStyle(
                                color: Colors.orange.shade600, fontSize: 13)),
                      ],
                    ),
                  const SizedBox(height: 20),
                  TextButton.icon(
                    onPressed: () {
                      notifier.cancelarPago();
                      Navigator.pop(ctx);
                    },
                    icon: const Icon(Icons.close, size: 18),
                    label: const Text('Cancelar pago'),
                  ),
                ] else ...[
                  const SizedBox(
                    width: 60, height: 60,
                    child: CircularProgressIndicator(),
                  ),
                  const SizedBox(height: 16),
                  const Text('Generando QR de pago...',
                      style: TextStyle(color: Colors.grey)),
                ],
                const SizedBox(height: 16),
              ],
            ),
          );
        });
      },
    ).then((_) => _pollCleanup());
  }

  Widget _qrImage(String base64) {
    try {
      final bytes = base64Decode(base64);
      return Container(
        width: 220,
        height: 220,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200, width: 2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.all(16),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.memory(bytes, fit: BoxFit.contain),
        ),
      );
    } catch (_) {
      return Container(
        width: 220,
        height: 220,
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.qr_code, size: 48, color: Colors.grey.shade600),
              const SizedBox(height: 4),
              Text('QR no disponible',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
            ],
          ),
        ),
      );
    }
  }
}
