import 'package:dio/dio.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../config/api_config.dart';
import 'auth_service.dart';

class FavoritosService {
  FavoritosService({Dio? dio, AuthService? authService})
    : _dio = dio ?? Dio(BaseOptions(baseUrl: ApiConfig.baseUrl)),
      _auth = authService ?? AuthService();

  final Dio _dio;
  final AuthService _auth;

  Box<String>? _box;

  Future<List<String>> inicializar() async {
    final token = await _auth.obtenerToken();

    if (token == null) {
      throw StateError('Sesión no disponible');
    }

    final response = await _dio.get(
      '/usuarios/me',
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );

    final usuarioId = response.data['id'] as int;

    _box = await Hive.openBox<String>('favoritos_usuario_$usuarioId');

    return _box!.values.toList();
  }

  Future<void> agregar(String codigo) async {
    final box = _box;
    if (box == null) {
      throw StateError('Favoritos no inicializados');
    }

    await box.put(codigo, codigo);
  }

  Future<void> quitar(String codigo) async {
    final box = _box;
    if (box == null) {
      throw StateError('Favoritos no inicializados');
    }

    await box.delete(codigo);
  }
}
