import '../services/favoritos_service.dart';

import 'package:dio/dio.dart';
import 'package:get/get.dart';

import '../models/equipo.dart';
import '../repositories/equipos_repository.dart';

class EquiposController extends GetxController {
  final EquiposRepository _repository = EquiposRepository();

  final FavoritosService _favoritosService = FavoritosService();

  final favoritos = <String>[].obs;
  final soloFavoritos = false.obs;

  bool esFavorito(String codigo) {
    return favoritos.contains(codigo);
  }

  Future<void> cambiarFavorito(String codigo) async {
    try {
      if (esFavorito(codigo)) {
        await _favoritosService.quitar(codigo);
        favoritos.remove(codigo);
      } else {
        await _favoritosService.agregar(codigo);
        favoritos.add(codigo);
      }
      error.value = '';
    } catch (_) {
      error.value = 'No se pudo guardar el favorito.';
    }
  }

  void alternarFiltro() {
    soloFavoritos.value = !soloFavoritos.value;
  }

  final equipos = <Equipo>[].obs;
  final cargando = false.obs;
  final guardando = false.obs;
  final error = ''.obs;

  @override
  @override
  void onInit() {
    super.onInit();
    iniciar();
  }

  Future<void> iniciar() async {
    cargando.value = true;

    try {
      favoritos.assignAll(await _favoritosService.inicializar());
    } catch (_) {
      error.value = 'No se pudieron cargar los favoritos.';
    }

    await cargarEquipos();
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
