import 'dart:convert';
import 'package:flutter/material.dart';
import '../../core/services/api_service.dart';

class TutorHome extends StatefulWidget {
  const TutorHome({super.key});

  @override
  State<TutorHome> createState() => _TutorHomeState();
}

class _TutorHomeState extends State<TutorHome> {
  Map<String, dynamic>? _estudiante;
  bool _loading = true;
  final _api = ApiService();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _loading = true);
    try {
      final resp = await _api.get('/api/tutores/mi-estudiante');
      if (resp.statusCode == 200 && mounted) {
        final body = jsonDecode(resp.body);
        setState(() {
          _estudiante = body['data'];
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: ListTile(
              leading: CircleAvatar(
                child: Text((_estudiante?['nombres'] as String? ?? 'E')[0]),
              ),
              title: Text('${_estudiante?['nombres'] ?? ''} ${_estudiante?['apellidos'] ?? ''}'),
              subtitle: const Text('Estudiante vinculado'),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: ListTile(
              leading: const Icon(Icons.check_circle_outline, color: Colors.green),
              title: const Text('Asistencia'),
              trailing: TextButton(onPressed: () {}, child: const Text('Ver')),
            ),
          ),
          const SizedBox(height: 8),
          Card(
            child: ListTile(
              leading: const Icon(Icons.grading_outlined, color: Colors.blue),
              title: const Text('Calificaciones'),
              trailing: TextButton(onPressed: () {}, child: const Text('Ver')),
            ),
          ),
        ],
      ),
    );
  }
}
