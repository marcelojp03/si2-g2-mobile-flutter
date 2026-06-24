import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../config/theme/theme_provider.dart';
import '../../../core/http/api_client.dart';
import '../../../data/repositories/cuotas_repository.dart';
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
  final _cuotasRepo = CuotasRepository(ApiClient());
  List<ComunicadoModel> _comunicados = [];
  int _cuotasPendientes = 0;
  bool _loading = true;

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    try {
      final results = await Future.wait([
        _comRepo.getPublicados(),
        _cuotasRepo.getCuotas(),
      ]);
      if (mounted) setState(() {
        _comunicados = (results[0] as List)
            .map((e) => ComunicadoModel.fromJson(e as Map<String, dynamic>))
            .toList();
        _cuotasPendientes = (results[1] as List)
            .where((c) => (c as Map)['estado'] == 'PENDIENTE')
            .length;
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
        Row(children: [
          Expanded(child: _card(Icons.check_circle_outline, Colors.green, 'Asistencia', () => context.push('/asistencia'))),
          const SizedBox(width: 8),
          Expanded(child: _card(Icons.grading_outlined, Colors.blue, 'Notas', () => context.push('/calificaciones'))),
        ]),
        const SizedBox(height: 8),
        _cuotasCard(),
        const SizedBox(height: 16),
        Text('Comunicados', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        if (_loading) const Center(child: Padding(padding: EdgeInsets.all(24), child: CircularProgressIndicator()))
        else if (_comunicados.isEmpty) const Card(child: Padding(padding: EdgeInsets.all(16), child: Text('No hay comunicados')))
        else for (final c in _comunicados) Card(margin: const EdgeInsets.only(bottom: 8), child: ListTile(
          leading: Icon(Icons.campaign, color: c.tipo == 'URGENTE' ? Colors.red : Colors.blue),
          title: Text(c.titulo), subtitle: Text(c.contenido, maxLines: 2, overflow: TextOverflow.ellipsis),
        )),
        const SizedBox(height: 8),
        Card(child: ListTile(
          leading: const Icon(Icons.logout, color: Colors.red),
          title: const Text('Cerrar sesion', style: TextStyle(color: Colors.red)),
          onTap: () async { await ref.read(authProvider.notifier).logout(); if (context.mounted) context.go('/login'); },
        )),
      ]),
    );
  }

  Widget _card(IconData icon, Color color, String title, VoidCallback onTap) => Card(
    margin: EdgeInsets.zero,
    child: ListTile(leading: Icon(icon, color: color), title: Text(title), trailing: TextButton(onPressed: onTap, child: const Text('Ver'))));

  Widget _cuotasCard() {
    final pendientes = _cuotasPendientes;
    final color = pendientes > 0 ? Colors.orange : Colors.green;
    final badge = pendientes > 0 ? '$pendientes pendiente${pendientes > 1 ? 's' : ''}' : 'Al día';
    return Card(
      child: ListTile(
        leading: Badge(
          isLabelVisible: pendientes > 0,
          label: Text('$pendientes', style: const TextStyle(fontSize: 10)),
          child: Icon(Icons.credit_card_outlined, color: color),
        ),
        title: const Text('Mis Cuotas'),
        subtitle: Text(badge, style: TextStyle(color: color, fontSize: 12)),
        trailing: TextButton(
            onPressed: () => context.push('/cuotas'), child: const Text('Ver')),
      ),
    );
  }
}
