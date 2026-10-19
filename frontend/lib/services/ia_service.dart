import 'package:dio/dio.dart';

import '../config/api_config.dart';
import 'auth_service.dart';

class IaService {
  IaService({Dio? dio, AuthService? authService})
    : _dio =
          dio ??
          Dio(
            BaseOptions(
              baseUrl: ApiConfig.baseUrl,
              connectTimeout: const Duration(seconds: 10),
              receiveTimeout: const Duration(seconds: 45),
            ),
          ),
      _authService = authService ?? AuthService();

  final Dio _dio;
  final AuthService _authService;

  Future<String> preguntar(String pregunta) async {
    final token = await _authService.obtenerToken();

    if (token == null || token.isEmpty) {
      throw Exception('Tu sesión ha caducado. Inicia sesión nuevamente.');
    }

    final response = await _dio.post(
      '/ia/preguntar',
      data: {'pregunta': pregunta},
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );

    final datos = response.data as Map<String, dynamic>;
    return datos['respuesta'] as String;
  }
}
