// lib/core/services/firebase_service.dart
//
// Inicializa Firebase y configura FCM (Firebase Cloud Messaging).
// Llamado una sola vez en main.dart antes de runApp().

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

import '../../firebase_options.dart';

/// Manejador de mensajes en segundo plano (debe ser función top-level)
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  debugPrint('[FCM Background] Mensaje recibido: ${message.messageId}');
}

class FirebaseService {
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  /// Inicializa Firebase y FCM. Retorna el FCM token del dispositivo (puede ser null).
  static Future<String?> initialize() async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    // Registrar manejador de mensajes en background
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // Pedir permisos de notificaciones (iOS y Android 13+)
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.denied) {
      debugPrint('[FCM] Permisos denegados por el usuario');
      return null;
    }

    // Manejadores de mensajes en primer plano
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint(
        '[FCM Foreground] ${message.notification?.title}: ${message.notification?.body}',
      );
      // TODO Sprint 3: mostrar SnackBar / banner in-app
    });

    // App abierta desde notificación (app en background)
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint('[FCM Opened] ${message.data}');
      // TODO Sprint 3: navegar a pantalla relevante según message.data
    });

    // App fría abierta desde notificación
    final initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null) {
      debugPrint('[FCM Initial] ${initialMessage.data}');
    }

    // Obtener y retornar el FCM token
    final token = await _messaging.getToken();
    debugPrint('[FCM] Token: $token');
    return token;
  }

  /// Obtiene el FCM token actual del dispositivo.
  static Future<String?> getToken() => _messaging.getToken();

  /// Suscribe el dispositivo a un topic (ej: "institucion-{id}")
  static Future<void> suscribirATopic(String topic) =>
      _messaging.subscribeToTopic(topic);

  /// Desuscribe el dispositivo de un topic
  static Future<void> desuscribirDeTopic(String topic) =>
      _messaging.unsubscribeFromTopic(topic);
}
