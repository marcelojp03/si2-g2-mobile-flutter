import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/http/api_client.dart';
import '../../../data/repositories/cuotas_repository.dart';
import '../../../data/repositories/comunicados_repository.dart';
import '../../../data/models/comunicado_model.dart';
import '../../../data/models/cuota_model.dart';
import '../../../data/models/user_model.dart';
import '../../auth/providers/auth_provider.dart';
import '../../../config/theme/theme_provider.dart';
import '../../../shared/widgets/glass_card.dart';
import '../../../shared/widgets/empty_state.dart';

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
            .toList()
          ..sort((a, b) {
            final aDate = a.publicadoEn ?? a.creadoEn;
            final bDate = b.publicadoEn ?? b.creadoEn;
            return bDate.compareTo(aDate);
          });
        _cuotasPendientes = (results[1] as List<Cuota>)
            .where((c) => c.estado == 'PENDIENTE')
            .length;
        _loading = false;
      });
    } catch (e) {
      debugPrint('[Home] Error loading data: $e');
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authProvider);
    final u = auth.user;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('SIA - UAGRM'),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            tooltip: 'Cerrar sesion',
            onPressed: () async {
              final ok = await showDialog<bool>(
                context: context,
                builder: (_) => AlertDialog(
                  title: const Text('Cerrar sesion'),
                  content: const Text('¿Seguro que deseas salir?'),
                  actions: [
                    TextButton(onPressed: () => Navigator.of(context, rootNavigator: true).pop(false), child: const Text('Cancelar')),
                    FilledButton(onPressed: () => Navigator.of(context, rootNavigator: true).pop(true), child: const Text('Salir')),
                  ],
                ),
              );
              if (ok == true && context.mounted) {
                await ref.read(authProvider.notifier).logout();
                context.go('/login');
              }
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _load,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          children: [
            _profileCard(u),
            const SizedBox(height: 20),
            _gridCards(),
            const SizedBox(height: 24),
            _comunicadosSection(theme),
          ],
        ),
      ),
    );
  }

  Widget _profileCard(UserModel? u) {
    final theme = Theme.of(context);
    final initials = u != null && u.nombres.isNotEmpty
        ? u.nombres.split(' ').where((s) => s.isNotEmpty).map((s) => s[0]).take(2).join().toUpperCase()
        : 'U';
    return GlassCard(
      margin: EdgeInsets.zero,
      child: Row(
        children: [
          CircleAvatar(
            radius: 26,
            backgroundColor: theme.colorScheme.primaryContainer,
            child: Text(initials,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: theme.colorScheme.primary,
              )),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(u?.nombreCompleto ?? 'Usuario',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16, color: theme.colorScheme.onSurface)),
                const SizedBox(height: 2),
                Text(u?.correo ?? '',
                  style: TextStyle(fontSize: 13, color: theme.colorScheme.onSurfaceVariant)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _gridCards() {
    final pendientes = _cuotasPendientes;
    return LayoutBuilder(
      builder: (_, constraints) {
        final gap = 12.0;
        final itemWidth = (constraints.maxWidth - gap) / 2;
        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: [
            _navCard(
              width: itemWidth,
              icon: Icons.calendar_month_rounded,
              color: Colors.blue,
              title: 'Asistencia',
              subtitle: 'Ver registro',
              onTap: () => context.push('/asistencia'),
            ),
            _navCard(
              width: itemWidth,
              icon: Icons.grading_rounded,
              color: Colors.green,
              title: 'Notas',
              subtitle: 'Calificaciones',
              onTap: () => context.push('/calificaciones'),
            ),
            GlassCard(
              width: itemWidth,
              padding: const EdgeInsets.all(16),
              onTap: () => context.push('/cuotas'),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Stack(
                    children: [
                      Icon(Icons.credit_card_rounded,
                        size: 32, color: pendientes > 0 ? Colors.orange : Colors.green),
                      if (pendientes > 0)
                        Positioned(
                          right: -4, top: -4,
                          child: Container(
                            padding: const EdgeInsets.all(5),
                            decoration: const BoxDecoration(
                              color: Colors.orange,
                              shape: BoxShape.circle,
                            ),
                            child: Text('$pendientes',
                              style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text('Cuotas', style: TextStyle(fontWeight: FontWeight.w600, color: Theme.of(context).colorScheme.onSurface)),
                  const SizedBox(height: 2),
                  Text(
                    pendientes > 0 ? '$pendientes pendiente${pendientes > 1 ? 's' : ''}' : 'Al dia',
                    style: TextStyle(fontSize: 12,
                      color: pendientes > 0 ? Colors.orange : Colors.green.shade600),
                  ),
                ],
              ),
            ),
            _navCard(
              width: itemWidth,
              icon: Icons.description_rounded,
              color: Colors.purple,
              title: 'Perfil',
              subtitle: 'Mis datos',
              onTap: () => _showProfile(),
            ),
          ],
        );
      },
    );
  }

  Widget _navCard({
    required double width,
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    return GlassCard(
      width: width,
      padding: const EdgeInsets.all(16),
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 32, color: color),
          const SizedBox(height: 12),
          Text(title, style: TextStyle(fontWeight: FontWeight.w600, color: theme.colorScheme.onSurface)),
          const SizedBox(height: 2),
          Text(subtitle,
            style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurfaceVariant)),
        ],
      ),
    );
  }

  Widget _comunicadosSection(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.campaign_rounded, size: 20, color: theme.colorScheme.primary),
            const SizedBox(width: 8),
            Text('Comunicados',
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
          ],
        ),
        const SizedBox(height: 12),
        if (_loading)
          ...List.generate(3, (_) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: GlassCard(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(height: 16, width: 160,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(6),
                    )),
                  const SizedBox(height: 10),
                  Container(height: 12,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surfaceContainerHigh,
                      borderRadius: BorderRadius.circular(4),
                    )),
                  const SizedBox(height: 6),
                  Container(height: 12, width: 240,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surfaceContainerHigh,
                      borderRadius: BorderRadius.circular(4),
                    )),
                ],
              ),
            ),
          ))
        else if (_comunicados.isEmpty)
          const EmptyState(
            icon: Icons.markunread_mailbox_outlined,
            title: 'No hay comunicados',
            subtitle: 'Los comunicados apareceran aqui cuando sean publicados',
          )
        else
          ..._comunicados.map((c) => _comunicadoItem(c)),
      ],
    );
  }

  Widget _comunicadoItem(ComunicadoModel c) {
    final theme = Theme.of(context);
    final isUrgente = c.tipo == 'URGENTE';
    return GlassCard(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(
              color: isUrgente ? theme.colorScheme.errorContainer : theme.colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              isUrgente ? Icons.warning_amber_rounded : Icons.campaign_rounded,
              color: isUrgente ? theme.colorScheme.error : theme.colorScheme.primary,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(c.titulo,
                        style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: theme.colorScheme.onSurface),
                        maxLines: 1, overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (isUrgente)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.errorContainer,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text('URGENTE',
                          style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: theme.colorScheme.onErrorContainer)),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(c.contenido,
                  maxLines: 2, overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 13, color: theme.colorScheme.onSurfaceVariant)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showProfile() {
    final u = ref.read(authProvider).user;
    showDialog(
      context: context,
      builder: (ctx) => Consumer(builder: (_, watch2, __) {
        final isDark = watch2.watch(themeProvider);
        return AlertDialog(
          title: const Text('Mi Perfil'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _profileField('Nombre', u?.nombreCompleto ?? '-'),
              _profileField('Correo', u?.correo ?? '-'),
              _profileField('Roles', u?.roles.join(', ') ?? '-'),
              if (u?.idInstitucion != null)
                _profileField('Institucion', u!.idInstitucion!),
              const Divider(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Modo oscuro',
                    style: TextStyle(color: Theme.of(ctx).colorScheme.onSurface)),
                  Switch(
                    value: isDark,
                    onChanged: (v) => watch2.read(themeProvider.notifier).setDark(v),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            FilledButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cerrar')),
          ],
        );
      }),
    );
  }

  Widget _profileField(String label, String value) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurfaceVariant)),
          const SizedBox(height: 2),
          Text(value, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: theme.colorScheme.onSurface)),
        ],
      ),
    );
  }
}
