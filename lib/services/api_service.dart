import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/api_response.dart';

class ApiService {
  // Configuración de URLs
  static const String baseUrl = 'http://10.0.2.2:3000'; // Para emulador Android
  // static const String baseUrl = 'http://localhost:3000'; // Para web y iOS
  // static const String baseUrl = 'https://783df38e9ffd.ngrok-free.app'; // Para ngrok - Backend con imágenes
  static const String apiVersion = '/api';
  
  static String get fullUrl => '$baseUrl$apiVersion';
  
  // Headers por defecto
  static Map<String, String> get defaultHeaders => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    // 'ngrok-skip-browser-warning': 'true', // Para evitar warnings de ngrok
  };
  
  // Headers con autenticación
  static Map<String, String> authHeaders(String token) => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    'Authorization': 'Bearer $token',
  };
  
  // Headers para ngrok (evita warning) - NO USAR con localhost
  // static Map<String, String> get ngrokHeaders => {
  //   'Content-Type': 'application/json',
  //   'Accept': 'application/json',
  //   'ngrok-skip-browser-warning': 'true',
  // };

  /// Maneja errores de red y conexión
  static ApiResponse<T> _handleNetworkError<T>() {
    return ApiResponse<T>(
      status: 'error',
      message: 'Error de conexión. Verifica tu conexión a internet.',
    );
  }

  /// Maneja errores de respuesta HTTP
  static ApiResponse<T> _handleHttpError<T>(int statusCode, Map<String, dynamic> responseData) {
    String message = 'Error en la petición';
    String? code;

    switch (statusCode) {
      case 400:
        message = responseData['message'] ?? 'Datos de validación inválidos';
        code = responseData['code'];
        break;
      case 401:
        message = responseData['message'] ?? 'Credenciales inválidas';
        code = 'INVALID_CREDENTIALS';
        break;
      case 403:
        message = responseData['message'] ?? 'Cuenta no verificada';
        code = 'ACCOUNT_NOT_VERIFIED';
        break;
      case 404:
        message = responseData['message'] ?? 'Usuario no encontrado';
        code = 'USER_NOT_FOUND';
        break;
      case 409:
        message = responseData['message'] ?? 'Usuario ya existe';
        code = 'USER_EXISTS';
        break;
      case 429:
        message = responseData['message'] ?? 'Demasiados intentos. Intenta más tarde';
        code = 'RATE_LIMIT_EXCEEDED';
        break;
      case 500:
        message = 'Error interno del servidor';
        code = 'INTERNAL_SERVER_ERROR';
        break;
      default:
        message = responseData['message'] ?? 'Error desconocido';
        code = responseData['code'];
    }

    return ApiResponse<T>(
      status: 'error',
      message: message,
      code: code,
      errors: responseData['errors'],
    );
  }

  /// Obtiene restaurantes con paginación y filtros
  static Future<ApiResponse<Map<String, dynamic>>> getRestaurants({
    int page = 1,
    int pageSize = 10,
    String? category,
    String? search,
    double? latitude,
    double? longitude,
  }) async {
    try {
      String endpoint = '/restaurants?page=$page&pageSize=$pageSize';
      if (category != null) endpoint += '&category=$category';
      if (search != null && search.isNotEmpty) endpoint += '&search=$search';
      
      // Agregar coordenadas si están disponibles (para ordenamiento por proximidad)
      if (latitude != null && longitude != null) {
        endpoint += '&lat=$latitude&lng=$longitude';
        debugPrint('🗺️ Enviando coordenadas para ordenamiento por proximidad: lat=$latitude, lng=$longitude');
      }
      
      final response = await makeRequest<Map<String, dynamic>>(
        'GET',
        endpoint,
        defaultHeaders,
        null,
        null,
      );
      
      return response;
    } catch (e) {
      return ApiResponse<Map<String, dynamic>>(
        status: 'error',
        message: 'Error al obtener restaurantes: ${e.toString()}',
      );
    }
  }

  /// Obtiene categorías disponibles
  static Future<ApiResponse<List<dynamic>>> getCategories() async {
    try {
      final response = await makeRequest<List<dynamic>>(
        'GET',
        '/categories',
        defaultHeaders,
        null,
        (data) => data as List<dynamic>,
      );
      
      return response;
    } catch (e) {
      return ApiResponse<List<dynamic>>(
        status: 'error',
        message: 'Error al obtener categorías: ${e.toString()}',
      );
    }
  }

  /// Obtiene detalles de un restaurante con su menú
  static Future<ApiResponse<Map<String, dynamic>>> getRestaurantDetail({
    required int restaurantId,
  }) async {
    try {
      final response = await makeRequest<Map<String, dynamic>>(
        'GET',
        '/restaurants/$restaurantId',
        defaultHeaders,
        null,
        null,
      );
      
      return response;
    } catch (e) {
      return ApiResponse<Map<String, dynamic>>(
        status: 'error',
        message: 'Error al obtener detalles del restaurante: ${e.toString()}',
      );
    }
  }

  /// Realiza una petición HTTP genérica
  static Future<ApiResponse<T>> makeRequest<T>(
    String method,
    String endpoint,
    Map<String, String> headers,
    Map<String, dynamic>? body,
    T Function(dynamic)? fromJson,
  ) async {
    try {
      final url = Uri.parse('$fullUrl$endpoint');
      http.Response response;

      switch (method.toUpperCase()) {
        case 'GET':
          response = await http.get(url, headers: headers);
          break;
        case 'POST':
          response = await http.post(
            url,
            headers: headers,
            body: body != null ? jsonEncode(body) : null,
          );
          break;
        case 'PUT':
          response = await http.put(
            url,
            headers: headers,
            body: body != null ? jsonEncode(body) : null,
          );
          break;
        case 'DELETE':
          response = await http.delete(
            url,
            headers: headers,
            body: body != null ? jsonEncode(body) : null,
          );
          break;
        case 'PATCH':
          response = await http.patch(
            url,
            headers: headers,
            body: body != null ? jsonEncode(body) : null,
          );
          break;
        default:
          throw Exception('Método HTTP no soportado: $method');
      }

      // Debug: Imprimir respuesta del servidor (solo en desarrollo)
      print('=== RESPUESTA DEL SERVIDOR ===');
      print('URL: $url');
      print('Method: $method');
      print('Status Code: ${response.statusCode}');
      print('Response Headers: ${response.headers}');
      print('Response Body Raw: ${response.body}');
      print('==============================');

      Map<String, dynamic> responseData;
      try {
        responseData = jsonDecode(response.body);
        print('Response Body Parsed: $responseData');
      } catch (e) {
        print('❌ Error parsing JSON: $e');
        print('❌ Raw response body: ${response.body}');
        return ApiResponse<T>(
          status: 'error',
          message: 'Error en el formato de respuesta del servidor: ${e.toString()}',
        );
      }

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return ApiResponse.fromJson(responseData, fromJson);
      } else {
        return _handleHttpError<T>(response.statusCode, responseData);
      }
    } on SocketException {
      return _handleNetworkError<T>();
    } on http.ClientException {
      return _handleNetworkError<T>();
    } on FormatException {
      return ApiResponse<T>(
        status: 'error',
        message: 'Error en el formato de respuesta del servidor.',
      );
    } catch (e) {
      return ApiResponse<T>(
        status: 'error',
        message: 'Error inesperado: ${e.toString()}',
      );
    }
  }
}
