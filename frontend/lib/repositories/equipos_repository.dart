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

  Future<Options> _autorizacion() async {
    final token = await _auth.obtenerToken();
    if (token == null) {
      throw StateError('Sesión no disponible');
    }
    return Options(headers: {'Authorization': 'Bearer $token'});
  }

  Future<List<Equipo>> listar() async {
    final response = await _dio.get(
      '/equipos/',
      options: await _autorizacion(),
    );

    return (response.data as List)
        .map((e) => Equipo.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> crear(Map<String, dynamic> datos) async {
    await _dio.post('/equipos/', data: datos, options: await _autorizacion());
  }

  Future<void> actualizar(int id, Map<String, dynamic> datos) async {
    await _dio.put('/equipos/$id', data: datos, options: await _autorizacion());
  }

  Future<void> eliminar(int id) async {
    await _dio.delete('/equipos/$id', options: await _autorizacion());
  }
}
