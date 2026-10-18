import 'package:dio/dio.dart';

import '../config/api_config.dart';
import 'auth_service.dart';

class IaService {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: ApiConfig.baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 45),
    ),
  );

  final AuthService _authService = AuthService();

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
