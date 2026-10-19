import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:itca_tic_inventario/repositories/equipos_repository.dart';
import 'package:itca_tic_inventario/services/auth_service.dart';

class AuthFalso extends AuthService {
  AuthFalso(this.token);

  final String? token;

  @override
  Future<String?> obtenerToken() async => token;
}

class AdaptadorEquiposFalso implements HttpClientAdapter {
  int llamadas = 0;
  String? metodo;
  String? ruta;
  String? autorizacion;
  dynamic cuerpo;
  int codigoRespuesta = 200;
  dynamic respuesta = [];

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    llamadas++;
    metodo = options.method;
    ruta = options.path;
    autorizacion = options.headers['Authorization'] as String?;

    final bytes = <int>[];

    if (requestStream != null) {
      await for (final fragmento in requestStream) {
        bytes.addAll(fragmento);
      }
    }

    if (bytes.isNotEmpty) {
      cuerpo = jsonDecode(utf8.decode(bytes));
    }

    return ResponseBody.fromString(
      jsonEncode(respuesta),
      codigoRespuesta,
      headers: {
        Headers.contentTypeHeader: ['application/json'],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

Map<String, dynamic> equipoJson({
  int id = 1,
  String codigo = 'TIC-001',
  String nombre = 'Laptop Dell',
}) {
  return {
    'id': id,
    'codigo': codigo,
    'nombre': nombre,
    'categoria': 'Computadora',
    'estado': 'Disponible',
    'ubicacion': 'Laboratorio TIC',
  };
}

Map<String, dynamic> datosEquipo() {
  final datos = equipoJson();
  datos.remove('id');
  return datos;
}

EquiposRepository crearRepositorio(
  AdaptadorEquiposFalso adaptador, {
  String? token = 'jwt-de-prueba',
}) {
  final dio = Dio(BaseOptions(baseUrl: 'https://pruebas.example'));

  dio.httpClientAdapter = adaptador;

  return EquiposRepository(dio: dio, authService: AuthFalso(token));
}

void main() {
  group('Repositorio de equipos con HTTP simulado', () {
    test('Lista los equipos recibidos desde FastAPI', () async {
      final adaptador = AdaptadorEquiposFalso();
      adaptador.respuesta = [
        equipoJson(),
        equipoJson(id: 2, codigo: 'TIC-002', nombre: 'Impresora HP'),
      ];

      final repositorio = crearRepositorio(adaptador);
      final equipos = await repositorio.listar();

      expect(equipos.length, 2);
      expect(equipos.first.codigo, 'TIC-001');
      expect(equipos.last.nombre, 'Impresora HP');
      expect(adaptador.metodo, 'GET');
      expect(Uri.parse(adaptador.ruta!).path, '/equipos/');
      expect(adaptador.autorizacion, 'Bearer jwt-de-prueba');
    });

    test('Devuelve lista vacía cuando no hay equipos', () async {
      final adaptador = AdaptadorEquiposFalso();
      final repositorio = crearRepositorio(adaptador);

      final equipos = await repositorio.listar();

      expect(equipos, isEmpty);
      expect(adaptador.llamadas, 1);
    });

    test('Envía correctamente la creación de un equipo', () async {
      final adaptador = AdaptadorEquiposFalso()
        ..codigoRespuesta = 201
        ..respuesta = equipoJson();

      final repositorio = crearRepositorio(adaptador);

      await repositorio.crear(datosEquipo());

      expect(adaptador.metodo, 'POST');
      expect(Uri.parse(adaptador.ruta!).path, '/equipos/');
      expect(adaptador.cuerpo['codigo'], 'TIC-001');
      expect(adaptador.cuerpo['nombre'], 'Laptop Dell');
      expect(adaptador.autorizacion, 'Bearer jwt-de-prueba');
    });

    test('Envía correctamente la actualización de un equipo', () async {
      final adaptador = AdaptadorEquiposFalso();
      final repositorio = crearRepositorio(adaptador);

      final datos = datosEquipo();
      datos['nombre'] = 'Laptop actualizada';

      await repositorio.actualizar(7, datos);

      expect(adaptador.metodo, 'PUT');
      expect(Uri.parse(adaptador.ruta!).path, '/equipos/7');
      expect(adaptador.cuerpo['nombre'], 'Laptop actualizada');
    });

    test('Envía correctamente la eliminación de un equipo', () async {
      final adaptador = AdaptadorEquiposFalso()..codigoRespuesta = 204;

      final repositorio = crearRepositorio(adaptador);

      await repositorio.eliminar(5);

      expect(adaptador.metodo, 'DELETE');
      expect(Uri.parse(adaptador.ruta!).path, '/equipos/5');
      expect(adaptador.autorizacion, 'Bearer jwt-de-prueba');
    });

    test('No realiza solicitudes sin token JWT', () async {
      final adaptador = AdaptadorEquiposFalso();
      final repositorio = crearRepositorio(adaptador, token: null);

      await expectLater(repositorio.listar(), throwsA(isA<StateError>()));

      expect(adaptador.llamadas, 0);
    });

    test('Propaga error HTTP 401 de autenticación', () async {
      final adaptador = AdaptadorEquiposFalso()
        ..codigoRespuesta = 401
        ..respuesta = {'detail': 'No autorizado'};

      final repositorio = crearRepositorio(adaptador);

      await expectLater(
        repositorio.listar(),
        throwsA(
          isA<DioException>().having(
            (e) => e.response?.statusCode,
            'estado HTTP',
            401,
          ),
        ),
      );
    });

    test('Propaga error HTTP 409 de código duplicado', () async {
      final adaptador = AdaptadorEquiposFalso()
        ..codigoRespuesta = 409
        ..respuesta = {'detail': 'Código duplicado'};

      final repositorio = crearRepositorio(adaptador);

      await expectLater(
        repositorio.crear(datosEquipo()),
        throwsA(
          isA<DioException>().having(
            (e) => e.response?.statusCode,
            'estado HTTP',
            409,
          ),
        ),
      );
    });
  });
}
