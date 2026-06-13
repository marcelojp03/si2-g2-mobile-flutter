import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'core/providers/auth_provider.dart';
import 'core/services/api_service.dart';
import 'core/services/firebase_service.dart';
import 'features/auth/login_screen.dart';
import 'features/auth/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final fcmToken = await FirebaseService.initialize();
  if (fcmToken != null) {
    final apiService = ApiService();
    final jwt = await apiService.getToken();
    if (jwt != null) {
      await apiService.registrarFcmToken(fcmToken);
    }
  }

  runApp(
    ChangeNotifierProvider(
      create: (_) => AuthProvider()..tryAutoLogin(),
      child: const SiaApp(),
    ),
  );
}

final _router = GoRouter(
  initialLocation: '/login',
  redirect: (context, state) {
    final auth = context.read<AuthProvider>();
    final loggedIn = auth.isLoggedIn;
    final onLogin = state.matchedLocation == '/login';
    if (!loggedIn && !onLogin) return '/login';
    if (loggedIn && onLogin) return '/home';
    return null;
  },
  routes: [
    GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
    GoRoute(path: '/home', builder: (_, __) => const HomeScreen()),
  ],
);

class SiaApp extends StatelessWidget {
  const SiaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'SIA - UAGRM',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1A5276), brightness: Brightness.light),
        useMaterial3: true,
      ),
      routerConfig: _router,
    );
  }
}
