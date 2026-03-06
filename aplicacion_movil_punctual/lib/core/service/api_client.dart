import 'dart:convert';

import 'package:aplicacion_movil_punctual/config/api_base_url.dart';
import 'package:aplicacion_movil_punctual/config/guardar_token.dart';
import 'package:http/http.dart' as http;

class ApiException implements Exception {
  final int statusCode;
  final String message;

  const ApiException(this.statusCode, this.message);

  @override
  String toString() => 'ApiException($statusCode): $message';
}

class ApiClient {
  final http.Client _httpClient;

  ApiClient({http.Client? httpClient}) : _httpClient = httpClient ?? http.Client();

  Future<Map<String, dynamic>> get(String path) async {
    final response = await _httpClient.get(
      _buildUri(path),
      headers: await _headers(),
    );
    return _parseMap(response);
  }

  Future<Map<String, dynamic>> post(String path, {Map<String, dynamic>? body}) async {
    final response = await _httpClient.post(
      _buildUri(path),
      headers: await _headers(),
      body: jsonEncode(body ?? <String, dynamic>{}),
    );
    return _parseMap(response);
  }

  Uri _buildUri(String path) {
    final base = ApiBaseUrl.value.endsWith('/') ? ApiBaseUrl.value.substring(0, ApiBaseUrl.value.length - 1) : ApiBaseUrl.value;
    final route = path.startsWith('/') ? path : '/$path';
    return Uri.parse('$base$route');
  }

  Future<Map<String, String>> _headers() async {
    final token = await GuardarToken.getToken();
    return {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    };
  }

  Map<String, dynamic> _parseMap(http.Response response) {
    final dynamic decoded;
    if (response.body.isEmpty) {
      decoded = <String, dynamic>{};
    } else {
      try {
        decoded = jsonDecode(response.body);
      } on FormatException {
        if (response.statusCode >= 200 && response.statusCode < 300) {
          throw const ApiException(502, 'Respuesta inválida del servidor');
        }

        final message = _toUserSafeMessage('Error de servidor', response.statusCode);
        throw ApiException(response.statusCode, message);
      }
    }

    if (response.statusCode < 200 || response.statusCode >= 300) {
      final rawMessage = decoded is Map<String, dynamic>
          ? (decoded['message']?.toString() ?? 'Error de servidor')
          : 'Error de servidor';
      final message = _toUserSafeMessage(rawMessage, response.statusCode);
      throw ApiException(response.statusCode, message);
    }

    if (decoded is Map<String, dynamic>) {
      return decoded;
    }

    throw const ApiException(500, 'Respuesta inválida del servidor');
  }

  String _toUserSafeMessage(String rawMessage, int statusCode) {
    final normalized = rawMessage.toLowerCase();

    const sensitiveMarkers = [
      'sqlstate',
      'connection refused',
      'denegó expresamente',
      'pdoexception',
      'queryexception',
      'stack trace',
      'select * from',
    ];

    final hasSensitiveContent = sensitiveMarkers.any(normalized.contains);

    if (hasSensitiveContent || statusCode >= 500) {
      return 'El servidor no está disponible temporalmente. Inténtalo de nuevo en unos minutos.';
    }

    return rawMessage;
  }
}
