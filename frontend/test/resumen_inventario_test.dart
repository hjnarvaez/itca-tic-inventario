import 'package:flutter_test/flutter_test.dart';
import 'package:itca_tic_inventario/models/equipo.dart';
import 'package:itca_tic_inventario/models/resumen_inventario.dart';

Equipo crearEquipo({
  required int id,
  required String estado,
  String categoria = 'Computadora',
  String ubicacion = 'Laboratorio TIC',
}) {
  return Equipo(
    id: id,
    codigo: 'TIC-$id',
    nombre: 'Equipo $id',
    categoria: categoria,
    estado: estado,
    ubicacion: ubicacion,
  );
}

void main() {
  group('Resumen estadístico del inventario', () {
    test('Muestra valores cero cuando no hay equipos', () {
      final resumen = ResumenInventario.desdeEquipos([]);

      expect(resumen.total, 0);
      expect(resumen.disponibles, 0);
      expect(resumen.mantenimiento, 0);
      expect(resumen.porCategoria, isEmpty);
      expect(resumen.porcentajeEstado('Disponible'), 0);
    });

    test('Calcula correctamente los estados', () {
      final equipos = [
        crearEquipo(id: 1, estado: 'Disponible'),
        crearEquipo(id: 2, estado: 'Disponible'),
        crearEquipo(id: 3, estado: 'Asignado'),
        crearEquipo(id: 4, estado: 'Mantenimiento'),
        crearEquipo(id: 5, estado: 'Baja'),
      ];

      final resumen = ResumenInventario.desdeEquipos(equipos);

      expect(resumen.total, 5);
      expect(resumen.disponibles, 2);
      expect(resumen.asignados, 1);
      expect(resumen.mantenimiento, 1);
      expect(resumen.bajas, 1);
    });

    test('Agrupa equipos por categoría y ubicación', () {
      final equipos = [
        crearEquipo(id: 1, estado: 'Disponible'),
        crearEquipo(id: 2, estado: 'Asignado'),
        crearEquipo(
          id: 3,
          estado: 'Mantenimiento',
          categoria: 'Impresora',
          ubicacion: 'Administración',
        ),
      ];

      final resumen = ResumenInventario.desdeEquipos(equipos);

      expect(resumen.porCategoria['Computadora'], 2);
      expect(resumen.porCategoria['Impresora'], 1);
      expect(resumen.porUbicacion['Laboratorio TIC'], 2);
      expect(resumen.porUbicacion['Administración'], 1);
    });

    test('Calcula porcentajes por estado', () {
      final equipos = [
        crearEquipo(id: 1, estado: 'Disponible'),
        crearEquipo(id: 2, estado: 'Disponible'),
        crearEquipo(id: 3, estado: 'Disponible'),
        crearEquipo(id: 4, estado: 'Mantenimiento'),
      ];

      final resumen = ResumenInventario.desdeEquipos(equipos);

      expect(resumen.porcentajeEstado('Disponible'), 75);
      expect(resumen.porcentajeEstado('Mantenimiento'), 25);
      expect(resumen.porcentajeEstado('Baja'), 0);
    });
  });
}
