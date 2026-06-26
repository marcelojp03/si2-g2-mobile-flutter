import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/http/api_client.dart';
import '../../../data/repositories/estudiante_repository.dart';
import '../../../data/models/historial_models.dart';
import '../../auth/providers/auth_provider.dart';
import '../../../shared/widgets/glass_card.dart';
import '../../../shared/widgets/empty_state.dart';

class AsistenciaScreen extends ConsumerStatefulWidget {
  const AsistenciaScreen({super.key});
  @override
  ConsumerState<AsistenciaScreen> createState() => _AsistenciaScreenState();
}

class _AsistenciaScreenState extends ConsumerState<AsistenciaScreen> {
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
      appBar: AppBar(title: const Text('Asistencia')),
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
          child: Row(
            children: [
              Container(
                width: 48, height: 48,
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(height: 16, width: 160,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(4),
                      )),
                    const SizedBox(height: 8),
                    Container(height: 12, width: 100,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceContainerHigh,
                        borderRadius: BorderRadius.circular(4),
                      )),
                  ],
                ),
              ),
              Container(width: 48, height: 48,
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(24),
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
        icon: Icons.calendar_month_outlined,
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
                Text(gestion.nombreGestion,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
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
    final asis = m.porcentajeAsistencia;
    final color = asis == null
        ? theme.colorScheme.onSurfaceVariant
        : asis >= 85
            ? theme.colorScheme.tertiary
            : asis >= 70
                ? theme.colorScheme.secondary
                : theme.colorScheme.error;

    return GlassCard(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          SizedBox(
            width: 52, height: 52,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 52, height: 52,
                  child: CircularProgressIndicator(
                    value: asis != null ? asis / 100 : 0,
                    backgroundColor: theme.colorScheme.surfaceContainerHighest,
                    valueColor: AlwaysStoppedAnimation(color),
                    strokeWidth: 4,
                  ),
                ),
                Text(asis?.toStringAsFixed(0) ?? '-',
                  style: TextStyle(
                    fontSize: 13, fontWeight: FontWeight.bold, color: color)),
              ],
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(m.nombreMateria,
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: theme.colorScheme.onSurface)),
                const SizedBox(height: 2),
                Text('${m.sesionesPresente}/${m.totalSesiones} sesiones',
                  style: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontSize: 13)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text('${asis?.toStringAsFixed(1) ?? "-"}%',
              style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 15)),
          ),
        ],
      ),
    );
  }
}
