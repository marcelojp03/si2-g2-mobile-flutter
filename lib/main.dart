import 'package:flutter/material.dart';

import 'core/services/api_service.dart';
import 'core/services/firebase_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializar Firebase y obtener FCM token
  final fcmToken = await FirebaseService.initialize();

  // Si hay sesion activa, registrar FCM token en backend
  if (fcmToken != null) {
    final apiService = ApiService();
    final jwt = await apiService.getToken();
    if (jwt != null) {
      await apiService.registrarFcmToken(fcmToken);
    }
  }

  runApp(const SiaApp());
}

class SiaApp extends StatelessWidget {
  const SiaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SIA - UAGRM',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1A5276),
        ),
        useMaterial3: true,
      ),
      home: const Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.school, size: 80, color: Color(0xFF1A5276)),
              SizedBox(height: 16),
              Text(
                'Sistema de Gestion Academica',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text('UAGRM - SI2 Grupo 2', style: TextStyle(color: Colors.grey)),
            ],
          ),
        ),
      ),
    );
  }
}
