import '../models/api_response.dart';
import 'api_service.dart';
import 'token_manager.dart';
import 'logger_service.dart';

class OrderService {
  /// Obtener historial de pedidos del usuario
  static Future<ApiResponse<Map<String, dynamic>>> getOrdersHistory({
    int page = 1,
    int pageSize = 20,
    String? status,
  }) async {
    try {
      LoggerService.location('Obteniendo historial de pedidos - Página: $page', tag: 'OrderService');
      
      String endpoint = '/customer/orders?page=$page&pageSize=$pageSize';
      if (status != null && status.isNotEmpty) {
        endpoint += '&status=$status';
      }
      
      final response = await ApiService.makeRequest<Map<String, dynamic>>(
        'GET',
        endpoint,
        ApiService.authHeaders(await TokenManager.getToken() ?? ''),
        null,
        (data) => data as Map<String, dynamic>,
      );

      LoggerService.location('Respuesta de historial: ${response.status}', tag: 'OrderService');
      return response;
    } catch (e) {
      LoggerService.error('Error al obtener historial de pedidos: $e', tag: 'OrderService');
      return ApiResponse<Map<String, dynamic>>(
        status: 'error',
        message: 'Error al obtener historial de pedidos: $e',
        data: null,
      );
    }
  }

  /// Obtener detalles de un pedido específico
  static Future<ApiResponse<Map<String, dynamic>>> getOrderDetails({
    required String orderId,
  }) async {
    try {
      LoggerService.location('Obteniendo detalles del pedido: $orderId', tag: 'OrderService');
      
      final response = await ApiService.makeRequest<Map<String, dynamic>>(
        'GET',
        '/customer/orders/$orderId',
        ApiService.authHeaders(await TokenManager.getToken() ?? ''),
        null,
        (data) => data as Map<String, dynamic>,
      );

      LoggerService.location('Respuesta de detalles: ${response.status}', tag: 'OrderService');
      return response;
    } catch (e) {
      LoggerService.error('Error al obtener detalles del pedido: $e', tag: 'OrderService');
      return ApiResponse<Map<String, dynamic>>(
        status: 'error',
        message: 'Error al obtener detalles del pedido: $e',
        data: null,
      );
    }
  }

  /// Obtener ubicación del repartidor
  static Future<ApiResponse<Map<String, dynamic>>> getOrderLocation({
    required String orderId,
  }) async {
    try {
      LoggerService.location('Obteniendo ubicación del pedido: $orderId', tag: 'OrderService');
      
      final response = await ApiService.makeRequest<Map<String, dynamic>>(
        'GET',
        '/customer/orders/$orderId/location',
        ApiService.authHeaders(await TokenManager.getToken() ?? ''),
        null,
        (data) => data as Map<String, dynamic>,
      );

      LoggerService.location('Respuesta de ubicación: ${response.status}', tag: 'OrderService');
      return response;
    } catch (e) {
      LoggerService.error('Error al obtener ubicación del pedido: $e', tag: 'OrderService');
      return ApiResponse<Map<String, dynamic>>(
        status: 'error',
        message: 'Error al obtener ubicación del pedido: $e',
        data: null,
      );
    }
  }

  /// Cancelar un pedido
  static Future<ApiResponse<Map<String, dynamic>>> cancelOrder({
    required String orderId,
    String? reason,
  }) async {
    try {
      LoggerService.location('Cancelando pedido: $orderId', tag: 'OrderService');
      
      final response = await ApiService.makeRequest<Map<String, dynamic>>(
        'POST',
        '/customer/orders/$orderId/cancel',
        ApiService.authHeaders(await TokenManager.getToken() ?? ''),
        {
          if (reason != null) 'reason': reason,
        },
        (data) => data as Map<String, dynamic>,
      );

      LoggerService.location('Respuesta de cancelación: ${response.status}', tag: 'OrderService');
      return response;
    } catch (e) {
      LoggerService.error('Error al cancelar pedido: $e', tag: 'OrderService');
      return ApiResponse<Map<String, dynamic>>(
        status: 'error',
        message: 'Error al cancelar pedido: $e',
        data: null,
      );
    }
  }
}
