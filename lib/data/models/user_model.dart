class UserModel {
  final String id;
  final String correo;
  final String nombres;
  final String apellidos;
  final List<String> roles;
  final String? idInstitucion;
  final String? idEstudiante;
  final String? idTutor;

  UserModel({
    required this.id,
    required this.correo,
    required this.nombres,
    required this.apellidos,
    required this.roles,
    this.idInstitucion,
    this.idEstudiante,
    this.idTutor,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? '',
      correo: json['correo'] ?? '',
      nombres: json['nombres'] ?? '',
      apellidos: json['apellidos'] ?? '',
      roles: List<String>.from(json['roles'] ?? []),
      idInstitucion: json['idInstitucion'],
      idEstudiante: json['idEstudiante'],
      idTutor: json['idTutor'],
    );
  }

  String get nombreCompleto => '$nombres $apellidos';
  bool get esEstudiante => roles.contains('ESTUDIANTE');
  bool get esTutor => roles.contains('TUTOR');
  bool get esDocente => roles.contains('DOCENTE');
}
