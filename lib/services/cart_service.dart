import '../models/api_response.dart';
import '../models/restaurant_cart.dart';
import 'api_service.dart';
import 'token_manager.dart';
import 'logger_service.dart';

class CartService {
  /// Método de diagnóstico para verificar conectividad y autenticación
  static Future<void> diagnoseConnection() async {
    try {
      LoggerService.debug('DIAGNÓSTICO DE CONECTIVIDAD Y AUTENTICACIÓN', tag: 'CartService');
      
      // Verificar token
      final token = await TokenManager.getToken();
      LoggerService.debug('Token disponible: ${token != null ? "Sí" : "No"}', tag: 'CartService');
      if (token != null) {
        LoggerService.debug('Token: ${token.substring(0, 20)}...', tag: 'CartService');
      }
      
      // Verificar headers
      final headers = await TokenManager.getAuthHeaders();
      LoggerService.debug('Headers: $headers', tag: 'CartService');
      
      // Verificar URL base
      LoggerService.debug('URL base: ${ApiService.fullUrl}', tag: 'CartService');
      
      // Hacer una petición de prueba simple
      LoggerService.debug('Probando conectividad con endpoint de prueba...', tag: 'CartService');
      final testResponse = await ApiService.makeRequest<Map<String, dynamic>>(
        'GET',
        '/categories', // Endpoint público
        ApiService.defaultHeaders,
        null,
        (data) => data as Map<String, dynamic>,
      );
      
      LoggerService.debug('Respuesta de prueba: ${testResponse.status}', tag: 'CartService');
      LoggerService.debug('Datos de prueba: ${testResponse.data}', tag: 'CartService');
      
      // Probar específicamente el endpoint del carrito
      LoggerService.debug('Probando endpoint del carrito específicamente...', tag: 'CartService');
      final cartTestResponse = await ApiService.makeRequest<Map<String, dynamic>>(
        'GET',
        '/cart',
        headers,
        null,
        (data) => data as Map<String, dynamic>,
      );
      
      LoggerService.debug('Respuesta del carrito: ${cartTestResponse.status}', tag: 'CartService');
      LoggerService.debug('Datos del carrito: ${cartTestResponse.data}', tag: 'CartService');
      
    } catch (e) {
      LoggerService.error('Error en diagnóstico: $e', tag: 'CartService');
    }
  }

  /// Obtener carrito del usuario
  static Future<ApiResponse<List<RestaurantCart>>> getCart() async {
    try {
      LoggerService.cart('Obteniendo carrito del usuario...', tag: 'CartService');
      
      // Verificar si hay token disponible
      final token = await TokenManager.getToken();
      LoggerService.debug('Token disponible: ${token != null ? "Sí" : "No"}', tag: 'CartService');
      if (token != null) {
        LoggerService.debug('Token: ${token.substring(0, 20)}...', tag: 'CartService');
      }
      
      final headers = await TokenManager.getAuthHeaders();
      LoggerService.debug('Headers: $headers', tag: 'CartService');
      
      final response = await ApiService.makeRequest<Map<String, dynamic>>(
        'GET',
        '/cart',
        headers,
        null,
        (data) => data as Map<String, dynamic>,
      );

      LoggerService.cart('Respuesta del carrito: ${response.status}', tag: 'CartService');
      LoggerService.cart('Datos del carrito: ${response.data}', tag: 'CartService');

        // Extraer la lista de carritos por restaurante
        List<RestaurantCart> restaurantCarts = [];
        if (response.isSuccess && response.data != null) {
          final responseData = response.data!;
          
          // El backend devuelve: data: {carts: [...]}
          List<dynamic> cartData = [];
          if (responseData.containsKey('carts') && responseData['carts'] is List) {
            cartData = responseData['carts'] as List<dynamic>;
            LoggerService.cart('Estructura correcta encontrada: data.carts con ${cartData.length} carritos', tag: 'CartService');
          } else if (responseData.containsKey('data') && 
              responseData['data'] is Map<String, dynamic> &&
              responseData['data']['carts'] is List) {
            cartData = responseData['data']['carts'] as List<dynamic>;
            LoggerService.cart('Estructura alternativa encontrada: data.data.carts con ${cartData.length} carritos', tag: 'CartService');
          } else {
            LoggerService.cart('Estructura no reconocida: ${responseData.keys}', tag: 'CartService');
            LoggerService.cart('Datos completos: $responseData', tag: 'CartService');
          }
          
          restaurantCarts = cartData.map((cart) => RestaurantCart.fromJson(cart)).toList();
          LoggerService.cart('Carritos por restaurante cargados: ${restaurantCarts.length} restaurantes', tag: 'CartService');
        }

      return ApiResponse<List<RestaurantCart>>(
        status: response.status,
        message: response.message,
        data: restaurantCarts,
        code: response.code,
        errors: response.errors,
      );
    } catch (e) {
      LoggerService.error('Error al obtener carrito: $e', tag: 'CartService');
      return ApiResponse<List<RestaurantCart>>(
        status: 'error',
        message: 'Error al obtener carrito: $e',
        data: [],
      );
    }
  }

  /// Agregar producto al carrito
  static Future<ApiResponse<Map<String, dynamic>>> addToCart({
    required int productId,
    required int quantity,
  }) async {
    try {
      LoggerService.cart('Agregando producto $productId al carrito (cantidad: $quantity)...', tag: 'CartService');
      
      final response = await ApiService.makeRequest<Map<String, dynamic>>(
        'POST',
        '/cart/add',
        await TokenManager.getAuthHeaders(),
        {
          'productId': productId,
          'quantity': quantity,
        },
        (data) => data as Map<String, dynamic>,
      );

      LoggerService.cart('Respuesta al agregar: ${response.status}', tag: 'CartService');
      LoggerService.cart('Datos de respuesta: ${response.data}', tag: 'CartService');

      return response;
    } catch (e) {
      LoggerService.error('Error al agregar producto al carrito: $e', tag: 'CartService');
      return ApiResponse<Map<String, dynamic>>(
        status: 'error',
        message: 'Error al agregar producto al carrito: $e',
        data: null,
      );
    }
  }

  /// Actualizar cantidad de item en el carrito
  static Future<ApiResponse<Map<String, dynamic>>> updateQuantity({
    required int itemId,
    required int quantity,
  }) async {
    try {
      LoggerService.cart('Actualizando cantidad del item $itemId a $quantity...', tag: 'CartService');
      
      final response = await ApiService.makeRequest<Map<String, dynamic>>(
        'PUT',
        '/cart/update/$itemId',
        await TokenManager.getAuthHeaders(),
        {
          'quantity': quantity,
        },
        (data) => data as Map<String, dynamic>,
      );

      LoggerService.cart('Respuesta al actualizar: ${response.status}', tag: 'CartService');
      LoggerService.cart('Datos de respuesta: ${response.data}', tag: 'CartService');

      return response;
    } catch (e) {
      LoggerService.error('Error al actualizar cantidad: $e', tag: 'CartService');
      return ApiResponse<Map<String, dynamic>>(
        status: 'error',
        message: 'Error al actualizar cantidad: $e',
        data: null,
      );
    }
  }

  /// Eliminar item del carrito
  static Future<ApiResponse<Map<String, dynamic>>> removeFromCart({
    required int itemId,
  }) async {
    try {
      LoggerService.cart('Eliminando item $itemId del carrito...', tag: 'CartService');
      
      final response = await ApiService.makeRequest<Map<String, dynamic>>(
        'DELETE',
        '/cart/remove/$itemId',
        await TokenManager.getAuthHeaders(),
        null,
        (data) => data as Map<String, dynamic>,
      );

      LoggerService.cart('Respuesta al eliminar: ${response.status}', tag: 'CartService');
      LoggerService.cart('Datos de respuesta: ${response.data}', tag: 'CartService');

      return response;
    } catch (e) {
      LoggerService.error('Error al eliminar producto del carrito: $e', tag: 'CartService');
      return ApiResponse<Map<String, dynamic>>(
        status: 'error',
        message: 'Error al eliminar producto del carrito: $e',
        data: null,
      );
    }
  }

  /// Limpiar todo el carrito
  static Future<ApiResponse<Map<String, dynamic>>> clearCart() async {
    try {
      LoggerService.cart('Limpiando carrito completo...', tag: 'CartService');
      
      final response = await ApiService.makeRequest<Map<String, dynamic>>(
        'DELETE',
        '/cart/clear',
        await TokenManager.getAuthHeaders(),
        null,
        (data) => data as Map<String, dynamic>,
      );

      LoggerService.cart('Respuesta al limpiar: ${response.status}', tag: 'CartService');
      LoggerService.cart('Datos de respuesta: ${response.data}', tag: 'CartService');

      return response;
    } catch (e) {
      LoggerService.error('Error al limpiar carrito: $e', tag: 'CartService');
      return ApiResponse<Map<String, dynamic>>(
        status: 'error',
        message: 'Error al limpiar carrito: $e',
        data: null,
      );
    }
  }

  /// Obtener resumen del carrito
  static Future<Map<String, dynamic>> getCartSummary() async {
    try {
      final response = await getCart();
      if (response.isSuccess && response.data != null) {
        final restaurantCarts = response.data!;
        
        int totalItems = 0;
        double totalAmount = 0.0;
        
        for (final restaurantCart in restaurantCarts) {
          totalItems += restaurantCart.totalItems;
          totalAmount += restaurantCart.subtotal;
        }
        
        return {
          'totalItems': totalItems,
          'totalAmount': totalAmount,
          'restaurantCount': restaurantCarts.length,
        };
      }
      
      return {
        'totalItems': 0,
        'totalAmount': 0.0,
        'restaurantCount': 0,
      };
    } catch (e) {
      LoggerService.error('Error al obtener resumen del carrito: $e', tag: 'CartService');
      return {
        'totalItems': 0,
        'totalAmount': 0.0,
        'restaurantCount': 0,
      };
    }
  }
}