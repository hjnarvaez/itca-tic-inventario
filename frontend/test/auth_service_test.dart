import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:itca_tic_inventario/services/auth_service.dart';

class AdaptadorAuthFalso implements HttpClientAdapter {
  int llamadas = 0;
  String? metodo;
  String? ruta;
  String? autorizacion;
  String? username;
  String? password;
  int codigoRespuesta = 200;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    llamadas++;
    metodo = options.method;
    ruta = Uri.parse(options.path).path;
    autorizacion = options.headers['Authorization'] as String?;

    final bytes = <int>[];

    if (requestStream != null) {
      await for (final fragmento in requestStream) {
        bytes.addAll(fragmento);
      }
    }

    if (bytes.isNotEmpty && ruta == '/usuarios/token') {
      final parametros = Uri.splitQueryString(utf8.decode(bytes));
      username = parametros['username'];
      password = parametros['password'];
    }

    final respuesta = ruta == '/usuarios/token'
        ? {'access_token': 'jwt-simulado'}
        : {'id': 1, 'email': 'test@itca.edu.ec'};

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

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const storage = FlutterSecureStorage();

  late AdaptadorAuthFalso adaptador;
  late AuthService servicio;

  setUp(() async {
    FlutterSecureStorage.setMockInitialValues({});

    adaptador = AdaptadorAuthFalso();

    final dio = Dio(BaseOptions(baseUrl: 'https://pruebas.example'));

    dio.httpClientAdapter = adaptador;

    servicio = AuthService(dio: dio, storage: storage);
  });

  group('Servicio de autenticación', () {
    test('Login almacena correctamente el token JWT', () async {
      await servicio.login('test@itca.edu.ec', 'ClaveSegura123');

      expect(adaptador.metodo, 'POST');
      expect(adaptador.ruta, '/usuarios/token');
      expect(adaptador.username, 'test@itca.edu.ec');
      expect(adaptador.password, 'ClaveSegura123');
      expect(await servicio.obtenerToken(), 'jwt-simulado');
    });

    test('Login incorrecto devuelve error HTTP 401', () async {
      adaptador.codigoRespuesta = 401;

      await expectLater(
        servicio.login('test@itca.edu.ec', 'incorrecta'),
        throwsA(
          isA<DioException>().having(
            (e) => e.response?.statusCode,
            'HTTP',
            401,
          ),
        ),
      );

      expect(await servicio.obtenerToken(), isNull);
    });

    test('Recupera una sesión válida', () async {
      await storage.write(key: 'access_token', value: 'jwt-valido');

      final resultado = await servicio.restaurarSesion();

      expect(resultado, isTrue);
      expect(adaptador.metodo, 'GET');
      expect(adaptador.ruta, '/usuarios/me');
      expect(adaptador.autorizacion, 'Bearer jwt-valido');
    });

    test('Detecta una sesión expirada', () async {
      await storage.write(key: 'access_token', value: 'jwt-expirado');

      adaptador.codigoRespuesta = 401;

      expect(await servicio.restaurarSesion(), isFalse);
    });

    test('No consulta el backend sin token', () async {
      expect(await servicio.restaurarSesion(), isFalse);
      expect(adaptador.llamadas, 0);
    });

    test('Obtiene el token almacenado', () async {
      await storage.write(key: 'access_token', value: 'token-existente');

      expect(await servicio.obtenerToken(), 'token-existente');
    });

    test('Logout elimina el token', () async {
      await storage.write(key: 'access_token', value: 'jwt-valido');

      await servicio.logout();

      expect(await servicio.obtenerToken(), isNull);
    });
  });
}
