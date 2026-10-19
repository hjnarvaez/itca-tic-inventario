import 'package:flutter/foundation.dart';

class ApiConfig {
  static const String _configuredBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
  );

  static String get baseUrl => resolveApiBaseUrl(
    configuredBaseUrl: _configuredBaseUrl,
    isDebug: kDebugMode,
  );
}

String resolveApiBaseUrl({
  required String configuredBaseUrl,
  required bool isDebug,
}) {
  const debugDefaultBaseUrl = 'http://10.0.2.2:8001';
  final candidate = configuredBaseUrl.trim().isEmpty
      ? (isDebug ? debugDefaultBaseUrl : '')
      : configuredBaseUrl.trim();

  if (candidate.isEmpty) {
    throw StateError(
      'API_BASE_URL es obligatoria y debe usar HTTPS fuera de debug.',
    );
  }

  final uri = Uri.tryParse(candidate);
  if (uri == null || !uri.isAbsolute || !uri.hasAuthority || uri.host.isEmpty) {
    throw StateError('API_BASE_URL no es una URL absoluta válida.');
  }

  if (uri.userInfo.isNotEmpty) {
    throw StateError('API_BASE_URL no debe incluir credenciales.');
  }

  if (uri.hasFragment) {
    throw StateError('API_BASE_URL no debe incluir fragmentos.');
  }

  final scheme = uri.scheme.toLowerCase();
  if (isDebug) {
    if (scheme != 'http' && scheme != 'https') {
      throw StateError('API_BASE_URL debe usar HTTP o HTTPS en debug.');
    }
  } else if (scheme != 'https') {
    throw StateError('API_BASE_URL debe usar HTTPS fuera de debug.');
  }

  try {
    final port = uri.port;
    if (uri.hasPort && (port < 1 || port > 65535)) {
      throw const FormatException();
    }
  } on FormatException {
    throw StateError('API_BASE_URL contiene un puerto inválido.');
  }

  return candidate;
}
