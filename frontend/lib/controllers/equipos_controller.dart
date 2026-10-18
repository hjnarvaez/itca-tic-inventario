import 'package:dio/dio.dart';
import 'package:get/get.dart';

import '../models/equipo.dart';
import '../repositories/equipos_repository.dart';

class EquiposController extends GetxController {
  final EquiposRepository _repository = EquiposRepository();

  final equipos = <Equipo>[].obs;
  final cargando = false.obs;
  final guardando = false.obs;
  final error = ''.obs;

  @override
  void onInit() {
    super.onInit();
    cargarEquipos();
  }

  String mensajeError(Object e) {
    if (e is DioException) {
      if (e.response?.statusCode == 401) {
        return 'Sesión expirada. Inicia sesión nuevamente.';
      }
      if (e.response?.statusCode == 409) {
        return 'Ya existe un equipo con ese código.';
      }
      if (e.response?.statusCode == 404) {
        return 'Equipo no encontrado.';
      }
      if (e.response?.statusCode == 422) {
        return 'Verifica los datos ingresados.';
      }
      if (e.response == null) {
        return 'No se pudo conectar con el servidor.';
      }
    }
    return 'No se pudo completar la operación.';
  }

  Future<void> cargarEquipos() async {
    cargando.value = true;
    error.value = '';
    try {
      equipos.assignAll(await _repository.listar());
    } catch (e) {
      equipos.clear();
      error.value = mensajeError(e);
    } finally {
      cargando.value = false;
    }
  }

  Future<String?> guardar(Map<String, dynamic> datos, {int? id}) async {
    guardando.value = true;
    try {
      if (id == null) {
        await _repository.crear(datos);
      } else {
        await _repository.actualizar(id, datos);
      }
      await cargarEquipos();
      return null;
    } catch (e) {
      return mensajeError(e);
    } finally {
      guardando.value = false;
    }
  }

  Future<String?> eliminarEquipo(int id) async {
    guardando.value = true;
    try {
      await _repository.eliminar(id);
      await cargarEquipos();
      return null;
    } catch (e) {
      return mensajeError(e);
    } finally {
      guardando.value = false;
    }
  }
}
