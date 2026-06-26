import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../http/api_client.dart';

@pragma('vm:entry-point')
Future<void> _firebaseBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  final notification = message.notification;
  if (notification != null) {
    final localNotifications = FlutterLocalNotificationsPlugin();
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings();
    await localNotifications.initialize(const InitializationSettings(android: android, iOS: ios));
    await localNotifications.show(
      message.messageId.hashCode,
      notification.title,
      notification.body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'comunicados_channel',
          'Comunicados',
          channelDescription: 'Notificaciones de comunicados',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: DarwinNotificationDetails(),
      ),
      payload: message.data['id'],
    );
  }
}

class FcmService {
  static final FcmService _instance = FcmService._();
  factory FcmService() => _instance;
  FcmService._();

  final _localNotifications = FlutterLocalNotificationsPlugin();
  final _api = ApiClient();
  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;
    try {
      await Firebase.initializeApp();
      await _initLocalNotifications();
      FirebaseMessaging.onBackgroundMessage(_firebaseBackgroundHandler);
      await _requestPermission();
      await _registerExistingToken();
      _listenTokenRefresh();
      _listenForegroundMessages();
      _listenNotificationTaps();
      _checkInitialMessage();
      _initialized = true;
    } catch (e) {
      debugPrint('[FCM] init error: $e');
    }
  }

  Future<void> _initLocalNotifications() async {
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    await _localNotifications.initialize(
      const InitializationSettings(android: android, iOS: ios),
      onDidReceiveNotificationResponse: _onLocalNotificationTap,
    );
  }

  Future<void> _requestPermission() async {
    final messaging = FirebaseMessaging.instance;
    await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      announcement: true,
      criticalAlert: true,
    );
    if (Platform.isAndroid) {
      await _localNotifications.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()?.requestNotificationsPermission();
    }
  }

  Future<void> _registerExistingToken() async {
    try {
      final token = await FirebaseMessaging.instance.getToken();
      if (token != null) await _registerToken(token);
    } catch (_) {}
  }

  void _listenTokenRefresh() {
    FirebaseMessaging.instance.onTokenRefresh.listen((token) {
      _registerToken(token);
    });
  }

  void _listenForegroundMessages() {
    FirebaseMessaging.onMessage.listen((msg) {
      print('[FCM] onMessage recibido: ${msg.notification?.title} / ${msg.data}');
      _handleForegroundMessage(msg);
    });
  }

  void _listenNotificationTaps() {
    FirebaseMessaging.onMessageOpenedApp.listen((msg) {
      print('[FCM] onMessageOpenedApp: ${msg.notification?.title}');
      _handleNotificationTap(msg);
    });
  }

  Future<void> _checkInitialMessage() async {
    final message = await FirebaseMessaging.instance.getInitialMessage();
    if (message != null) {
      _handleNotificationTap(message);
    }
  }

  Future<void> registerCurrentToken() async {
    try {
      final token = await FirebaseMessaging.instance.getToken();
      if (token != null) _registerToken(token);
    } catch (_) {}
  }

  Future<void> _registerToken(String token) async {
    try {
      await _api.post('/notificaciones/fcm-token', body: {
        'fcmToken': token,
        'plataforma': Platform.isAndroid ? 'android' : 'ios',
      });
    } catch (_) {}
  }

  Future<void> _handleForegroundMessage(RemoteMessage message) async {
    print('[FCM] _handleForegroundMessage llamado');
    final notification = message.notification;
    if (notification == null) {
      print('[FCM] notification es null');
      return;
    }
    const channelId = 'comunicados_channel';
    const channelName = 'Comunicados';

    await _localNotifications.show(
      notification.hashCode,
      notification.title,
      notification.body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          channelId,
          channelName,
          channelDescription: 'Notificaciones de comunicados',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: const DarwinNotificationDetails(),
      ),
      payload: message.data['id'],
    );
  }

  void _handleNotificationTap(RemoteMessage message) {
    // Navigation handled by go_router if app is in context
  }

  void _onLocalNotificationTap(NotificationResponse response) {
    // Handle local notification tap (app in foreground)
    // e.g., navigate to notification detail using response.payload
  }
}
