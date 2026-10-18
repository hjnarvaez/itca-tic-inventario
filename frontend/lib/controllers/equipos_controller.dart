import 'package:dio/dio.dart';
import 'package:get/get.dart';

import '../models/equipo.dart';
import '../repositories/equipos_repository.dart';

class EquiposController extends GetxController {
  final EquiposRepository _repository = EquiposRepository();

  final equipos = <Equipo>[].obs;
  final cargando = false.obs;
  final error = ''.obs;

  @override
  void onInit() {
    super.onInit();
    cargarEquipos();
  }

  Future<void> cargarEquipos() async {
    cargando.value = true;
    error.value = '';

    try {
      equipos.assignAll(await _repository.listar());
    } on DioException catch (e) {
      equipos.clear();

      if (e.response?.statusCode == 401) {
        error.value = 'Tu sesión expiró. Cierra sesión e ingresa nuevamente.';
      } else if (e.response?.statusCode == null) {
        error.value = 'No se pudo conectar con el servidor.';
      } else {
        error.value = 'No fue posible cargar el inventario.';
      }
    } catch (_) {
      equipos.clear();
      error.value = 'Ocurrió un error al cargar los equipos.';
    } finally {
      cargando.value = false;
    }
  }
}
