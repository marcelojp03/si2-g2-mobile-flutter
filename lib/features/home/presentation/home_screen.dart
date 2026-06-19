import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../config/theme/theme_provider.dart';
import '../../../core/http/api_client.dart';
import '../../../data/repositories/comunicados_repository.dart';
import '../../../data/models/comunicado_model.dart';
import '../../auth/providers/auth_provider.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});
  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final _comRepo = ComunicadosRepository(ApiClient());
  List<ComunicadoModel> _comunicados = [];
  bool _loading = true;

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    try {
      final data = await _comRepo.getPublicados();
      if (mounted) setState(() {
        _comunicados = data.map((e) => ComunicadoModel.fromJson(e)).toList();
        _loading = false;
      });
    } catch (_) { if (mounted) setState(() => _loading = false); }
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authProvider);
    final u = auth.user;
    final isDark = ref.watch(themeProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('SIA - UAGRM'), actions: [
        IconButton(icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode),
            onPressed: () => ref.read(themeProvider.notifier).toggleTheme()),
      ]),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        Card(child: ListTile(
          leading: CircleAvatar(child: Text((u != null && u.nombres.isNotEmpty ? u.nombres[0] : 'U'))),
          title: Text(u?.nombreCompleto ?? 'Usuario'),
          subtitle: Text(u?.correo ?? ''),
        )),
        const SizedBox(height: 16),
        _card(Icons.check_circle_outline, Colors.green, 'Asistencia', () => context.push('/asistencia')),
        _card(Icons.grading_outlined, Colors.blue, 'Calificaciones', () => context.push('/calificaciones')),
        _card(Icons.credit_card_outlined, Colors.orange, 'Mis Cuotas', () => context.push('/cuotas')),
        const SizedBox(height: 16),
        Text('Comunicados', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        if (_loading) const Center(child: Padding(padding: EdgeInsets.all(24), child: CircularProgressIndicator()))
        else if (_comunicados.isEmpty) const Card(child: Padding(padding: EdgeInsets.all(16), child: Text('No hay comunicados')))
        else for (final c in _comunicados) Card(margin: const EdgeInsets.only(bottom: 8), child: ListTile(
          leading: Icon(Icons.campaign, color: c.tipo == 'URGENTE' ? Colors.red : Colors.blue),
          title: Text(c.titulo), subtitle: Text(c.contenido, maxLines: 2, overflow: TextOverflow.ellipsis),
        )),
        Card(child: ListTile(
          leading: const Icon(Icons.logout, color: Colors.red),
          title: const Text('Cerrar sesion', style: TextStyle(color: Colors.red)),
          onTap: () async { await ref.read(authProvider.notifier).logout(); if (context.mounted) context.go('/login'); },
        )),
      ]),
    );
  }

  Widget _card(IconData icon, Color color, String title, VoidCallback onTap) => Card(
    margin: const EdgeInsets.only(bottom: 8),
    child: ListTile(leading: Icon(icon, color: color), title: Text(title), trailing: TextButton(onPressed: onTap, child: const Text('Ver'))));
}
