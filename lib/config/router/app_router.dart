import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/storage/storage_service.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/home/presentation/home_screen.dart';
import '../../features/cuotas/presentation/cuotas_screen.dart';
import '../../features/calificaciones/presentation/calificaciones_screen.dart';
import '../../features/asistencia/presentation/asistencia_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final storage = StorageService();
  return GoRouter(
    initialLocation: '/login',
    redirect: (context, state) async {
      final token = await storage.getToken();
      final loggedIn = token != null;
      final onLogin = state.matchedLocation == '/login';
      if (!loggedIn && !onLogin) return '/login';
      if (loggedIn && onLogin) return '/home';
      return null;
    },
    routes: [
      GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
      GoRoute(path: '/home', builder: (_, __) => const HomeScreen()),
      GoRoute(path: '/cuotas', builder: (_, __) => const CuotasScreen()),
      GoRoute(path: '/calificaciones', builder: (_, __) => const CalificacionesScreen()),
      GoRoute(path: '/asistencia', builder: (_, __) => const AsistenciaScreen()),
    ],
  );
});
