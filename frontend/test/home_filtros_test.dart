import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:itca_tic_inventario/controllers/equipos_controller.dart';
import 'package:itca_tic_inventario/models/equipo.dart';
import 'package:itca_tic_inventario/screens/home_screen.dart';

import 'equipos_controller_test.dart'
    show FavoritosFalso, RepositorioEquiposFalso;

Equipo equipoInterfaz({
  required int id,
  required String nombre,
  required String categoria,
  required String estado,
  required String ubicacion,
}) {
  return Equipo(
    id: id,
    codigo: 'TIC-$id',
    nombre: nombre,
    categoria: categoria,
    estado: estado,
    ubicacion: ubicacion,
  );
}

EquiposController crearController() {
  return EquiposController(
    repository: RepositorioEquiposFalso(),
    favoritosService: FavoritosFalso(),
  );
}

Future<void> mostrarInventario(
  WidgetTester tester,
  EquiposController controller,
) async {
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(body: InventarioContenido(controller: controller)),
    ),
  );
}

void main() {
  testWidgets('busca sin distinguir mayúsculas ni tildes y limpia filtros', (
    tester,
  ) async {
    final controller = crearController();
    controller.equipos
      ..clear()
      ..addAll([
        equipoInterfaz(
          id: 1,
          nombre: 'Portátil administrativo',
          categoria: 'Computadora',
          estado: 'Disponible',
          ubicacion: 'Administración',
        ),
        equipoInterfaz(
          id: 2,
          nombre: 'Router principal',
          categoria: 'Redes',
          estado: 'Asignado',
          ubicacion: 'Centro de Datos',
        ),
      ]);
    await mostrarInventario(tester, controller);

    await tester.enterText(
      find.byKey(const Key('busqueda-equipos')),
      'ADMINISTRACION',
    );
    await tester.pump();

    expect(find.text('Portátil administrativo'), findsOneWidget);
    expect(find.text('Router principal'), findsNothing);
    expect(find.text('Equipos encontrados: 1'), findsOneWidget);

    await tester.tap(find.byKey(const Key('limpiar-filtros')));
    await tester.pump();

    expect(find.text('Portátil administrativo'), findsOneWidget);
    expect(find.text('Router principal'), findsOneWidget);
    expect(find.text('Equipos encontrados: 2'), findsOneWidget);
    expect(
      tester
          .widget<TextField>(find.byKey(const Key('busqueda-equipos')))
          .controller
          ?.text,
      isEmpty,
    );
  });

  testWidgets('permite combinar búsqueda y estado desde la interfaz', (
    tester,
  ) async {
    final controller = crearController();
    controller.equipos
      ..clear()
      ..addAll([
        equipoInterfaz(
          id: 1,
          nombre: 'Laptop norte',
          categoria: 'Computadora',
          estado: 'Disponible',
          ubicacion: 'Laboratorio Norte',
        ),
        equipoInterfaz(
          id: 2,
          nombre: 'Router norte',
          categoria: 'Redes',
          estado: 'Mantenimiento',
          ubicacion: 'Laboratorio Norte',
        ),
      ]);
    await mostrarInventario(tester, controller);

    await tester.enterText(find.byKey(const Key('busqueda-equipos')), 'norte');
    await tester.tap(find.byKey(const ValueKey('estado-Todos')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Mantenimiento').last);
    await tester.pumpAndSettle();

    expect(find.text('Laptop norte'), findsNothing);
    expect(find.text('Router norte'), findsOneWidget);
    expect(find.text('Equipos encontrados: 1'), findsOneWidget);
  });

  testWidgets(
    'diferencia los mensajes sin inventario, favoritos y resultados',
    (tester) async {
      final controller = crearController();
      await mostrarInventario(tester, controller);

      expect(find.text('No hay equipos registrados'), findsOneWidget);

      controller.equipos.add(
        equipoInterfaz(
          id: 1,
          nombre: 'Laptop',
          categoria: 'Computadora',
          estado: 'Disponible',
          ubicacion: 'Laboratorio',
        ),
      );
      controller.soloFavoritos.value = true;
      await tester.pump();
      expect(find.text('No tienes equipos favoritos'), findsOneWidget);

      controller.soloFavoritos.value = false;
      controller.actualizarBusqueda('sin coincidencias');
      await tester.pump();
      expect(
        find.text('No se encontraron equipos con los filtros seleccionados'),
        findsOneWidget,
      );
    },
  );

  testWidgets('se adapta a una pantalla estrecha sin desbordamientos', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 700);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final controller = crearController();
    controller.equipos.add(
      equipoInterfaz(
        id: 1,
        nombre: 'Laptop',
        categoria: 'Computadora',
        estado: 'Disponible',
        ubicacion: 'Laboratorio',
      ),
    );
    await mostrarInventario(tester, controller);

    expect(tester.takeException(), isNull);
    expect(find.text('Equipos encontrados: 1'), findsOneWidget);
  });
}
