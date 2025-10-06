import '../models/api_response.dart';
import 'api_service.dart';
import 'token_manager.dart';
import 'logger_service.dart';

class CheckoutService {
  /// Validar carrito antes del checkout
  static Future<ApiResponse<Map<String, dynamic>>> validateCart({
    required int restaurantId,
  }) async {
    try {
      LoggerService.location('Validando carrito para restaurante $restaurantId', tag: 'CheckoutService');
      
      final response = await ApiService.makeRequest<Map<String, dynamic>>(
        'POST',
        '/cart/validate',
        ApiService.authHeaders(await TokenManager.getToken() ?? ''),
        {
          'restaurantId': restaurantId,
        },
        (data) => data as Map<String, dynamic>,
      );

      LoggerService.location('Respuesta de validación: ${response.status}', tag: 'CheckoutService');
      return response;
    } catch (e) {
      LoggerService.error('Error al validar carrito: $e', tag: 'CheckoutService');
      return ApiResponse<Map<String, dynamic>>(
        status: 'error',
        message: 'Error al validar carrito: $e',
        data: null,
      );
    }
  }

  /// Crear pedido de pago en efectivo
  static Future<ApiResponse<Map<String, dynamic>>> createCashOrder({
    required int addressId,
    required int restaurantId,
    required List<Map<String, dynamic>> items,
    String? specialInstructions,
  }) async {
    try {
      LoggerService.location('Creando pedido de efectivo', tag: 'CheckoutService');
      
      final response = await ApiService.makeRequest<Map<String, dynamic>>(
        'POST',
        '/checkout/cash-order',
        ApiService.authHeaders(await TokenManager.getToken() ?? ''),
        {
          'addressId': addressId,
          'restaurantId': restaurantId,
          'items': items,
          if (specialInstructions != null) 'specialInstructions': specialInstructions,
        },
        (data) => data as Map<String, dynamic>,
      );

      LoggerService.location('Respuesta de pedido efectivo: ${response.status}', tag: 'CheckoutService');
      return response;
    } catch (e) {
      LoggerService.error('Error al crear pedido de efectivo: $e', tag: 'CheckoutService');
      return ApiResponse<Map<String, dynamic>>(
        status: 'error',
        message: 'Error al crear pedido de efectivo: $e',
        data: null,
      );
    }
  }

  /// Crear preferencia de Mercado Pago
  static Future<ApiResponse<Map<String, dynamic>>> createMercadoPagoPreference({
    required int addressId,
    required int restaurantId,
    bool useCart = true,
    String? specialInstructions,
  }) async {
    try {
      LoggerService.location('Creando preferencia de Mercado Pago', tag: 'CheckoutService');
      LoggerService.location('Datos: addressId=$addressId, restaurantId=$restaurantId, useCart=$useCart', tag: 'CheckoutService');
      
      final response = await ApiService.makeRequest<Map<String, dynamic>>(
        'POST',
        '/checkout/create-preference',
        ApiService.authHeaders(await TokenManager.getToken() ?? ''),
        {
          'addressId': addressId,
          'restaurantId': restaurantId,
          'useCart': useCart,
          if (specialInstructions != null) 'specialInstructions': specialInstructions,
        },
        (data) => data as Map<String, dynamic>,
      );

      LoggerService.location('Respuesta de preferencia MP: ${response.status}', tag: 'CheckoutService');
      if (response.isSuccess && response.data != null) {
        LoggerService.location('Preferencia creada - init_point: ${response.data!['init_point']}', tag: 'CheckoutService');
        LoggerService.location('External reference: ${response.data!['external_reference']}', tag: 'CheckoutService');
      }
      return response;
    } catch (e) {
      LoggerService.error('Error al crear preferencia MP: $e', tag: 'CheckoutService');
      return ApiResponse<Map<String, dynamic>>(
        status: 'error',
        message: 'Error al crear preferencia de Mercado Pago: $e',
        data: null,
      );
    }
  }

  /// Verificar estado del pago
  static Future<ApiResponse<Map<String, dynamic>>> getPaymentStatus({
    required String paymentId,
  }) async {
    try {
      LoggerService.location('Verificando estado del pago: $paymentId', tag: 'CheckoutService');
      
      final response = await ApiService.makeRequest<Map<String, dynamic>>(
        'GET',
        '/checkout/payment-status/$paymentId',
        ApiService.authHeaders(await TokenManager.getToken() ?? ''),
        null,
        (data) => data as Map<String, dynamic>,
      );

      LoggerService.location('Estado del pago: ${response.status}', tag: 'CheckoutService');
      return response;
    } catch (e) {
      LoggerService.error('Error al verificar estado del pago: $e', tag: 'CheckoutService');
      return ApiResponse<Map<String, dynamic>>(
        status: 'error',
        message: 'Error al verificar estado del pago: $e',
        data: null,
      );
    }
  }

  /// Limpiar carrito después del pedido
  static Future<ApiResponse<Map<String, dynamic>>> clearCart({
    required int restaurantId,
  }) async {
    try {
      LoggerService.location('Limpiando carrito del restaurante $restaurantId', tag: 'CheckoutService');
      
      final response = await ApiService.makeRequest<Map<String, dynamic>>(
        'DELETE',
        '/cart/clear?restaurantId=$restaurantId',
        ApiService.authHeaders(await TokenManager.getToken() ?? ''),
        null,
        (data) => data as Map<String, dynamic>,
      );

      LoggerService.location('Respuesta de limpieza: ${response.status}', tag: 'CheckoutService');
      return response;
    } catch (e) {
      LoggerService.error('Error al limpiar carrito: $e', tag: 'CheckoutService');
      return ApiResponse<Map<String, dynamic>>(
        status: 'error',
        message: 'Error al limpiar carrito: $e',
        data: null,
      );
    }
  }
}