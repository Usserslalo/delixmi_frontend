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

  /// Crear pedido de pago en efectivo usando el carrito
  static Future<ApiResponse<Map<String, dynamic>>> createCashOrderFromCart({
    required int addressId,
    required int restaurantId,
    String? specialInstructions,
  }) async {
    try {
      LoggerService.location('Creando pedido de efectivo desde carrito', tag: 'CheckoutService');
      
      final response = await ApiService.makeRequest<Map<String, dynamic>>(
        'POST',
        '/checkout/cash-order',
        ApiService.authHeaders(await TokenManager.getToken() ?? ''),
        {
          'addressId': addressId,
          'useCart': true,
          'restaurantId': restaurantId,
          if (specialInstructions != null) 'specialInstructions': specialInstructions,
        },
        (data) => data as Map<String, dynamic>,
      );

      LoggerService.location('Respuesta de pedido efectivo desde carrito: ${response.status}', tag: 'CheckoutService');
      return response;
    } catch (e) {
      LoggerService.error('Error al crear pedido de efectivo desde carrito: $e', tag: 'CheckoutService');
      return ApiResponse<Map<String, dynamic>>(
        status: 'error',
        message: 'Error al crear pedido de efectivo desde carrito: $e',
        data: null,
      );
    }
  }

  /// Crear pedido de pago en efectivo con items directos
  static Future<ApiResponse<Map<String, dynamic>>> createCashOrderDirect({
    required int addressId,
    required List<Map<String, dynamic>> items,
    String? specialInstructions,
  }) async {
    try {
      LoggerService.location('Creando pedido de efectivo con items directos', tag: 'CheckoutService');
      
      final response = await ApiService.makeRequest<Map<String, dynamic>>(
        'POST',
        '/checkout/cash-order',
        ApiService.authHeaders(await TokenManager.getToken() ?? ''),
        {
          'addressId': addressId,
          'items': items,
          if (specialInstructions != null) 'specialInstructions': specialInstructions,
        },
        (data) => data as Map<String, dynamic>,
      );

      LoggerService.location('Respuesta de pedido efectivo directo: ${response.status}', tag: 'CheckoutService');
      return response;
    } catch (e) {
      LoggerService.error('Error al crear pedido de efectivo directo: $e', tag: 'CheckoutService');
      return ApiResponse<Map<String, dynamic>>(
        status: 'error',
        message: 'Error al crear pedido de efectivo directo: $e',
        data: null,
      );
    }
  }

  /// Crear pedido de pago en efectivo (método de compatibilidad)
  @Deprecated('Usar createCashOrderFromCart o createCashOrderDirect')
  static Future<ApiResponse<Map<String, dynamic>>> createCashOrder({
    required int addressId,
    required int restaurantId,
    required List<Map<String, dynamic>> items,
    String? specialInstructions,
  }) async {
    // Usar el carrito por defecto para mantener compatibilidad
    return createCashOrderFromCart(
      addressId: addressId,
      restaurantId: restaurantId,
      specialInstructions: specialInstructions,
    );
  }

  /// Crear preferencia de Mercado Pago usando el carrito
  static Future<ApiResponse<Map<String, dynamic>>> createMercadoPagoPreferenceFromCart({
    required int addressId,
    required int restaurantId,
    String? specialInstructions,
  }) async {
    try {
      LoggerService.location('Creando preferencia de Mercado Pago desde carrito', tag: 'CheckoutService');
      LoggerService.location('Datos: addressId=$addressId, restaurantId=$restaurantId', tag: 'CheckoutService');
      
      final response = await ApiService.makeRequest<Map<String, dynamic>>(
        'POST',
        '/checkout/create-preference',
        ApiService.authHeaders(await TokenManager.getToken() ?? ''),
        {
          'addressId': addressId,
          'useCart': true,
          'restaurantId': restaurantId,
          if (specialInstructions != null) 'specialInstructions': specialInstructions,
        },
        (data) => data as Map<String, dynamic>,
      );

      LoggerService.location('Respuesta de preferencia MP desde carrito: ${response.status}', tag: 'CheckoutService');
      if (response.isSuccess && response.data != null) {
        LoggerService.location('Preferencia creada - init_point: ${response.data!['init_point']}', tag: 'CheckoutService');
        LoggerService.location('External reference: ${response.data!['external_reference']}', tag: 'CheckoutService');
      }
      return response;
    } catch (e) {
      LoggerService.error('Error al crear preferencia MP desde carrito: $e', tag: 'CheckoutService');
      return ApiResponse<Map<String, dynamic>>(
        status: 'error',
        message: 'Error al crear preferencia de Mercado Pago desde carrito: $e',
        data: null,
      );
    }
  }

  /// Crear preferencia de Mercado Pago con items directos
  static Future<ApiResponse<Map<String, dynamic>>> createMercadoPagoPreferenceDirect({
    required int addressId,
    required List<Map<String, dynamic>> items,
    String? specialInstructions,
  }) async {
    try {
      LoggerService.location('Creando preferencia de Mercado Pago con items directos', tag: 'CheckoutService');
      
      final response = await ApiService.makeRequest<Map<String, dynamic>>(
        'POST',
        '/checkout/create-preference',
        ApiService.authHeaders(await TokenManager.getToken() ?? ''),
        {
          'addressId': addressId,
          'items': items,
          if (specialInstructions != null) 'specialInstructions': specialInstructions,
        },
        (data) => data as Map<String, dynamic>,
      );

      LoggerService.location('Respuesta de preferencia MP directo: ${response.status}', tag: 'CheckoutService');
      if (response.isSuccess && response.data != null) {
        LoggerService.location('Preferencia creada - init_point: ${response.data!['init_point']}', tag: 'CheckoutService');
        LoggerService.location('External reference: ${response.data!['external_reference']}', tag: 'CheckoutService');
      }
      return response;
    } catch (e) {
      LoggerService.error('Error al crear preferencia MP directo: $e', tag: 'CheckoutService');
      return ApiResponse<Map<String, dynamic>>(
        status: 'error',
        message: 'Error al crear preferencia de Mercado Pago directo: $e',
        data: null,
      );
    }
  }

  /// Crear preferencia de Mercado Pago (método de compatibilidad)
  @Deprecated('Usar createMercadoPagoPreferenceFromCart o createMercadoPagoPreferenceDirect')
  static Future<ApiResponse<Map<String, dynamic>>> createMercadoPagoPreference({
    required int addressId,
    required int restaurantId,
    bool useCart = true,
    String? specialInstructions,
  }) async {
    // Usar el carrito por defecto para mantener compatibilidad
    return createMercadoPagoPreferenceFromCart(
      addressId: addressId,
      restaurantId: restaurantId,
      specialInstructions: specialInstructions,
    );
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