import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../config/api_config.dart';

class AuthService {
  AuthService({Dio? dio, FlutterSecureStorage? storage})
    : _dio =
          dio ??
          Dio(
            BaseOptions(
              baseUrl: ApiConfig.baseUrl,
              connectTimeout: const Duration(seconds: 10),
              receiveTimeout: const Duration(seconds: 10),
            ),
          ),
      _storage = storage ?? const FlutterSecureStorage();

  final Dio _dio;
  final FlutterSecureStorage _storage;

  Future<void> login(String email, String password) async {
    final response = await _dio.post(
      '/usuarios/token',
      data: {'username': email, 'password': password},
      options: Options(contentType: Headers.formUrlEncodedContentType),
    );

    final token = response.data['access_token'] as String;

    await _storage.write(key: 'access_token', value: token);
  }

  Future<bool> restaurarSesion() async {
    final token = await obtenerToken();

    if (token == null) {
      return false;
    }

    try {
      await _dio.get(
        '/usuarios/me',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      return true;
    } on DioException {
      return false;
    }
  }

  Future<String?> obtenerToken() {
    return _storage.read(key: 'access_token');
  }

  Future<void> logout() {
    return _storage.delete(key: 'access_token');
  }
}
