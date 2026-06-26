import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/http/api_client.dart';
import '../../../data/repositories/estudiante_repository.dart';
import '../../../data/models/historial_models.dart';
import '../../auth/providers/auth_provider.dart';
import '../../../shared/widgets/glass_card.dart';
import '../../../shared/widgets/empty_state.dart';

class CalificacionesScreen extends ConsumerStatefulWidget {
  const CalificacionesScreen({super.key});
  @override
  ConsumerState<CalificacionesScreen> createState() => _CalificacionesScreenState();
}

class _CalificacionesScreenState extends ConsumerState<CalificacionesScreen> {
  HistorialAcademico? _data;
  bool _loading = true;
  String? _error;

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    final user = ref.read(authProvider).user;
    if (user?.idEstudiante == null) {
      if (mounted) setState(() { _loading = false; _error = 'No eres estudiante'; });
      return;
    }
    try {
      final repo = EstudianteRepository(ApiClient());
      final data = await repo.getHistorial(user!.idEstudiante!);
      if (mounted) setState(() { _data = data; _loading = false; });
    } catch (e) {
      if (mounted) setState(() { _error = e.toString(); _loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Calificaciones')),
      body: _loading
          ? _buildSkeleton()
          : _error != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.error_outline, size: 48, color: theme.colorScheme.error),
                        const SizedBox(height: 16),
                        Text(_error!, textAlign: TextAlign.center,
                          style: TextStyle(color: theme.colorScheme.error)),
                        const SizedBox(height: 16),
                        FilledButton.tonal(onPressed: _load, child: const Text('Reintentar')),
                      ],
                    ),
                  ),
                )
              : _buildContent(),
    );
  }

  Widget _buildSkeleton() {
    final theme = Theme.of(context);
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 4,
      itemBuilder: (_, __) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: GlassCard(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 40, height: 40,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(height: 16, width: 160,
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(4),
                          )),
                        const SizedBox(height: 6),
                        Container(height: 12, width: 120,
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surfaceContainerHigh,
                            borderRadius: BorderRadius.circular(4),
                          )),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Container(height: 10,
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(4),
                )),
              const SizedBox(height: 6),
              Container(height: 10, width: 160,
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(4),
                )),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    final gestion = _data!.gestiones.isNotEmpty ? _data!.gestiones.first : null;
    if (gestion == null) {
      return const EmptyState(
        icon: Icons.grading_outlined,
        title: 'Sin datos academicos',
      );
    }

    return RefreshIndicator(
      onRefresh: _load,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          GlassCard(
            margin: EdgeInsets.zero,
            child: Row(
              children: [
                Container(
                  width: 40, height: 40,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.school_rounded,
                    color: Theme.of(context).colorScheme.primary, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(gestion.nombreGestion,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
                      Text('Paralelo: ${gestion.nombreParalelo}',
                        style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 13)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          ...gestion.materias.map(_materiaCard),
        ],
      ),
    );
  }

  Widget _materiaCard(HistorialMateria m) {
    final theme = Theme.of(context);
    final prom = m.promedioGeneral;
    final color = prom == null
        ? theme.colorScheme.onSurfaceVariant
        : prom >= 51
            ? theme.colorScheme.tertiary
            : prom >= 36
                ? theme.colorScheme.secondary
                : theme.colorScheme.error;

    return GlassCard(
      margin: const EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.zero,
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        shape: const Border(),
        collapsedShape: const Border(),
        leading: Container(
          width: 40, height: 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color.withValues(alpha: 0.15),
          ),
          alignment: Alignment.center,
          child: Text(prom?.toStringAsFixed(0) ?? '-',
            style: TextStyle(color: color, fontWeight: FontWeight.bold)),
        ),
        title: Text(m.nombreMateria,
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: theme.colorScheme.onSurface)),
        subtitle: Text('${m.codigoMateria}  |  ${m.evaluaciones.length} evaluaciones',
          style: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontSize: 12)),
        children: [
          if (m.evaluaciones.isEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text('Sin evaluaciones registradas',
                style: TextStyle(color: theme.colorScheme.onSurfaceVariant)),
            )
          else
            ...m.evaluaciones.map((e) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(e.nombreEvaluacion,
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: theme.colorScheme.onSurface)),
                        Text('${e.tipoEvaluacion ?? "Evaluacion"} - Periodo ${e.periodo ?? 1}',
                          style: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontSize: 11)),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${e.nota?.toStringAsFixed(1) ?? "-"}/${e.puntajeMaximo?.toStringAsFixed(0) ?? "-"}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onPrimaryContainer,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            )),
        ],
      ),
    );
  }
}
