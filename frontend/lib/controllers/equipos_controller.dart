import '../services/favoritos_service.dart';

import 'package:dio/dio.dart';
import 'package:get/get.dart';

import '../models/equipo.dart';
import '../models/filtro_inventario.dart';
import '../repositories/equipos_repository.dart';

class EquiposController extends GetxController {
  EquiposController({
    EquiposRepository? repository,
    FavoritosService? favoritosService,
  }) : _repository = repository ?? EquiposRepository(),
       _favoritosService = favoritosService ?? FavoritosService();

  final EquiposRepository _repository;
  final FavoritosService _favoritosService;

  final favoritos = <String>[].obs;
  final soloFavoritos = false.obs;
  final busqueda = ''.obs;
  final estadoSeleccionado = 'Todos'.obs;
  final categoriaSeleccionada = 'Todas'.obs;

  static const estadosDisponibles = [
    'Todos',
    'Disponible',
    'Asignado',
    'Mantenimiento',
    'Baja',
  ];

  List<String> get categoriasDisponibles {
    final categorias = equipos
        .map((equipo) => equipo.categoria.trim())
        .where((categoria) => categoria.isNotEmpty)
        .toSet()
        .toList();
    categorias.sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
    return categorias;
  }

  List<Equipo> get equiposVisibles {
    return FiltroInventario(
      texto: busqueda.value,
      estado: estadoSeleccionado.value == 'Todos'
          ? null
          : estadoSeleccionado.value,
      categoria: categoriaSeleccionada.value == 'Todas'
          ? null
          : categoriaSeleccionada.value,
      soloFavoritos: soloFavoritos.value,
    ).aplicar(equipos, esFavorito: esFavorito);
  }

  bool get hayFiltrosActivos {
    return busqueda.value.trim().isNotEmpty ||
        estadoSeleccionado.value != 'Todos' ||
        categoriaSeleccionada.value != 'Todas' ||
        soloFavoritos.value;
  }

  void actualizarBusqueda(String valor) {
    busqueda.value = valor;
  }

  void seleccionarEstado(String estado) {
    estadoSeleccionado.value = estado;
  }

  void seleccionarCategoria(String categoria) {
    categoriaSeleccionada.value = categoria;
  }

  void limpiarFiltros() {
    busqueda.value = '';
    estadoSeleccionado.value = 'Todos';
    categoriaSeleccionada.value = 'Todas';
    soloFavoritos.value = false;
  }

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
