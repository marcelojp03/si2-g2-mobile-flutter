import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/http/api_client.dart';
import '../../../data/repositories/estudiante_repository.dart';
import '../../../data/models/historial_models.dart';
import '../../auth/providers/auth_provider.dart';

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
      appBar: AppBar(title: const Text('Asistencia')),
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
      const SizedBox(height: 16),
      for (final m in gestion.materias) _materiaCard(m),
    ]);
  }

  Widget _materiaCard(HistorialMateria m) {
    final asis = m.porcentajeAsistencia;
    final color = asis == null ? Colors.grey : asis >= 85 ? Colors.green : asis >= 70 ? Colors.orange : Colors.red;

    return Card(margin: const EdgeInsets.only(bottom: 12), child: ListTile(
      leading: Stack(alignment: Alignment.center, children: [
        SizedBox(width: 48, height: 48, child: CircularProgressIndicator(
          value: asis != null ? asis / 100 : 0,
          backgroundColor: Colors.grey.shade200,
          valueColor: AlwaysStoppedAnimation(color),
          strokeWidth: 4,
        )),
        Text(asis?.toStringAsFixed(0) ?? '-', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
      ]),
      title: Text(m.nombreMateria, style: const TextStyle(fontWeight: FontWeight.w500)),
      subtitle: Text('${m.sesionesPresente}/${m.totalSesiones} sesiones'),
      trailing: Text(
        '${asis?.toStringAsFixed(1) ?? "-"}%',
        style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 16)),
    ));
  }
}
