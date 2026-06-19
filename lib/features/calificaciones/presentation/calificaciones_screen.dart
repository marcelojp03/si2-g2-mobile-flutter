import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/http/api_client.dart';
import '../../../data/repositories/estudiante_repository.dart';
import '../../../data/models/historial_models.dart';
import '../../auth/providers/auth_provider.dart';

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
    if (user?.idEstudiante == null) { setState(() { _loading = false; _error = 'No eres estudiante'; }); return; }
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
    return Scaffold(
      appBar: AppBar(title: const Text('Calificaciones')),
      body: _loading ? const Center(child: CircularProgressIndicator())
          : _error != null ? Center(child: Text(_error!, style: const TextStyle(color: Colors.red)))
          : _buildContent(),
    );
  }

  Widget _buildContent() {
    final gestion = _data!.gestiones.isNotEmpty ? _data!.gestiones.first : null;
    if (gestion == null) return const Center(child: Text('Sin datos academicos'));

    return ListView(padding: const EdgeInsets.all(16), children: [
      Text(gestion.nombreGestion, style: Theme.of(context).textTheme.titleLarge),
      Text('Paralelo: ${gestion.nombreParalelo}', style: Theme.of(context).textTheme.bodyMedium),
      const SizedBox(height: 16),
      for (final m in gestion.materias) _materiaCard(m),
    ]);
  }

  Widget _materiaCard(HistorialMateria m) {
    final prom = m.promedioGeneral;
    final color = prom == null ? Colors.grey : prom >= 51 ? Colors.green : prom >= 36 ? Colors.orange : Colors.red;

    return Card(margin: const EdgeInsets.only(bottom: 12), child: ExpansionTile(
      leading: CircleAvatar(backgroundColor: color.withAlpha(51), child: Text(
        prom?.toStringAsFixed(0) ?? '-', style: TextStyle(color: color, fontWeight: FontWeight.bold))),
      title: Text(m.nombreMateria, style: const TextStyle(fontWeight: FontWeight.w500)),
      subtitle: Text('${m.codigoMateria}  |  ${m.evaluaciones.length} evaluaciones'),
      children: [
        if (m.evaluaciones.isEmpty)
          const Padding(padding: EdgeInsets.all(16), child: Text('Sin evaluaciones registradas'))
        else
          for (final e in m.evaluaciones)
            ListTile(
              dense: true,
              title: Text(e.nombreEvaluacion),
              subtitle: Text('${e.tipoEvaluacion ?? "Evaluacion"} - Periodo ${e.periodo ?? 1}'),
              trailing: Text(
                '${e.nota?.toStringAsFixed(1) ?? "-"}/${e.puntajeMaximo?.toStringAsFixed(0) ?? "-"}',
                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue.shade700)),
            ),
      ],
    ));
  }
}
