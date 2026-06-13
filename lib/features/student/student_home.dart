import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/services/api_service.dart';
import '../../core/config/api_config.dart';

class StudentHome extends StatefulWidget {
  const StudentHome({super.key});

  @override
  State<StudentHome> createState() => _StudentHomeState();
}

class _StudentHomeState extends State<StudentHome> {
  Map<String, dynamic>? _historial;
  Map<String, dynamic>? _asistencia;
  List<dynamic> _comunicados = [];
  bool _loading = true;
  String? _error;
  final _api = ApiService();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _loading = true);
    try {
      final auth = context.read<AuthProvider>();
      final userId = auth.user?.id ?? '';

      final results = await Future.wait([
        _api.get(ApiConfig.historial(userId)),
        _api.get(ApiConfig.comunicados),
        _api.get('/api/notificaciones/contar-no-leidas'),
      ]);

      if (mounted) {
        setState(() {
          if (results[0].statusCode == 200) _historial = jsonDecode(results[0].body);
          if (results[2].statusCode == 200) {
            final countData = jsonDecode(results[2].body);
          }
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() { _error = e.toString(); _loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    if (_loading) return const Center(child: CircularProgressIndicator());

    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: ListTile(
              leading: CircleAvatar(child: Text((auth.user?.nombres ?? 'E')[0])),
              title: Text(auth.user?.nombreCompleto ?? ''),
              subtitle: Text(auth.user?.correo ?? ''),
            ),
          ),
          const SizedBox(height: 16),
          _card('Asistencia', Icons.check_circle_outline, Colors.green, 'Ver detalle', () {
            Navigator.of(context).push(MaterialPageRoute(builder: (_) => const _AsistenciaScreen()));
          }),
          const SizedBox(height: 8),
          _card('Calificaciones', Icons.grading_outlined, Colors.blue, 'Ver historial', () {
            Navigator.of(context).push(MaterialPageRoute(builder: (_) => const _HistorialScreen()));
          }),
          const SizedBox(height: 8),
          _card('Comunicados', Icons.campaign_outlined, Colors.orange, 'Ver', () {
            Navigator.of(context).push(MaterialPageRoute(builder: (_) => const _ComunicadosScreen()));
          }),
        ],
      ),
    );
  }

  Widget _card(String title, IconData icon, Color color, String action, VoidCallback onTap) {
    return Card(
      child: ListTile(
        leading: Icon(icon, color: color),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
        trailing: TextButton(onPressed: onTap, child: Text(action)),
      ),
    );
  }
}

class _AsistenciaScreen extends StatelessWidget {
  const _AsistenciaScreen();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Asistencia')),
      body: const Center(child: Text('Asistencia - proximamente')),
    );
  }
}

class _HistorialScreen extends StatelessWidget {
  const _HistorialScreen();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Historial Academico')),
      body: const Center(child: Text('Historial - proximamente')),
    );
  }
}

class _ComunicadosScreen extends StatelessWidget {
  const _ComunicadosScreen();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Comunicados')),
      body: const Center(child: Text('Comunicados - proximamente')),
    );
  }
}
