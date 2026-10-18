import 'package:dio/dio.dart';
import 'package:get/get.dart';

import '../services/auth_service.dart';

class AuthController extends GetxController {
  final AuthService _auth = AuthService();

  final cargando = false.obs;
  final verificando = true.obs;
  final autenticado = false.obs;
  final mensajeError = ''.obs;

  @override
  void onInit() {
    super.onInit();
    verificarSesion();
  }

  Future<void> verificarSesion() async {
    verificando.value = true;
    try {
      autenticado.value = await _auth.restaurarSesion();
      if (!autenticado.value) {
        await _auth.logout();
      }
    } catch (_) {
      autenticado.value = false;
    } finally {
      verificando.value = false;
    }
  }

  Future<void> login(String email, String password) async {
    cargando.value = true;
    mensajeError.value = '';

    try {
      await _auth.login(email.trim(), password);
      autenticado.value = true;
    } on DioException catch (e) {
      if (e.response?.statusCode == 400 || e.response?.statusCode == 401) {
        mensajeError.value = 'Correo o contraseña incorrectos.';
      } else if (e.response?.statusCode == null) {
        mensajeError.value = 'No se pudo conectar al servidor.';
      } else {
        mensajeError.value = 'Error al iniciar sesión.';
      }
    } catch (_) {
      mensajeError.value = 'No se pudo iniciar sesión.';
    } finally {
      cargando.value = false;
    }
  }

  Future<void> logout() async {
    await _auth.logout();
    autenticado.value = false;
    mensajeError.value = '';
  }
}
