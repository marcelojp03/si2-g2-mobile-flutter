import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/storage/storage_service.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/home/presentation/home_shell.dart';
import '../../features/home/presentation/home_screen.dart';
import '../../features/cuotas/presentation/cuotas_screen.dart';
import '../../features/calificaciones/presentation/calificaciones_screen.dart';
import '../../features/asistencia/presentation/asistencia_screen.dart';
import '../../shared/widgets/page_transition.dart';

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
      GoRoute(
        path: '/login',
        pageBuilder: (context, state) => buildPageTransition(
          const ValueKey('login'),
          const LoginScreen(),
        ),
      ),
      ShellRoute(
        builder: (_, __, child) => HomeShell(child: child),
        routes: [
          GoRoute(
            path: '/home',
            pageBuilder: (_, __) => buildPageTransition(
              const ValueKey('home'),
              const HomeScreen(),
            ),
          ),
          GoRoute(
            path: '/cuotas',
            pageBuilder: (_, __) => buildPageTransition(
              const ValueKey('cuotas'),
              const CuotasScreen(),
            ),
          ),
          GoRoute(
            path: '/calificaciones',
            pageBuilder: (_, __) => buildPageTransition(
              const ValueKey('calificaciones'),
              const CalificacionesScreen(),
            ),
          ),
          GoRoute(
            path: '/asistencia',
            pageBuilder: (_, __) => buildPageTransition(
              const ValueKey('asistencia'),
              const AsistenciaScreen(),
            ),
          ),
        ],
      ),
    ],
  );
});
