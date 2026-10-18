import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:itca_tic_inventario/controllers/ia_controller.dart';
import 'package:itca_tic_inventario/services/ia_service.dart';

class IaServiceFalso extends IaService {
  String? ultimaPregunta;
  String respuestaSimulada = 'Hay 20 equipos registrados.';
  Object? errorSimulado;
  int llamadas = 0;

  @override
  Future<String> preguntar(String pregunta) async {
    llamadas++;
    ultimaPregunta = pregunta;

    if (errorSimulado != null) {
      throw errorSimulado!;
    }

    return respuestaSimulada;
  }
}

DioException errorHttp(int codigo) {
  final request = RequestOptions(path: '/ia/preguntar');

  return DioException(
    requestOptions: request,
    response: Response(requestOptions: request, statusCode: codigo),
    type: DioExceptionType.badResponse,
  );
}

void main() {
  group('Controlador del asistente IA', () {
    test('Procesa correctamente la respuesta de Gemini', () async {
      final servicio = IaServiceFalso();
      final controller = IaController(service: servicio);

      await controller.preguntar('¿Cuántos equipos tengo?');

      expect(servicio.llamadas, 1);
      expect(servicio.ultimaPregunta, '¿Cuántos equipos tengo?');
      expect(controller.respuesta.value, 'Hay 20 equipos registrados.');
      expect(controller.error.value, isEmpty);
      expect(controller.cargando.value, isFalse);
    });

    test('No envía preguntas vacías', () async {
      final servicio = IaServiceFalso();
      final controller = IaController(service: servicio);

      await controller.preguntar('   ');

      expect(servicio.llamadas, 0);
      expect(controller.respuesta.value, isEmpty);
    });

    test('Elimina espacios al inicio y final', () async {
      final servicio = IaServiceFalso();
      final controller = IaController(service: servicio);

      await controller.preguntar('  Resume mi inventario  ');

      expect(servicio.ultimaPregunta, 'Resume mi inventario');
    });

    test('Muestra error cuando el JWT es inválido', () async {
      final servicio = IaServiceFalso();
      servicio.errorSimulado = errorHttp(401);

      final controller = IaController(service: servicio);
      await controller.preguntar('Resume mis equipos');

      expect(controller.error.value, contains('sesión'));
      expect(controller.cargando.value, isFalse);
    });

    test('Muestra error cuando Gemini no está disponible', () async {
      final servicio = IaServiceFalso();
      servicio.errorSimulado = errorHttp(503);

      final controller = IaController(service: servicio);
      await controller.preguntar('Resume mis equipos');

      expect(controller.error.value, contains('no está disponible'));
      expect(controller.cargando.value, isFalse);
    });
  });
}
