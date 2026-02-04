import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/api_response.dart';

/// Excepción personalizada para errores del repositorio
class AparcamientoException implements Exception {
  final String message;

  AparcamientoException(this.message);

  @override
  String toString() => 'AparcamientoException: $message';
}

/// Repositorio para gestionar las peticiones al API de aparcamientos de Valencia
class AparcamientoRepository {
  static const String baseUrl =
      'https://valencia.opendatasoft.com/api/explore/v2.1';
  static const String datasetId = 'aparcaments-bicicletes-aparcamientos-bicicletas';

  final http.Client _client;

  AparcamientoRepository({http.Client? client}) : _client = client ?? http.Client();

  /// Obtiene la lista de aparcamientos desde el API
  /// 
  /// [limit] - Número máximo de resultados a obtener (por defecto 100)
  /// [offset] - Desplazamiento para paginación (por defecto 0)
  Future<ApiResponse> getAparcamientos({int limit = 100, int offset = 0}) async {
    try {
      final uri = Uri.parse(
        '$baseUrl/catalog/datasets/$datasetId/records?limit=$limit&offset=$offset',
      );

      final response = await _client.get(uri);

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        return ApiResponse.fromJson(jsonData);
      } else {
        throw AparcamientoException(
          'Error al obtener los aparcamientos. Código: ${response.statusCode}',
        );
      }
    } catch (e) {
      if (e is AparcamientoException) {
        rethrow;
      }
      throw AparcamientoException('Error de conexión: ${e.toString()}');
    }
  }

  /// Cierra el cliente HTTP
  void dispose() {
    _client.close();
  }
}
