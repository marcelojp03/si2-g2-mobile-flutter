import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/cuotas_provider.dart';
import '../../../data/models/cuota_model.dart';
import '../../../shared/widgets/glass_card.dart';
import '../../../shared/widgets/app_dialog.dart';
import '../../../shared/widgets/empty_state.dart';

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

  void _pollCleanup() => ref.read(cuotasProvider.notifier).cancelarPago();

  @override
  Widget build(BuildContext context) {
    final s = ref.watch(cuotasProvider);
    final pendientesCount = s.pendientes.length;
    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (_, __) => _pollCleanup(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Mis Cuotas'),
          bottom: TabBar(
            controller: _tabCtrl,
            tabs: [
              Tab(text: 'Pendientes ($pendientesCount)'),
              Tab(text: 'Pagadas (${s.pagadas.length})'),
              const Tab(text: 'Historial'),
            ],
          ),
        ),
        body: s.loading
            ? _buildSkeleton()
            : s.error != null && s.cuotas.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.error_outline, size: 48, color: Theme.of(context).colorScheme.error),
                          const SizedBox(height: 16),
                          Text('Error: ${s.error}',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Theme.of(context).colorScheme.error)),
                          const SizedBox(height: 16),
                          FilledButton.tonal(
                            onPressed: () => ref.read(cuotasProvider.notifier).load(),
                            child: const Text('Reintentar'),
                          ),
                        ],
                      ),
                    ),
                  )
                : TabBarView(controller: _tabCtrl, children: [
                    _listado(s.pendientes, s, 'No hay cuotas pendientes'),
                    _listado(s.pagadas, s, 'No hay cuotas pagadas'),
                    _historial(s.pagos),
                  ]),
      ),
    );
  }

  Widget _buildSkeleton() {
    final theme = Theme.of(context);
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 5,
      itemBuilder: (_, __) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: GlassCard(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 44, height: 44,
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(22),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(height: 16, width: 120,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(4),
                      )),
                    const SizedBox(height: 8),
                    Container(height: 12, width: 80,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceContainerHigh,
                        borderRadius: BorderRadius.circular(4),
                      )),
                  ],
                ),
              ),
              Container(width: 60, height: 36,
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8),
                )),
            ],
          ),
        ),
      ),
    );
  }

  Widget _listado(List<Cuota> items, CuotasState s, String emptyMsg) {
    final theme = Theme.of(context);
    if (items.isEmpty) {
      return EmptyState(
        icon: Icons.credit_card_outlined,
        title: emptyMsg,
      );
    }
    return RefreshIndicator(
      onRefresh: () async {
        _pollCleanup();
        await ref.read(cuotasProvider.notifier).load();
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: items.length,
        itemBuilder: (_, i) {
          final c = items[i];
          final vencida = c.vencida;
          final pagada = c.pagada;
          return GlassCard(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 44, height: 44,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: pagada
                        ? theme.colorScheme.tertiaryContainer
                        : vencida
                            ? theme.colorScheme.errorContainer
                            : theme.colorScheme.secondaryContainer,
                  ),
                  alignment: Alignment.center,
                  child: Text('${c.numeroCuota}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: pagada
                          ? theme.colorScheme.onTertiaryContainer
                          : vencida
                              ? theme.colorScheme.onErrorContainer
                              : theme.colorScheme.onSecondaryContainer,
                    )),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(c.nombrePlan,
                        style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: theme.colorScheme.onSurface)),
                      const SizedBox(height: 2),
                      Text('Cuota ${c.numeroCuota}  ·  Bs ${c.monto.toStringAsFixed(2)}',
                        style: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontSize: 13)),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                if (pagada)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.tertiaryContainer,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text('Pagada',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: theme.colorScheme.onTertiaryContainer)),
                  )
                else if (vencida)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.errorContainer,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text('Vencida',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: theme.colorScheme.onErrorContainer)),
                  )
                else
                  FilledButton.tonal(
                    onPressed: s.pagando ? null : () => _showPaymentSheet(c),
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      minimumSize: Size.zero,
                    ),
                    child: s.pagando
                        ? const SizedBox(width: 16, height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2))
                        : const Text('Pagar', style: TextStyle(fontSize: 13)),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _historial(List<PagoModel> items) {
    final theme = Theme.of(context);
    if (items.isEmpty) {
      return EmptyState(
        icon: Icons.receipt_long_outlined,
        title: 'Sin pagos registrados',
      );
    }
    return RefreshIndicator(
      onRefresh: () async {
        _pollCleanup();
        await ref.read(cuotasProvider.notifier).load();
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: items.length,
        itemBuilder: (_, i) {
          final p = items[i];
          final completado = p.estado == 'COMPLETADO';
          return GlassCard(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Container(
                  width: 40, height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: completado ? theme.colorScheme.tertiaryContainer : theme.colorScheme.secondaryContainer,
                  ),
                  alignment: Alignment.center,
                  child: Icon(
                    completado ? Icons.check_circle : Icons.pending,
                    color: completado ? theme.colorScheme.tertiary : theme.colorScheme.secondary,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Bs ${p.monto.toStringAsFixed(2)}',
                        style: TextStyle(fontWeight: FontWeight.w600, color: theme.colorScheme.onSurface)),
                      const SizedBox(height: 2),
                      Text(
                        '${p.metodoPago}${p.proveedor != null ? " via ${p.proveedor}" : ""}',
                        style: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: completado ? theme.colorScheme.tertiaryContainer : theme.colorScheme.secondaryContainer,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(p.estado,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                          color: completado ? theme.colorScheme.onTertiaryContainer : theme.colorScheme.onSecondaryContainer,
                        )),
                    ),
                    if (p.pagadoEn != null) ...[
                      const SizedBox(height: 2),
                      Text(_formatDate(p.pagadoEn!),
                        style: TextStyle(fontSize: 10, color: theme.colorScheme.onSurfaceVariant)),
                    ],
                  ],
                ),
              ],
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
    final theme = Theme.of(context);
    final notifier = ref.read(cuotasProvider.notifier);
    notifier.generarQr(c.id);

    AppDialog.show(
      context,
      maxHeight: 500,
      child: Consumer(builder: (_, watch2, __) {
        final st = watch2.watch(cuotasProvider);
        final pagado = st.estadoPago == 'COMPLETADO';

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Pagar ${c.nombrePlan}',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface)),
            const SizedBox(height: 4),
            Text('Cuota ${c.numeroCuota}',
              style: TextStyle(color: theme.colorScheme.onSurfaceVariant)),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Monto: ', style: TextStyle(color: theme.colorScheme.onSurfaceVariant)),
                Text('Bs ${c.monto.toStringAsFixed(2)}',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface)),
              ],
            ),
            const SizedBox(height: 20),
            if (pagado)
              _buildPagadoView()
            else if (st.error != null)
              _buildErrorView(st.error!, () => notifier.generarQr(c.id))
            else if (st.qrBase64 != null)
              _buildQrView(st.qrBase64!, st.polling, notifier)
            else
              _buildLoadingView(),
          ],
        );
      }),
    ).then((_) => _pollCleanup());
  }

  Widget _buildPagadoView() {
    final theme = Theme.of(context);
    return Column(
      children: [
        Container(
          width: 80, height: 80,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: theme.colorScheme.tertiaryContainer,
          ),
          child: Icon(Icons.check_circle, size: 56, color: theme.colorScheme.tertiary),
        ),
        const SizedBox(height: 16),
        Text('Pago confirmado',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: theme.colorScheme.tertiary)),
        const SizedBox(height: 8),
        Text('Procesado exitosamente a traves de VPay',
          textAlign: TextAlign.center,
          style: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontSize: 13)),
        const SizedBox(height: 20),
        FilledButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cerrar'),
        ),
      ],
    );
  }

  Widget _buildErrorView(String error, VoidCallback onRetry) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Container(
          width: 60, height: 60,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: theme.colorScheme.errorContainer,
          ),
          child: Icon(Icons.error_outline, size: 36, color: theme.colorScheme.error),
        ),
        const SizedBox(height: 12),
        Text('Error: $error',
          textAlign: TextAlign.center,
          style: TextStyle(color: theme.colorScheme.error, fontSize: 13)),
        const SizedBox(height: 16),
        FilledButton.tonal(onPressed: onRetry, child: const Text('Reintentar')),
      ],
    );
  }

  Widget _buildQrView(String base64, bool polling, CuotasNotifier notifier) {
    final theme = Theme.of(context);
    return Column(
      children: [
        _qrImage(base64),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: theme.colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.qr_code_scanner, size: 18, color: theme.colorScheme.onPrimaryContainer),
              const SizedBox(width: 6),
              Text('Escanea con tu app bancaria',
                style: TextStyle(fontSize: 12, color: theme.colorScheme.onPrimaryContainer)),
            ],
          ),
        ),
        const SizedBox(height: 12),
        if (polling)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: theme.colorScheme.secondaryContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 16, height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5, color: theme.colorScheme.secondary),
                ),
                const SizedBox(width: 8),
                Text('Esperando confirmacion...',
                  style: TextStyle(color: theme.colorScheme.onSecondaryContainer, fontSize: 13)),
              ],
            ),
          ),
        const SizedBox(height: 16),
        TextButton.icon(
          onPressed: () {
            notifier.cancelarPago();
            Navigator.pop(context);
          },
          icon: Icon(Icons.close, size: 18, color: theme.colorScheme.onSurfaceVariant),
          label: Text('Cancelar pago', style: TextStyle(color: theme.colorScheme.onSurfaceVariant)),
        ),
      ],
    );
  }

  Widget _buildLoadingView() {
    final theme = Theme.of(context);
    return Column(
      children: [
        const SizedBox(height: 20),
        Container(
          width: 60, height: 60,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: theme.colorScheme.surfaceContainerHigh,
          ),
          child: const CircularProgressIndicator(strokeWidth: 3),
        ),
        const SizedBox(height: 16),
        Text('Generando QR de pago...',
          style: TextStyle(color: theme.colorScheme.onSurfaceVariant)),
      ],
    );
  }

  Widget _qrImage(String base64) {
    final theme = Theme.of(context);
    try {
      final bytes = base64Decode(base64);
      return Container(
        width: 280,
        height: 280,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: theme.colorScheme.outlineVariant, width: 2),
          boxShadow: [
            BoxShadow(
              color: theme.colorScheme.shadow.withValues(alpha: 0.06),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.memory(bytes, fit: BoxFit.contain),
        ),
      );
    } catch (_) {
      return Container(
        width: 280,
        height: 280,
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: theme.colorScheme.outlineVariant),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.qr_code, size: 48, color: theme.colorScheme.onSurfaceVariant),
            const SizedBox(height: 4),
            Text('QR no disponible',
              style: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontSize: 12)),
          ],
        ),
      );
    }
  }
}
