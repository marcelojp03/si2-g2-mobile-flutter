class Materia {
  final String id;
  final String nombre;
  final String area;
  final String? ciclo;

  Materia({required this.id, required this.nombre, required this.area, this.ciclo});

  factory Materia.fromJson(Map<String, dynamic> json) {
    return Materia(id: json['id'] ?? '', nombre: json['nombre'] ?? '', area: json['area'] ?? '', ciclo: json['ciclo']);
  }
}
