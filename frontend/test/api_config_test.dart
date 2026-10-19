import 'package:flutter_test/flutter_test.dart';
import 'package:itca_tic_inventario/config/api_config.dart';

void main() {
  group('Configuración de API', () {
    test('debug usa por defecto el host HTTP del emulador', () {
      expect(
        resolveApiBaseUrl(configuredBaseUrl: '', isDebug: true),
        'http://10.0.2.2:8001',
      );
    });

    test('debug acepta una URL HTTP explícita', () {
      expect(
        resolveApiBaseUrl(
          configuredBaseUrl: 'http://192.0.2.10:8001',
          isDebug: true,
        ),
        'http://192.0.2.10:8001',
      );
    });

    test('debug acepta una URL HTTPS explícita', () {
      expect(
        resolveApiBaseUrl(
          configuredBaseUrl: 'https://inventario.example',
          isDebug: true,
        ),
        'https://inventario.example',
      );
    });

    test('profile y release exigen una URL explícita', () {
      expect(
        () => resolveApiBaseUrl(configuredBaseUrl: '', isDebug: false),
        throwsStateError,
      );
    });

    test('profile y release rechazan HTTP', () {
      expect(
        () => resolveApiBaseUrl(
          configuredBaseUrl: 'http://inventario.example',
          isDebug: false,
        ),
        throwsStateError,
      );
    });

    test('profile y release aceptan HTTPS', () {
      expect(
        resolveApiBaseUrl(
          configuredBaseUrl: 'https://inventario.example/api',
          isDebug: false,
        ),
        'https://inventario.example/api',
      );
    });

    test('rechaza esquemas no HTTP', () {
      expect(
        () => resolveApiBaseUrl(
          configuredBaseUrl: 'file:///tmp/inventario',
          isDebug: true,
        ),
        throwsStateError,
      );
    });

    test('rechaza URLs relativas o sin host', () {
      for (final value in ['/api', 'https://', 'inventario.example']) {
        expect(
          () => resolveApiBaseUrl(configuredBaseUrl: value, isDebug: true),
          throwsStateError,
          reason: value,
        );
      }
    });

    test('rechaza credenciales embebidas', () {
      expect(
        () => resolveApiBaseUrl(
          configuredBaseUrl: 'https://usuario:clave@inventario.example',
          isDebug: false,
        ),
        throwsStateError,
      );
    });

    test('rechaza fragmentos', () {
      expect(
        () => resolveApiBaseUrl(
          configuredBaseUrl: 'https://inventario.example/api#seccion',
          isDebug: false,
        ),
        throwsStateError,
      );
    });

    test('rechaza puertos inválidos', () {
      for (final value in [
        'https://inventario.example:invalido',
        'https://inventario.example:0',
        'https://inventario.example:65536',
      ]) {
        expect(
          () => resolveApiBaseUrl(configuredBaseUrl: value, isDebug: false),
          throwsStateError,
          reason: value,
        );
      }
    });
  });
}
