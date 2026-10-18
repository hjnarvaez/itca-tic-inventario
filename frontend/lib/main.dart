import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'controllers/auth_controller.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  Get.put(AuthController(), permanent: true);
  runApp(const InventarioApp());
}

class InventarioApp extends StatelessWidget {
  const InventarioApp({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Get.find<AuthController>();

    return GetMaterialApp(
      title: 'ITCA TIC Inventario',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF146C94)),
        useMaterial3: true,
      ),
      home: Obx(() {
        if (auth.verificando.value) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        return auth.autenticado.value
            ? const HomeScreen()
            : const LoginScreen();
      }),
    );
  }
}
