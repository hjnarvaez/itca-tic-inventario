import 'package:flutter_test/flutter_test.dart';
import 'package:itca_tic_inventario/models/equipo.dart';
import 'package:itca_tic_inventario/models/filtro_inventario.dart';

Equipo equipo({
  required int id,
  required String codigo,
  required String nombre,
  required String categoria,
  required String estado,
  required String ubicacion,
}) {
  return Equipo(
    id: id,
    codigo: codigo,
    nombre: nombre,
    categoria: categoria,
    estado: estado,
    ubicacion: ubicacion,
  );
}

void main() {
  final equipos = [
    equipo(
      id: 1,
      codigo: 'TIC-001',
      nombre: 'Portátil Ágil',
      categoria: 'Computadora',
      estado: 'Disponible',
      ubicacion: 'Administración',
    ),
    equipo(
      id: 2,
      codigo: 'RED-002',
      nombre: 'Router principal',
      categoria: 'Redes',
      estado: 'Asignado',
      ubicacion: 'Laboratorio Norte',
    ),
    equipo(
      id: 3,
      codigo: 'TIC-003',
      nombre: 'Impresora láser',
      categoria: 'Impresora',
      estado: 'Mantenimiento',
      ubicacion: 'Secretaría',
    ),
    equipo(
      id: 4,
      codigo: 'TIC-004',
      nombre: 'Portátil de respaldo',
      categoria: 'Computadora',
      estado: 'Baja',
      ubicacion: 'Laboratorio Sur',
    ),
  ];

  group('Filtro de inventario', () {
    test('busca por código, nombre o ubicación', () {
      expect(const FiltroInventario(texto: 'red-002').aplicar(equipos), [
        equipos[1],
      ]);
      expect(const FiltroInventario(texto: 'impresora').aplicar(equipos), [
        equipos[2],
      ]);
      expect(const FiltroInventario(texto: 'laboratorio').aplicar(equipos), [
        equipos[1],
        equipos[3],
      ]);
    });

    test('ignora mayúsculas, minúsculas y tildes', () {
      expect(const FiltroInventario(texto: 'PORTATIL AGIL').aplicar(equipos), [
        equipos[0],
      ]);
      expect(const FiltroInventario(texto: 'administracion').aplicar(equipos), [
        equipos[0],
      ]);
      expect(const FiltroInventario(texto: 'secretaria').aplicar(equipos), [
        equipos[2],
      ]);
    });

    test('filtra por estado y categoría', () {
      expect(const FiltroInventario(estado: 'Baja').aplicar(equipos), [
        equipos[3],
      ]);
      expect(
        const FiltroInventario(categoria: 'Computadora').aplicar(equipos),
        [equipos[0], equipos[3]],
      );
    });

    test('combina texto, estado y categoría', () {
      final resultado = const FiltroInventario(
        texto: 'laboratorio',
        estado: 'Baja',
        categoria: 'Computadora',
      ).aplicar(equipos);

      expect(resultado, [equipos[3]]);
    });

    test('combina favoritos con los demás filtros', () {
      final resultado = const FiltroInventario(
        texto: 'portatil',
        categoria: 'Computadora',
        soloFavoritos: true,
      ).aplicar(equipos, esFavorito: (codigo) => codigo == 'TIC-004');

      expect(resultado, [equipos[3]]);
    });

    test('devuelve una lista vacía cuando no hay coincidencias', () {
      expect(
        const FiltroInventario(texto: 'servidor').aplicar(equipos),
        isEmpty,
      );
    });
  });
}
