class ApiConfig {
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.0.2.2:2026',
  );

  // Auth
  static const String login = '/api/auth/login';
  static String perfil = '/api/usuarios/mi-perfil';
  static String cambiarContrasena = '/api/usuarios/cambiar-contrasena';

  // Estudiante
  static String historial(String id) => '/api/estudiantes/$id/historial';
  static String asistencia(String id) => '/api/estudiantes/$id/asistencia';
  static String comunicados = '/api/comunicados/publicados';
  static String notificaciones = '/api/notificaciones/mis-notificaciones';
  static String notificacionesCount = '/api/notificaciones/contar-no-leidas';

  // Tutor
  static String tutorEstudiante(String id) => '/api/tutores/$id/estudiante';
}
