import 'equipo.dart';

class ResumenInventario {
  final int total;
  final Map<String, int> porEstado;
  final Map<String, int> porCategoria;
  final Map<String, int> porUbicacion;

  const ResumenInventario._({
    required this.total,
    required this.porEstado,
    required this.porCategoria,
    required this.porUbicacion,
  });

  factory ResumenInventario.desdeEquipos(Iterable<Equipo> equipos) {
    final estados = <String, int>{};
    final categorias = <String, int>{};
    final ubicaciones = <String, int>{};
    var total = 0;

    for (final equipo in equipos) {
      total++;

      estados.update(
        equipo.estado,
        (cantidad) => cantidad + 1,
        ifAbsent: () => 1,
      );

      categorias.update(
        equipo.categoria,
        (cantidad) => cantidad + 1,
        ifAbsent: () => 1,
      );

      ubicaciones.update(
        equipo.ubicacion,
        (cantidad) => cantidad + 1,
        ifAbsent: () => 1,
      );
    }

    return ResumenInventario._(
      total: total,
      porEstado: Map.unmodifiable(estados),
      porCategoria: Map.unmodifiable(categorias),
      porUbicacion: Map.unmodifiable(ubicaciones),
    );
  }

  int get disponibles => porEstado['Disponible'] ?? 0;
  int get asignados => porEstado['Asignado'] ?? 0;
  int get mantenimiento => porEstado['Mantenimiento'] ?? 0;
  int get bajas => porEstado['Baja'] ?? 0;

  double porcentajeEstado(String estado) {
    if (total == 0) return 0;

    return (porEstado[estado] ?? 0) * 100 / total;
  }
}
