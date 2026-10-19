import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:itca_tic_inventario/services/auth_service.dart';
import 'package:itca_tic_inventario/services/ia_service.dart';

class AuthServiceFalso extends AuthService {
  AuthServiceFalso(this.token);

  final String? token;

  @override
  Future<String?> obtenerToken() async => token;
}

class AdaptadorIaFalso implements HttpClientAdapter {
  int llamadas = 0;
  String? autorizacion;
  String? preguntaRecibida;
  int codigoRespuesta = 200;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    llamadas++;
    autorizacion = options.headers['Authorization'] as String?;

    final fragmentos = <int>[];

    if (requestStream != null) {
      await for (final fragmento in requestStream) {
        fragmentos.addAll(fragmento);
      }
    }

    final datos = jsonDecode(utf8.decode(fragmentos));
    preguntaRecibida = datos['pregunta'] as String;

    return ResponseBody.fromString(
      codigoRespuesta == 200
          ? jsonEncode({'respuesta': 'Hay 20 equipos registrados.'})
          : jsonEncode({'detail': 'Servicio temporalmente no disponible'}),
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
  group('Servicio IA con HTTP simulado', () {
    test('Envía la pregunta con JWT y recibe la respuesta', () async {
      final adaptador = AdaptadorIaFalso();
      final dio = Dio(BaseOptions(baseUrl: 'https://pruebas.example'));
      dio.httpClientAdapter = adaptador;

      final servicio = IaService(
        dio: dio,
        authService: AuthServiceFalso('token-de-prueba'),
      );

      final respuesta = await servicio.preguntar('Resume mi inventario');

      expect(respuesta, 'Hay 20 equipos registrados.');
      expect(adaptador.llamadas, 1);
      expect(adaptador.autorizacion, 'Bearer token-de-prueba');
      expect(adaptador.preguntaRecibida, 'Resume mi inventario');
    });

    test('Rechaza solicitudes sin token', () async {
      final adaptador = AdaptadorIaFalso();
      final dio = Dio(BaseOptions(baseUrl: 'https://pruebas.example'));
      dio.httpClientAdapter = adaptador;

      final servicio = IaService(dio: dio, authService: AuthServiceFalso(null));

      await expectLater(
        servicio.preguntar('Resume mi inventario'),
        throwsA(isA<Exception>()),
      );

      expect(adaptador.llamadas, 0);
    });

    test('Rechaza solicitudes con token vacío', () async {
      final adaptador = AdaptadorIaFalso();
      final dio = Dio(BaseOptions(baseUrl: 'https://pruebas.example'));
      dio.httpClientAdapter = adaptador;

      final servicio = IaService(dio: dio, authService: AuthServiceFalso(''));

      await expectLater(
        servicio.preguntar('Resume mi inventario'),
        throwsA(isA<Exception>()),
      );

      expect(adaptador.llamadas, 0);
    });

    test('Propaga errores HTTP del servicio', () async {
      final adaptador = AdaptadorIaFalso();
      adaptador.codigoRespuesta = 503;

      final dio = Dio(BaseOptions(baseUrl: 'https://pruebas.example'));
      dio.httpClientAdapter = adaptador;

      final servicio = IaService(
        dio: dio,
        authService: AuthServiceFalso('token-de-prueba'),
      );

      await expectLater(
        servicio.preguntar('Resume mi inventario'),
        throwsA(
          isA<DioException>().having(
            (e) => e.response?.statusCode,
            'código HTTP',
            503,
          ),
        ),
      );
    });
  });
}
