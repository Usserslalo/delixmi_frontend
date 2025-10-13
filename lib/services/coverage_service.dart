import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/coverage_response.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';

/// Servicio para validación de cobertura de entrega
class CoverageService {
  /// Verifica si una dirección tiene cobertura de restaurantes
  /// 
  /// Parámetros:
  /// - [addressId]: ID de la dirección a verificar
  /// 
  /// Retorna:
  /// - [CoverageResponse] con información de cobertura
  /// 
  /// Lanza excepciones en caso de error de red o autenticación
  static Future<CoverageResponse> checkCoverageForAddress(int addressId) async {
    try {
      // Obtener token de autenticación
      final token = await AuthService.getToken();
      if (token == null) {
        throw Exception('Usuario no autenticado');
      }

      // Construir URL del endpoint
      final url = Uri.parse('${ApiService.fullUrl}/customer/check-coverage');

      // Preparar body de la petición
      final body = jsonEncode({
        'addressId': addressId,
      });

      // Realizar petición POST
      final response = await http.post(
        url,
        headers: ApiService.authHeaders(token),
        body: body,
      );

      // Debug: Imprimir respuesta del servidor (solo en desarrollo)
      // debugPrint('=== COVERAGE SERVICE ===');
      // debugPrint('URL: $url');
      // debugPrint('Status Code: ${response.statusCode}');
      // debugPrint('Response Body: ${response.body}');
      // debugPrint('========================');

      // Parsear respuesta JSON
      Map<String, dynamic> responseData;
      try {
        responseData = jsonDecode(response.body);
    } catch (e) {
        // debugPrint('❌ Error parsing coverage JSON: $e');
        throw Exception('Error en el formato de respuesta del servidor');
      }

      // Verificar código de estado HTTP
      if (response.statusCode >= 200 && response.statusCode < 300) {
        // Respuesta exitosa
        final coverageResponse = CoverageResponse.fromJson(responseData);
        // debugPrint('✅ Cobertura verificada: ${coverageResponse.data.hasCoverage}');
        return coverageResponse;
      } else if (response.statusCode == 404) {
        // Dirección no encontrada
        throw Exception('Dirección no encontrada o no pertenece al usuario');
      } else if (response.statusCode == 401) {
        // No autenticado
        throw Exception('Sesión expirada. Por favor, inicia sesión nuevamente');
      } else if (response.statusCode == 400) {
        // Datos inválidos
        final message = responseData['message'] ?? 'El ID de la dirección es requerido';
        throw Exception(message);
    } else {
        // Otro error
        final message = responseData['message'] ?? 'Error al verificar cobertura';
        throw Exception(message);
      }
    } on SocketException {
      throw Exception('Error de conexión. Verifica tu conexión a internet');
    } on http.ClientException {
      throw Exception('Error de conexión. Verifica tu conexión a internet');
    } catch (e) {
      // Re-lanzar excepciones conocidas
      if (e.toString().contains('Usuario no autenticado') ||
          e.toString().contains('Dirección no encontrada') ||
          e.toString().contains('Sesión expirada') ||
          e.toString().contains('Error de conexión')) {
        rethrow;
      }
      // Error inesperado
      // debugPrint('❌ Error inesperado en CoverageService: $e');
      throw Exception('Error al verificar cobertura: ${e.toString()}');
    }
  }
}
