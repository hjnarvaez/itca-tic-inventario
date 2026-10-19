import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:itca_tic_inventario/models/equipo.dart';
import 'package:itca_tic_inventario/models/resumen_inventario.dart';
import 'package:itca_tic_inventario/screens/dashboard_screen.dart';

Equipo equipo({
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

Future<void> mostrarDashboard(WidgetTester tester, List<Equipo> equipos) async {
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: SingleChildScrollView(
          child: DashboardContenido(
            resumen: ResumenInventario.desdeEquipos(equipos),
          ),
        ),
      ),
    ),
  );
}

Future<void> mostrarDashboardEnPantallaEstrecha(
  WidgetTester tester,
  List<Equipo> equipos,
) async {
  tester.view.physicalSize = const Size(320, 568);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  await tester.pumpWidget(
    MaterialApp(
      home: MediaQuery(
        data: const MediaQueryData(textScaler: TextScaler.linear(2)),
        child: Scaffold(
          body: SingleChildScrollView(
            child: DashboardContenido(
              resumen: ResumenInventario.desdeEquipos(equipos),
            ),
          ),
        ),
      ),
    ),
  );
}

void main() {
  testWidgets('Muestra el inventario vacío', (tester) async {
    await mostrarDashboard(tester, []);

    expect(find.text('Total de activos'), findsOneWidget);
    expect(find.text('0 equipos registrados'), findsOneWidget);
    expect(find.text('Sin datos disponibles'), findsNWidgets(2));
  });

  testWidgets('Muestra estadísticas reales por estado', (tester) async {
    await mostrarDashboard(tester, [
      equipo(id: 1, estado: 'Disponible'),
      equipo(id: 2, estado: 'Disponible'),
      equipo(id: 3, estado: 'Mantenimiento'),
    ]);

    expect(find.text('3 equipos registrados'), findsOneWidget);
    expect(find.text('Disponibles'), findsOneWidget);
    expect(find.text('Mantenimiento'), findsOneWidget);
  });

  testWidgets('Muestra las categorías y ubicaciones', (tester) async {
    await mostrarDashboard(tester, [
      equipo(id: 1, estado: 'Disponible'),
      equipo(
        id: 2,
        estado: 'Asignado',
        categoria: 'Impresora',
        ubicacion: 'Administración',
      ),
    ]);

    expect(find.text('Equipos por categoría'), findsOneWidget);
    expect(find.text('Equipos por ubicación'), findsOneWidget);
    expect(find.text('Computadora'), findsOneWidget);
    expect(find.text('Impresora'), findsOneWidget);
    expect(find.text('Administración'), findsOneWidget);
  });

  testWidgets('No desborda en una pantalla estrecha con texto ampliado', (
    tester,
  ) async {
    await mostrarDashboardEnPantallaEstrecha(tester, [
      equipo(id: 1, estado: 'Disponible'),
      equipo(id: 2, estado: 'Asignado'),
      equipo(id: 3, estado: 'Mantenimiento'),
      equipo(id: 4, estado: 'Baja'),
    ]);

    expect(tester.takeException(), isNull);
  });
}
