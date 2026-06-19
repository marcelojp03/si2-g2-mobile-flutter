class HistorialAcademico {
  final String idEstudiante;
  final String codigoEstudiante;
  final String nombres;
  final String apellidos;
  final List<HistorialGestion> gestiones;

  HistorialAcademico({
    required this.idEstudiante,
    required this.codigoEstudiante,
    required this.nombres,
    required this.apellidos,
    required this.gestiones,
  });

  factory HistorialAcademico.fromJson(Map<String, dynamic> json) {
    return HistorialAcademico(
      idEstudiante: json['idEstudiante']?.toString() ?? '',
      codigoEstudiante: json['codigoEstudiante'] ?? '',
      nombres: json['nombres'] ?? '',
      apellidos: json['apellidos'] ?? '',
      gestiones: (json['gestiones'] as List<dynamic>?)
              ?.map((e) => HistorialGestion.fromJson(e))
              .toList() ??
          [],
    );
  }
}

class HistorialGestion {
  final String idGestion;
  final String nombreGestion;
  final String idParalelo;
  final String nombreParalelo;
  final String idInscripcion;
  final String estadoInscripcion;
  final String? fechaInscripcion;
  final List<HistorialMateria> materias;

  HistorialGestion({
    required this.idGestion,
    required this.nombreGestion,
    required this.idParalelo,
    required this.nombreParalelo,
    required this.idInscripcion,
    required this.estadoInscripcion,
    this.fechaInscripcion,
    required this.materias,
  });

  factory HistorialGestion.fromJson(Map<String, dynamic> json) {
    return HistorialGestion(
      idGestion: json['idGestion']?.toString() ?? '',
      nombreGestion: json['nombreGestion'] ?? '',
      idParalelo: json['idParalelo']?.toString() ?? '',
      nombreParalelo: json['nombreParalelo'] ?? '',
      idInscripcion: json['idInscripcion']?.toString() ?? '',
      estadoInscripcion: json['estadoInscripcion'] ?? '',
      fechaInscripcion: json['fechaInscripcion'],
      materias: (json['materias'] as List<dynamic>?)
              ?.map((e) => HistorialMateria.fromJson(e))
              .toList() ??
          [],
    );
  }
}

class HistorialMateria {
  final String idMateria;
  final String codigoMateria;
  final String nombreMateria;
  final String idAsignacion;
  final double? promedioGeneral;
  final List<HistorialEvaluacion> evaluaciones;
  final int totalSesiones;
  final int sesionesPresente;
  final double? porcentajeAsistencia;

  HistorialMateria({
    required this.idMateria,
    required this.codigoMateria,
    required this.nombreMateria,
    required this.idAsignacion,
    this.promedioGeneral,
    required this.evaluaciones,
    this.totalSesiones = 0,
    this.sesionesPresente = 0,
    this.porcentajeAsistencia,
  });

  factory HistorialMateria.fromJson(Map<String, dynamic> json) {
    return HistorialMateria(
      idMateria: json['idMateria']?.toString() ?? '',
      codigoMateria: json['codigoMateria'] ?? '',
      nombreMateria: json['nombreMateria'] ?? '',
      idAsignacion: json['idAsignacion']?.toString() ?? '',
      promedioGeneral: (json['promedioGeneral'] as num?)?.toDouble(),
      evaluaciones: (json['evaluaciones'] as List<dynamic>?)
              ?.map((e) => HistorialEvaluacion.fromJson(e))
              .toList() ??
          [],
      totalSesiones: json['totalSesiones'] ?? 0,
      sesionesPresente: json['sesionesPresente'] ?? 0,
      porcentajeAsistencia: (json['porcentajeAsistencia'] as num?)?.toDouble(),
    );
  }
}

class HistorialEvaluacion {
  final String idEvaluacion;
  final String nombreEvaluacion;
  final double? nota;
  final double? puntajeMaximo;
  final String? tipoEvaluacion;
  final int? periodo;

  HistorialEvaluacion({
    required this.idEvaluacion,
    required this.nombreEvaluacion,
    this.nota,
    this.puntajeMaximo,
    this.tipoEvaluacion,
    this.periodo,
  });

  factory HistorialEvaluacion.fromJson(Map<String, dynamic> json) {
    return HistorialEvaluacion(
      idEvaluacion: json['idEvaluacion']?.toString() ?? '',
      nombreEvaluacion: json['nombreEvaluacion'] ?? '',
      nota: (json['nota'] as num?)?.toDouble(),
      puntajeMaximo: (json['puntajeMaximo'] as num?)?.toDouble(),
      tipoEvaluacion: json['tipoEvaluacion'],
      periodo: json['periodo'],
    );
  }
}
