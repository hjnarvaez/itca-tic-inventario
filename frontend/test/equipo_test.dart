import 'package:flutter_test/flutter_test.dart';
import 'package:itca_tic_inventario/models/equipo.dart';

void main() {
  group('Modelo Equipo', () {
    final json = <String, dynamic>{
      'id': 1,
      'codigo': 'TIC-001',
      'nombre': 'Laptop Dell',
      'categoria': 'Computadora',
      'estado': 'Disponible',
      'ubicacion': 'Laboratorio TIC',
    };

    test('Convierte JSON a un equipo', () {
      final equipo = Equipo.fromJson(json);

      expect(equipo.id, 1);
      expect(equipo.codigo, 'TIC-001');
      expect(equipo.nombre, 'Laptop Dell');
      expect(equipo.categoria, 'Computadora');
      expect(equipo.estado, 'Disponible');
      expect(equipo.ubicacion, 'Laboratorio TIC');
    });

    test('Conserva el estado de mantenimiento', () {
      final equipo = Equipo.fromJson({...json, 'estado': 'Mantenimiento'});

      expect(equipo.estado, 'Mantenimiento');
    });

    test('Detecta datos obligatorios ausentes', () {
      expect(() => Equipo.fromJson({'id': 1}), throwsA(isA<TypeError>()));
    });
  });
}
