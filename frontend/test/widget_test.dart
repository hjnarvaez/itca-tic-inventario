import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:itca_tic_inventario/screens/login_screen.dart';
import 'package:itca_tic_inventario/controllers/auth_controller.dart';

void main() {
  setUp(() {
    Get.testMode = true;
    Get.put(AuthController());
  });

  tearDown(() async {
    Get.reset();
  });

  testWidgets('La pantalla muestra los campos de login', (tester) async {
    await tester.pumpWidget(const GetMaterialApp(home: LoginScreen()));

    expect(find.text('ITCA TIC Inventario'), findsOneWidget);
    expect(find.text('Correo electrónico'), findsOneWidget);
    expect(find.text('Contraseña'), findsOneWidget);
    expect(find.text('Iniciar sesión'), findsOneWidget);

    expect(find.byType(TextFormField), findsNWidgets(2));
  });
}
