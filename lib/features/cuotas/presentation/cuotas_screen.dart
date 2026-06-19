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
  void dispose() { _tabCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final s = ref.watch(cuotasProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Mis Cuotas'), bottom: TabBar(
        controller: _tabCtrl, tabs: [
        Tab(text: 'Pendientes (${s.pendientes.length})'),
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
    );
  }

  Widget _listado(List<Cuota> items, CuotasState s) {
    if (items.isEmpty) {
      return const Center(child: Text('No hay cuotas en esta categoría'));
    }
    return RefreshIndicator(
      onRefresh: () => ref.read(cuotasProvider.notifier).load(),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: items.length,
        itemBuilder: (_, i) {
          final c = items[i];
          final vencida = c.vencida;
          return Card(margin: const EdgeInsets.only(bottom: 8), child: ListTile(
            leading: CircleAvatar(
              backgroundColor: c.pagada ? Colors.green.shade100 : vencida ? Colors.red.shade100 : Colors.orange.shade100,
              child: Text('${c.numeroCuota}', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            title: Text('${c.nombrePlan} - Cuota ${c.numeroCuota}'),
            subtitle: Text('Bs ${c.monto.toStringAsFixed(2)}  |  Vence: ${c.fechaVencimiento ?? "---"}'),
            trailing: c.pagada
                ? Chip(label: const Text('Pagada'), backgroundColor: Colors.green.shade100, labelStyle: const TextStyle(fontSize: 12))
                : vencida
                    ? Chip(label: const Text('Vencida'), backgroundColor: Colors.red.shade100, labelStyle: const TextStyle(fontSize: 12, color: Colors.red))
                    : FilledButton.tonal(
                        onPressed: s.pagando ? null : () => _showPagarDialog(c),
                        child: s.pagando
                            ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                            : const Text('Pagar', style: TextStyle(fontSize: 12))),
          ));
        },
      ),
    );
  }

  Widget _historial(List<PagoModel> items) {
    if (items.isEmpty) return const Center(child: Text('Sin pagos registrados'));
    return RefreshIndicator(
      onRefresh: () => ref.read(cuotasProvider.notifier).load(),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: items.length,
        itemBuilder: (_, i) {
          final p = items[i];
          return Card(margin: const EdgeInsets.only(bottom: 8), child: ListTile(
            leading: Icon(p.estado == 'CONFIRMADO' ? Icons.check_circle : Icons.pending, color: p.estado == 'CONFIRMADO' ? Colors.green : Colors.orange),
            title: Text('Bs ${p.monto.toStringAsFixed(2)} ${p.moneda}'),
            subtitle: Text('${p.metodoPago}${p.proveedor != null ? " via ${p.proveedor}" : ""}  |  ${p.pagadoEn ?? p.estado}'),
            trailing: Text(p.estado, style: TextStyle(fontSize: 12, color: p.estado == 'CONFIRMADO' ? Colors.green : Colors.orange)),
          ));
        },
      ),
    );
  }

  void _showPagarDialog(Cuota c) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Pagar Cuota ${c.numeroCuota}'),
        content: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('${c.nombrePlan}', style: Theme.of(context).textTheme.bodyLarge),
          const SizedBox(height: 8),
          Text('Monto: Bs ${c.monto.toStringAsFixed(2)}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          Text('Vencimiento: ${c.fechaVencimiento ?? "---"}'),
          const SizedBox(height: 16),
          Container(
            width: double.infinity, height: 120,
            decoration: BoxDecoration(
              color: Colors.grey.shade100, borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Icon(Icons.qr_code, size: 48, color: Colors.grey.shade600),
              const SizedBox(height: 4),
              Text('QR simulado', style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
            ])),
          ),
          const SizedBox(height: 8),
          Text('Escanea el QR o confirma el pago', style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
        ]),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
          FilledButton.icon(
            onPressed: () async {
              Navigator.pop(ctx);
              final ok = await ref.read(cuotasProvider.notifier).pagar(c.id, c.monto);
              if (ok != null && mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Pago registrado: Bs ${c.monto.toStringAsFixed(2)}'), backgroundColor: Colors.green));
              }
            },
            icon: const Icon(Icons.check, size: 18),
            label: const Text('Confirmar Pago'),
          ),
        ],
      ),
    );
  }
}
