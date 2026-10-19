import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:itca_tic_inventario/services/auth_service.dart';
import 'package:itca_tic_inventario/services/favoritos_service.dart';

class AuthFalsoFavoritos extends AuthService {
  AuthFalsoFavoritos(this.token);

  final String? token;

  @override
  Future<String?> obtenerToken() async => token;
}

class AdaptadorUsuarioFalso implements HttpClientAdapter {
  AdaptadorUsuarioFalso(this.usuarioId);

  final int usuarioId;
  int llamadas = 0;
  String? autorizacion;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    llamadas++;
    autorizacion = options.headers['Authorization'] as String?;

    return ResponseBody.fromString(
      jsonEncode({'id': usuarioId}),
      200,
      headers: {
        Headers.contentTypeHeader: ['application/json'],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  late Directory directorioTemporal;
  late AdaptadorUsuarioFalso adaptador;
  late FavoritosService servicio;

  setUp(() async {
    directorioTemporal = await Directory.systemTemp.createTemp(
      'itca_hive_test_',
    );

    Hive.init(directorioTemporal.path);

    adaptador = AdaptadorUsuarioFalso(1001);

    final dio = Dio(BaseOptions(baseUrl: 'https://pruebas.example'));
    dio.httpClientAdapter = adaptador;

    servicio = FavoritosService(
      dio: dio,
      authService: AuthFalsoFavoritos('jwt-de-prueba'),
    );
  });

  tearDown(() async {
    await Hive.close();
    if (await directorioTemporal.exists()) {
      await directorioTemporal.delete(recursive: true);
    }
  });

  group('Persistencia real de favoritos con Hive', () {
    test('Inicializa una lista vacía para un usuario nuevo', () async {
      final favoritos = await servicio.inicializar();

      expect(favoritos, isEmpty);
      expect(adaptador.llamadas, 1);
      expect(adaptador.autorizacion, 'Bearer jwt-de-prueba');
    });

    test('Agrega y recupera un favorito', () async {
      await servicio.inicializar();
      await servicio.agregar('TIC-001');

      expect(
        Hive.box<String>('favoritos_usuario_1001').get('TIC-001'),
        'TIC-001',
      );

      final guardados = await servicio.inicializar();
      expect(guardados, contains('TIC-001'));
    });

    test('Quita un favorito guardado', () async {
      await servicio.inicializar();
      await servicio.agregar('TIC-001');
      await servicio.quitar('TIC-001');

      final guardados = await servicio.inicializar();

      expect(guardados, isEmpty);
    });

    test('Conserva los favoritos después de reabrir la base', () async {
      await servicio.inicializar();
      await servicio.agregar('TIC-002');

      await Hive.box<String>('favoritos_usuario_1001').close();

      final guardados = await servicio.inicializar();

      expect(guardados, contains('TIC-002'));
    });

    test('No permite agregar favoritos sin inicializar', () async {
      await expectLater(
        servicio.agregar('TIC-001'),
        throwsA(isA<StateError>()),
      );
    });

    test('No permite quitar favoritos sin inicializar', () async {
      await expectLater(servicio.quitar('TIC-001'), throwsA(isA<StateError>()));
    });

    test('No inicializa favoritos cuando no existe sesión', () async {
      final servicioSinSesion = FavoritosService(
        authService: AuthFalsoFavoritos(null),
      );

      await expectLater(
        servicioSinSesion.inicializar(),
        throwsA(isA<StateError>()),
      );
    });
  });
}
