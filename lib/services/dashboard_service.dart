import '../models/api_response.dart';
import '../models/restaurant.dart';
import '../models/category.dart';
import '../models/address.dart';
import 'api_service.dart';
import 'auth_service.dart';

/// Servicio para el endpoint de dashboard unificado
class DashboardService {
  /// Obtiene todos los datos necesarios para la HomeScreen en una sola llamada
  /// 
  /// Parámetros:
  /// - [latitude]: Latitud del usuario (opcional)
  /// - [longitude]: Longitud del usuario (opcional)
  /// - [addressId]: ID de la dirección seleccionada (opcional)
  /// 
  /// Retorna:
  /// - [ApiResponse<Map<String, dynamic>>] con todos los datos del dashboard
  static Future<ApiResponse<Map<String, dynamic>>> getDashboard({
    double? latitude,
    double? longitude,
    int? addressId,
  }) async {
    try {
      // Obtener token de autenticación
      final token = await AuthService.getToken();
      if (token == null) {
        throw Exception('Usuario no autenticado');
      }

      // Construir URL del endpoint con parámetros opcionales
      String endpoint = '/home/dashboard';
      List<String> params = [];
      
      if (latitude != null && longitude != null) {
        params.add('lat=$latitude');
        params.add('lng=$longitude');
      }
      
      if (addressId != null) {
        params.add('addressId=$addressId');
      }
      
      if (params.isNotEmpty) {
        endpoint += '?${params.join('&')}';
      }

      // Realizar petición GET
      final response = await ApiService.makeRequest<Map<String, dynamic>>(
        'GET',
        endpoint,
        ApiService.authHeaders(token),
        null,
        null,
      );

      return response;
    } catch (e) {
      return ApiResponse<Map<String, dynamic>>(
        status: 'error',
        message: 'Error al obtener dashboard: ${e.toString()}',
      );
    }
  }

  /// Verifica cobertura por coordenadas (endpoint optimizado)
  /// 
  /// Parámetros:
  /// - [latitude]: Latitud del usuario
  /// - [longitude]: Longitud del usuario
  /// 
  /// Retorna:
  /// - [ApiResponse<Map<String, dynamic>>] con información de cobertura
  static Future<ApiResponse<Map<String, dynamic>>> checkCoverageByCoordinates({
    required double latitude,
    required double longitude,
  }) async {
    try {
      // Obtener token de autenticación
      final token = await AuthService.getToken();
      if (token == null) {
        throw Exception('Usuario no autenticado');
      }

      // Construir URL del endpoint
      final endpoint = '/customer/check-coverage?lat=$latitude&lng=$longitude';

      // Realizar petición GET
      final response = await ApiService.makeRequest<Map<String, dynamic>>(
        'GET',
        endpoint,
        ApiService.authHeaders(token),
        null,
        null,
      );

      return response;
    } catch (e) {
      return ApiResponse<Map<String, dynamic>>(
        status: 'error',
        message: 'Error al verificar cobertura: ${e.toString()}',
      );
    }
  }

  /// Parsea la respuesta del dashboard y la convierte en objetos Dart
  static Map<String, dynamic> parseDashboardResponse(Map<String, dynamic> data) {
    try {
      final categories = (data['categories'] as List<dynamic>?)
          ?.map((json) => Category.fromJson(json))
          .toList() ?? [];

      final restaurants = (data['restaurants'] as List<dynamic>?)
          ?.map((json) => Restaurant.fromJson(json))
          .toList() ?? [];

      final addresses = (data['addresses'] as List<dynamic>?)
          ?.map((json) => Address.fromJson(json))
          .toList() ?? [];

      return {
        'categories': categories,
        'restaurants': restaurants,
        'addresses': addresses,
        'cartSummary': data['cartSummary'],
        'coverage': data['coverage'],
        'userLocation': data['userLocation'],
        'metadata': data['metadata'],
      };
    } catch (e) {
      throw Exception('Error al parsear respuesta del dashboard: ${e.toString()}');
    }
  }
}
