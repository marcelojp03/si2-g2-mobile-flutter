# SI2 G2 — App Móvil Flutter

[![Flutter](https://img.shields.io/badge/Flutter-3.x-54c5f8.svg)](https://flutter.dev/)
[![Dart](https://img.shields.io/badge/Dart-3.x-0553b1.svg)](https://dart.dev/)
[![Firebase](https://img.shields.io/badge/Firebase-FCM-FFCA28.svg)](https://firebase.google.com/)
[![Android](https://img.shields.io/badge/Android-APK-3DDC84.svg)](https://developer.android.com/)

App móvil del Sistema de Gestión Académica SaaS — UAGRM Sistemas de Información 2, Grupo 2.  
Orientada a estudiantes y tutores para consulta de asistencia, calificaciones y comunicados.

---

## Stack

| Capa | Tecnología |
|---|---|
| Framework | Flutter SDK ^3.x |
| Lenguaje | Dart 3 |
| HTTP | `http` + `dio` |
| Auth / Storage local | `shared_preferences`, `flutter_secure_storage`, `jwt_decoder` |
| Notificaciones push | Firebase Messaging (FCM) |
| UI | `google_fonts`, Material Design 3 |

---

## Requisitos previos

- Flutter SDK >= 3.x (`flutter --version`)
- Android Studio o VS Code con extensión Flutter
- JDK 17 (para build Android)
- Firebase project configurado (ver `google-services.json`)

---

## Levantar la app

```bash
cd si2-g2-mobile-flutter

# Instalar dependencias
flutter pub get

# Verificar entorno
flutter doctor

# Ejecutar en dispositivo/emulador conectado
flutter run

# Build APK de producción
flutter build apk --release
```

---

## Configuración

El archivo `lib/core/config/` contiene la URL base del backend:

```dart
// lib/core/config/app_config.dart
const String baseUrl = 'https://s7hwsnmsxf.us-east-1.awsapprunner.com';
```

Para desarrollo local cambiar a `http://10.0.2.2:2026` (emulador Android apunta a localhost del host).

Firebase: el archivo `google-services.json` va en `android/app/` (no incluido en el repo).

---

## Estructura del proyecto

```
lib/
├── main.dart                  — entrada + Firebase init
├── firebase_options.dart      — configuración generada por FlutterFire CLI
└── core/
    ├── config/                — URLs, constantes, configuración de entorno
    └── services/
        ├── api_service.dart   — cliente HTTP con JWT
        └── firebase_service.dart  — inicialización FCM y manejo de tokens
```

---

## Roles con acceso a la app

| Rol | Funcionalidades |
|---|---|
| `ESTUDIANTE` | Consulta de asistencia, calificaciones, horario y comunicados propios |
| `TUTOR` | Consulta de datos académicos del estudiante vinculado |

---

## Entornos

| Entorno | Backend URL |
|---|---|
| Local (emulador Android) | `http://10.0.2.2:2026` |
| Producción | `https://s7hwsnmsxf.us-east-1.awsapprunner.com` |
