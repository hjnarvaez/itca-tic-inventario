class Equipo {
  final int id;
  final String codigo;
  final String nombre;
  final String categoria;
  final String estado;
  final String ubicacion;

  const Equipo({
    required this.id,
    required this.codigo,
    required this.nombre,
    required this.categoria,
    required this.estado,
    required this.ubicacion,
  });

  factory Equipo.fromJson(Map<String, dynamic> json) {
    return Equipo(
      id: json['id'] as int,
      codigo: json['codigo'] as String,
      nombre: json['nombre'] as String,
      categoria: json['categoria'] as String,
      estado: json['estado'] as String,
      ubicacion: json['ubicacion'] as String,
    );
  }
}
