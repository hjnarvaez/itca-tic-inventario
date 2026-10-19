import 'package:flutter_test/flutter_test.dart';
import 'package:itca_tic_inventario/controllers/equipos_controller.dart';
import 'package:itca_tic_inventario/models/equipo.dart';

import 'equipos_controller_test.dart'
    show FavoritosFalso, RepositorioEquiposFalso;

Equipo crearEquipo({
  required int id,
  required String categoria,
  String estado = 'Disponible',
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
  group('Estado de los filtros de inventario', () {
    test('cambiar filtros no consulta nuevamente el backend', () async {
      final repositorio = RepositorioEquiposFalso();
      repositorio.registros.add(crearEquipo(id: 1, categoria: 'Computadora'));
      final controller = EquiposController(
        repository: repositorio,
        favoritosService: FavoritosFalso(),
      );

      await controller.cargarEquipos();
      final llamadasIniciales = repositorio.llamadasListar;

      controller.actualizarBusqueda('equipo');
      controller.seleccionarEstado('Disponible');
      controller.seleccionarCategoria('Computadora');
      controller.alternarFiltro();
      controller.limpiarFiltros();

      expect(repositorio.llamadasListar, llamadasIniciales);
    });

    test('mantiene los filtros al actualizar el inventario', () async {
      final repositorio = RepositorioEquiposFalso();
      repositorio.registros.add(crearEquipo(id: 1, categoria: 'Computadora'));
      final controller = EquiposController(
        repository: repositorio,
        favoritosService: FavoritosFalso(),
      );

      await controller.cargarEquipos();
      controller.actualizarBusqueda('laboratorio');
      controller.seleccionarEstado('Disponible');
      controller.seleccionarCategoria('Computadora');
      controller.alternarFiltro();

      repositorio.registros
        ..clear()
        ..add(crearEquipo(id: 2, categoria: 'Redes'));
      await controller.cargarEquipos();

      expect(controller.busqueda.value, 'laboratorio');
      expect(controller.estadoSeleccionado.value, 'Disponible');
      expect(controller.categoriaSeleccionada.value, 'Computadora');
      expect(controller.soloFavoritos.value, isTrue);
    });

    test(
      'actualiza y ordena las categorías según el inventario recibido',
      () async {
        final repositorio = RepositorioEquiposFalso();
        repositorio.registros.addAll([
          crearEquipo(id: 1, categoria: 'Redes'),
          crearEquipo(id: 2, categoria: 'Computadora'),
          crearEquipo(id: 3, categoria: 'Redes'),
        ]);
        final controller = EquiposController(
          repository: repositorio,
          favoritosService: FavoritosFalso(),
        );

        await controller.cargarEquipos();
        expect(controller.categoriasDisponibles, ['Computadora', 'Redes']);

        repositorio.registros
          ..clear()
          ..add(crearEquipo(id: 4, categoria: 'Impresora'));
        await controller.cargarEquipos();

        expect(controller.categoriasDisponibles, ['Impresora']);
      },
    );

    test('limpiar restablece búsqueda, selectores y favoritos', () {
      final controller = EquiposController(
        repository: RepositorioEquiposFalso(),
        favoritosService: FavoritosFalso(),
      );
      controller.actualizarBusqueda('router');
      controller.seleccionarEstado('Asignado');
      controller.seleccionarCategoria('Redes');
      controller.alternarFiltro();

      controller.limpiarFiltros();

      expect(controller.busqueda.value, isEmpty);
      expect(controller.estadoSeleccionado.value, 'Todos');
      expect(controller.categoriaSeleccionada.value, 'Todas');
      expect(controller.soloFavoritos.value, isFalse);
      expect(controller.hayFiltrosActivos, isFalse);
    });
  });
}
