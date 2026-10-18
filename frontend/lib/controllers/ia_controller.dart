import 'package:dio/dio.dart';
import 'package:get/get.dart';

import '../services/ia_service.dart';

class IaController extends GetxController {
  //final IaService _service = IaService();
  IaController({IaService? service}) : _service = service ?? IaService();

  final IaService _service;

  final cargando = false.obs;
  final respuesta = ''.obs;
  final error = ''.obs;

  Future<void> preguntar(String pregunta) async {
    final texto = pregunta.trim();

    if (texto.isEmpty || cargando.value) return;

    cargando.value = true;
    respuesta.value = '';
    error.value = '';

    try {
      respuesta.value = await _service.preguntar(texto);
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        error.value = 'Tu sesión ha caducado. Inicia sesión nuevamente.';
      } else if (e.response?.statusCode == 503) {
        error.value = 'El servicio de IA no está disponible. Intenta de nuevo.';
      } else {
        error.value = 'No se pudo conectar con el asistente.';
      }
    } catch (_) {
      error.value = 'No se pudo procesar la pregunta.';
    } finally {
      cargando.value = false;
    }
  }
}
