import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:itca_tic_inventario/controllers/equipos_controller.dart';
import 'package:itca_tic_inventario/models/equipo.dart';
import 'package:itca_tic_inventario/repositories/equipos_repository.dart';
import 'package:itca_tic_inventario/services/favoritos_service.dart';

class RepositorioEquiposFalso extends EquiposRepository {
  final registros = <Equipo>[];
  Object? errorSimulado;
  int llamadasListar = 0;
  int llamadasCrear = 0;
  int llamadasActualizar = 0;
  int llamadasEliminar = 0;

  void verificarError() {
    if (errorSimulado != null) {
      throw errorSimulado!;
    }
  }

  @override
  Future<List<Equipo>> listar() async {
    llamadasListar++;
    verificarError();
    return List.of(registros);
  }

  @override
  Future<void> crear(Map<String, dynamic> datos) async {
    llamadasCrear++;
    verificarError();

    registros.add(Equipo.fromJson({...datos, 'id': registros.length + 1}));
  }

  @override
  Future<void> actualizar(int id, Map<String, dynamic> datos) async {
    llamadasActualizar++;
    verificarError();

    final indice = registros.indexWhere((equipo) => equipo.id == id);
    if (indice < 0) {
      throw errorHttp(404);
    }

    registros[indice] = Equipo.fromJson({...datos, 'id': id});
  }

  @override
  Future<void> eliminar(int id) async {
    llamadasEliminar++;
    verificarError();
    registros.removeWhere((equipo) => equipo.id == id);
  }
}

class FavoritosFalso extends FavoritosService {
  final codigos = <String>[];

  @override
  Future<List<String>> inicializar() async {
    return List.of(codigos);
  }

  @override
  Future<void> agregar(String codigo) async {
    if (!codigos.contains(codigo)) {
      codigos.add(codigo);
    }
  }

  @override
  Future<void> quitar(String codigo) async {
    codigos.remove(codigo);
  }
}

DioException errorHttp(int codigo) {
  final request = RequestOptions(path: '/equipos/');

  return DioException(
    requestOptions: request,
    response: Response(requestOptions: request, statusCode: codigo),
    type: DioExceptionType.badResponse,
  );
}

Map<String, dynamic> datosEquipo({
  String codigo = 'TIC-001',
  String nombre = 'Laptop Dell',
}) {
  return {
    'codigo': codigo,
    'nombre': nombre,
    'categoria': 'Computadora',
    'estado': 'Disponible',
    'ubicacion': 'Laboratorio TIC',
  };
}

EquiposController crearControlador(
  RepositorioEquiposFalso repositorio,
  FavoritosFalso favoritos,
) {
  return EquiposController(
    repository: repositorio,
    favoritosService: favoritos,
  );
}

void main() {
  group('CRUD de equipos', () {
    test('Carga correctamente los equipos', () async {
      final repositorio = RepositorioEquiposFalso();
      final favoritos = FavoritosFalso();

      repositorio.registros.add(Equipo.fromJson({...datosEquipo(), 'id': 1}));

      final controller = crearControlador(repositorio, favoritos);

      await controller.iniciar();

      expect(controller.equipos.length, 1);
      expect(controller.equipos.first.codigo, 'TIC-001');
      expect(controller.error.value, isEmpty);
      expect(controller.cargando.value, isFalse);
    });

    test('Crea un equipo y actualiza el listado', () async {
      final repositorio = RepositorioEquiposFalso();
      final controller = crearControlador(repositorio, FavoritosFalso());

      final resultado = await controller.guardar(datosEquipo());

      expect(resultado, isNull);
      expect(repositorio.llamadasCrear, 1);
      expect(controller.equipos.length, 1);
      expect(controller.equipos.first.nombre, 'Laptop Dell');
      expect(controller.guardando.value, isFalse);
    });

    test('Actualiza un equipo existente', () async {
      final repositorio = RepositorioEquiposFalso();
      repositorio.registros.add(Equipo.fromJson({...datosEquipo(), 'id': 1}));

      final controller = crearControlador(repositorio, FavoritosFalso());

      final resultado = await controller.guardar(
        datosEquipo(nombre: 'Laptop actualizada'),
        id: 1,
      );

      expect(resultado, isNull);
      expect(repositorio.llamadasActualizar, 1);
      expect(controller.equipos.first.nombre, 'Laptop actualizada');
    });

    test('Elimina correctamente un equipo', () async {
      final repositorio = RepositorioEquiposFalso();
      repositorio.registros.add(Equipo.fromJson({...datosEquipo(), 'id': 1}));

      final controller = crearControlador(repositorio, FavoritosFalso());

      final resultado = await controller.eliminarEquipo(1);

      expect(resultado, isNull);
      expect(repositorio.llamadasEliminar, 1);
      expect(controller.equipos, isEmpty);
    });

    test('Informa cuando el código está duplicado', () async {
      final repositorio = RepositorioEquiposFalso();
      repositorio.errorSimulado = errorHttp(409);

      final controller = crearControlador(repositorio, FavoritosFalso());

      final resultado = await controller.guardar(datosEquipo());

      expect(resultado, contains('Ya existe'));
      expect(controller.guardando.value, isFalse);
    });

    test('Muestra error cuando la sesión ha expirado', () async {
      final repositorio = RepositorioEquiposFalso();
      repositorio.errorSimulado = errorHttp(401);

      final controller = crearControlador(repositorio, FavoritosFalso());

      await controller.cargarEquipos();

      expect(controller.error.value, contains('Sesión expirada'));
      expect(controller.cargando.value, isFalse);
    });

    test('Informa cuando el equipo no existe', () async {
      final repositorio = RepositorioEquiposFalso();
      repositorio.errorSimulado = errorHttp(404);

      final controller = crearControlador(repositorio, FavoritosFalso());

      final resultado = await controller.eliminarEquipo(99);

      expect(resultado, contains('Equipo no encontrado'));
      expect(controller.guardando.value, isFalse);
    });

    test('Muestra error ante datos inválidos', () async {
      final repositorio = RepositorioEquiposFalso();
      repositorio.errorSimulado = errorHttp(422);

      final controller = crearControlador(repositorio, FavoritosFalso());

      final resultado = await controller.guardar(datosEquipo());

      expect(resultado, contains('Verifica los datos'));
    });
  });
}
