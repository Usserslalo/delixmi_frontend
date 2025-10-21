import 'package:flutter/foundation.dart';
import '../models/api_response.dart';
import '../models/owner/order_models.dart';
import 'api_service.dart';
import 'token_manager.dart';

class OwnerOrderService {
  /// Obtiene la lista de pedidos del restaurante del owner
  static Future<ApiResponse<OrderListResponse>> getOrders({
    int page = 1,
    int pageSize = 10, // Backend default
    String? status,
    String? dateFrom,
    String? dateTo,
    String? sortBy,
    String? sortOrder,
    String? search,
  }) async {
    try {
      debugPrint('📋 OwnerOrderService: Obteniendo pedidos del restaurante...');
      debugPrint('📋 Parámetros: page=$page, pageSize=$pageSize, status=$status, search=$search');
      
      final headers = await TokenManager.getAuthHeaders();
      
      // Validar parámetros según backend Zod schema
      if (page <= 0) {
        debugPrint('⚠️ OwnerOrderService: page debe ser mayor a 0, usando 1');
        page = 1;
      }
      if (pageSize <= 0) {
        debugPrint('⚠️ OwnerOrderService: pageSize debe ser mayor a 0, usando 10');
        pageSize = 10;
      }
      if (pageSize > 100) {
        debugPrint('⚠️ OwnerOrderService: pageSize excede el máximo de 100, usando 100');
        pageSize = 100;
      }
      
      // Construir query parameters
      final Map<String, String> queryParams = {
        'page': page.toString(),
        'pageSize': pageSize.toString(),
      };
      
      if (status != null && status.isNotEmpty) {
        queryParams['status'] = status;
      }
      
      if (dateFrom != null && dateFrom.isNotEmpty) {
        queryParams['dateFrom'] = dateFrom;
      }
      
      if (dateTo != null && dateTo.isNotEmpty) {
        queryParams['dateTo'] = dateTo;
      }
      
      // Validación según backend Zod schema: dateFrom no puede ser mayor a dateTo
      if (dateFrom != null && dateTo != null && 
          dateFrom.isNotEmpty && dateTo.isNotEmpty) {
        try {
          final fromDate = DateTime.parse(dateFrom);
          final toDate = DateTime.parse(dateTo);
          if (fromDate.isAfter(toDate)) {
            debugPrint('⚠️ OwnerOrderService: dateFrom no puede ser mayor a dateTo');
            // No enviar los parámetros de fecha si son inválidos
            queryParams.remove('dateFrom');
            queryParams.remove('dateTo');
          }
        } catch (e) {
          debugPrint('⚠️ OwnerOrderService: Error al parsear fechas: $e');
          // Si hay error en el parsing, no enviar las fechas
          queryParams.remove('dateFrom');
          queryParams.remove('dateTo');
        }
      }
      
      // sortBy y sortOrder siempre se envían con defaults del backend
      queryParams['sortBy'] = sortBy ?? 'orderPlacedAt';
      queryParams['sortOrder'] = sortOrder ?? 'desc';
      
      if (search != null && search.trim().isNotEmpty) {
        queryParams['search'] = search.trim();
      }
      
      // Construir endpoint con query parameters
      final queryString = queryParams.entries
          .map((e) => '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
          .join('&');
      
      final endpoint = '/restaurant/orders?$queryString';
      
      final response = await ApiService.makeRequest<Map<String, dynamic>>(
        'GET',
        endpoint,
        headers,
        null,
        null,
      );

      if (response.isSuccess && response.data != null) {
        final orderListResponse = OrderListResponse.fromJson(response.data!);
        debugPrint('✅ Pedidos obtenidos exitosamente: ${orderListResponse.orders.length} pedidos');
        
        return ApiResponse<OrderListResponse>(
          status: 'success',
          message: response.message,
          data: orderListResponse,
        );
      } else {
        debugPrint('❌ Error al obtener pedidos: ${response.message}');
        
        // Manejar códigos de error específicos del backend
        String errorMessage = response.message;
        if (response.code != null) {
          switch (response.code) {
            case 'VALIDATION_ERROR':
              // El backend envía detalles específicos en response.errors
              if (response.errors != null && response.errors!.isNotEmpty) {
                final errorDetails = response.errors!.map((error) {
                  if (error is Map<String, dynamic>) {
                    final field = error['field'] ?? '';
                    final message = error['message'] ?? '';
                    return field.isNotEmpty ? '$field: $message' : message;
                  }
                  return error.toString();
                }).join('\n');
                errorMessage = errorDetails.isNotEmpty ? errorDetails : response.message;
              }
              break;
            case 'MISSING_TOKEN':
              errorMessage = 'Token de acceso requerido';
              break;
            case 'INSUFFICIENT_PERMISSIONS':
              errorMessage = 'Acceso denegado. Se requiere ser owner de un restaurante';
              break;
            case 'PRIMARY_BRANCH_NOT_FOUND':
              errorMessage = 'Sucursal principal no encontrada. Configure la ubicación del restaurante primero';
              break;
            case 'LOCATION_REQUIRED':
              errorMessage = 'Debe configurar la ubicación de su restaurante primero';
              break;
            case 'NOT_FOUND':
              errorMessage = 'Usuario no encontrado';
              break;
            case 'INTERNAL_ERROR':
              errorMessage = 'Error interno del servidor';
              break;
            default:
              errorMessage = response.message;
              break;
          }
        }
        
        return ApiResponse<OrderListResponse>(
          status: response.status,
          message: errorMessage,
          code: response.code,
          errors: response.errors,
        );
      }
    } catch (e) {
      debugPrint('❌ OwnerOrderService.getOrders: Error inesperado: $e');
      return ApiResponse<OrderListResponse>(
        status: 'error',
        message: 'Error al obtener los pedidos: ${e.toString()}',
      );
    }
  }

  /// Actualiza el estado de un pedido
  static Future<ApiResponse<Order>> updateOrderStatus({
    required String orderId,
    required String status,
  }) async {
    try {
      debugPrint('📋 OwnerOrderService: Actualizando estado del pedido $orderId a $status...');
      
      // Validar orderId según backend Zod schema: debe ser un número
      if (!RegExp(r'^\d+$').hasMatch(orderId)) {
        return ApiResponse<Order>(
          status: 'error',
          message: 'El ID del pedido debe ser un número válido',
          code: 'VALIDATION_ERROR',
        );
      }
      
      // Validar status según enum OrderStatus del backend
      final validStatuses = [
        'pending', 'confirmed', 'preparing', 'ready_for_pickup',
        'out_for_delivery', 'delivered', 'cancelled', 'refunded'
      ];
      if (!validStatuses.contains(status)) {
        return ApiResponse<Order>(
          status: 'error',
          message: 'Estado inválido',
          code: 'VALIDATION_ERROR',
        );
      }
      
      final headers = await TokenManager.getAuthHeaders();
      
      final response = await ApiService.makeRequest<Map<String, dynamic>>(
        'PATCH',
        '/restaurant/orders/$orderId/status',
        headers,
        {'status': status},
        null,
      );

      if (response.isSuccess && response.data != null) {
        final orderData = response.data!['order'] as Map<String, dynamic>;
        final order = Order.fromJson(orderData);
        
        debugPrint('✅ Estado del pedido actualizado exitosamente a $status');
        
        return ApiResponse<Order>(
          status: 'success',
          message: response.message,
          data: order,
        );
      } else {
        debugPrint('❌ Error al actualizar estado del pedido: ${response.message}');
        
        // Manejar códigos de error específicos del backend
        String errorMessage = response.message;
        if (response.code != null) {
          switch (response.code) {
            case 'VALIDATION_ERROR':
              // El backend envía detalles específicos en response.errors
              if (response.errors != null && response.errors!.isNotEmpty) {
                final errorDetails = response.errors!.map((error) {
                  if (error is Map<String, dynamic>) {
                    final field = error['field'] ?? '';
                    final message = error['message'] ?? '';
                    return field.isNotEmpty ? '$field: $message' : message;
                  }
                  return error.toString();
                }).join('\n');
                errorMessage = errorDetails.isNotEmpty ? errorDetails : response.message;
              }
              break;
            case 'STATUS_UPDATE_NOT_ALLOWED_FOR_ROLE':
              errorMessage = 'Tu rol no tiene permisos para realizar esta transición de estado';
              break;
            case 'ORDER_NOT_FOUND':
              errorMessage = 'Pedido no encontrado';
              break;
            case 'INVALID_STATUS_TRANSITION':
              errorMessage = 'Transición de estado inválida';
              break;
            case 'ORDER_IN_FINAL_STATE':
              errorMessage = 'No se puede cambiar el estado de un pedido finalizado';
              break;
            case 'MISSING_TOKEN':
              errorMessage = 'Token de acceso requerido';
              break;
            case 'INSUFFICIENT_PERMISSIONS':
              errorMessage = 'Acceso denegado. Se requiere ser owner de un restaurante';
              break;
            case 'PRIMARY_BRANCH_NOT_FOUND':
              errorMessage = 'Sucursal principal no encontrada. Configure la ubicación del restaurante primero';
              break;
            case 'LOCATION_REQUIRED':
              errorMessage = 'Debe configurar la ubicación de su restaurante primero';
              break;
            case 'NOT_FOUND':
              errorMessage = 'Usuario no encontrado';
              break;
            case 'INTERNAL_ERROR':
              errorMessage = 'Error interno del servidor';
              break;
            default:
              errorMessage = response.message;
              break;
          }
        }
        
        return ApiResponse<Order>(
          status: response.status,
          message: errorMessage,
          code: response.code,
          errors: response.errors,
        );
      }
    } catch (e) {
      debugPrint('❌ OwnerOrderService.updateOrderStatus: Error inesperado: $e');
      return ApiResponse<Order>(
        status: 'error',
        message: 'Error al actualizar el estado del pedido: ${e.toString()}',
      );
    }
  }
}
