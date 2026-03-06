import 'package:aplicacion_movil_punctual/config/guardar_token.dart';
import 'package:aplicacion_movil_punctual/core/service/api_client.dart';

class AuthApiService {
  final ApiClient _apiClient;

  AuthApiService({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  Future<void> login({required String email, required String password}) async {
    final data = await _apiClient.post(
      '/auth/login',
      body: {
        'email': email,
        'password': password,
      },
    );

    final token = data['token']?.toString();
    if (token == null || token.isEmpty) {
      throw const ApiException(500, 'No se recibió token de autenticación.');
    }

    await GuardarToken.saveToken(token);
  }

  Future<void> logout() async {
    try {
      await _apiClient.post('/auth/logout');
    } catch (_) {
    } finally {
      await GuardarToken.clearToken();
    }
  }

  Future<bool> hasSession() async {
    final token = await GuardarToken.getToken();
    return token != null && token.isNotEmpty;
  }
}
