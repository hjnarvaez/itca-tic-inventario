import 'package:flutter_test/flutter_test.dart';
import 'package:itca_tic_inventario/controllers/equipos_controller.dart';

import 'equipos_controller_test.dart'
    show RepositorioEquiposFalso, FavoritosFalso;

void main() {
  group('Favoritos de inventario', () {
    test('Carga los favoritos guardados', () async {
      final favoritos = FavoritosFalso();
      favoritos.codigos.add('TIC-001');

      final controller = EquiposController(
        repository: RepositorioEquiposFalso(),
        favoritosService: favoritos,
      );

      await controller.iniciar();

      expect(controller.esFavorito('TIC-001'), isTrue);
      expect(controller.esFavorito('TIC-002'), isFalse);
    });

    test('Agrega un equipo a favoritos', () async {
      final favoritos = FavoritosFalso();

      final controller = EquiposController(
        repository: RepositorioEquiposFalso(),
        favoritosService: favoritos,
      );

      await controller.cambiarFavorito('TIC-001');

      expect(controller.esFavorito('TIC-001'), isTrue);
      expect(favoritos.codigos, contains('TIC-001'));
      expect(controller.error.value, isEmpty);
    });

    test('Quita un equipo de favoritos', () async {
      final favoritos = FavoritosFalso();
      favoritos.codigos.add('TIC-001');

      final controller = EquiposController(
        repository: RepositorioEquiposFalso(),
        favoritosService: favoritos,
      );

      await controller.iniciar();
      await controller.cambiarFavorito('TIC-001');

      expect(controller.esFavorito('TIC-001'), isFalse);
      expect(favoritos.codigos, isEmpty);
    });

    test('Activa y desactiva el filtro de favoritos', () {
      final controller = EquiposController(
        repository: RepositorioEquiposFalso(),
        favoritosService: FavoritosFalso(),
      );

      expect(controller.soloFavoritos.value, isFalse);

      controller.alternarFiltro();
      expect(controller.soloFavoritos.value, isTrue);

      controller.alternarFiltro();
      expect(controller.soloFavoritos.value, isFalse);
    });
  });
}
