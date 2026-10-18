import 'package:dio/dio.dart';

import '../config/api_config.dart';
import '../models/equipo.dart';
import '../services/auth_service.dart';

class EquiposRepository {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: ApiConfig.baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    ),
  );

  final AuthService _auth = AuthService();

  Future<List<Equipo>> listar() async {
    final token = await _auth.obtenerToken();

    if (token == null) {
      throw StateError('Sesión no disponible');
    }

    final response = await _dio.get(
      '/equipos/',
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );

    final datos = response.data as List<dynamic>;

    return datos
        .map((item) => Equipo.fromJson(item as Map<String, dynamic>))
        .toList();
  }
}
