import 'package:flutter/foundation.dart';
import '../models/api_response.dart';
import '../models/owner/metrics_models.dart';
import '../models/owner/dashboard_summary_models.dart';
import 'api_service.dart';
import 'token_manager.dart';

class MetricsService {
  /// Obtiene el saldo de la billetera del restaurante
  static Future<ApiResponse<RestaurantWallet>> getWalletBalance() async {
    try {
      debugPrint('💰 MetricsService: Obteniendo saldo de billetera...');
      
      final headers = await TokenManager.getAuthHeaders();
      
      final response = await ApiService.makeRequest<Map<String, dynamic>>(
        'GET',
        '/restaurant/wallet/balance',
        headers,
        null,
        null,
      );

      if (response.isSuccess && response.data != null) {
        try {
          final walletData = response.data!['wallet'] as Map<String, dynamic>;
          final wallet = RestaurantWallet.fromJson(walletData);
          
          return ApiResponse<RestaurantWallet>(
            status: 'success',
            message: response.message,
            data: wallet,
          );
        } catch (e) {
          debugPrint('❌ Error parsing wallet data: $e');
          return ApiResponse<RestaurantWallet>(
            status: 'error',
            message: 'Error al procesar los datos de la billetera: ${e.toString()}',
            code: 'PARSE_ERROR',
          );
        }
      } else {
        debugPrint('❌ Error al obtener saldo: ${response.message}');
        
        // Manejar códigos de error específicos del backend
        String errorMessage = response.message;
        if (response.code != null) {
          switch (response.code) {
            case 'RESTAURANT_NOT_FOUND':
              errorMessage = 'Restaurante no encontrado para este propietario';
              break;
            case 'RESTAURANT_WALLET_NOT_FOUND':
              errorMessage = 'Billetera del restaurante no encontrada';
              break;
            case 'INSUFFICIENT_PERMISSIONS':
              errorMessage = 'Permisos insuficientes para acceder a la billetera';
              break;
            case 'LOCATION_REQUIRED':
              errorMessage = 'Debe configurar la ubicación del restaurante primero';
              break;
            default:
              errorMessage = response.message;
              break;
          }
        }
        
        return ApiResponse<RestaurantWallet>(
          status: response.status,
          message: errorMessage,
          code: response.code,
        );
      }
    } catch (e) {
      debugPrint('❌ Error en getWalletBalance: $e');
      return ApiResponse<RestaurantWallet>(
        status: 'error',
        message: 'Error interno: ${e.toString()}',
        code: 'INTERNAL_ERROR',
      );
    }
  }

  /// Obtiene las transacciones de la billetera del restaurante
  static Future<ApiResponse<TransactionListResponse>> getWalletTransactions({
    int page = 1,
    int pageSize = 10,
    String? dateFrom,
    String? dateTo,
  }) async {
    try {
      debugPrint('💰 MetricsService: Obteniendo transacciones...');
      debugPrint('📋 Parámetros: page=$page, pageSize=$pageSize, dateFrom=$dateFrom, dateTo=$dateTo');
      
      // Validar parámetros según backend Zod schema
      if (page <= 0) {
        debugPrint('⚠️ MetricsService: page debe ser mayor a 0, usando 1');
        page = 1;
      }
      if (pageSize <= 0) {
        debugPrint('⚠️ MetricsService: pageSize debe ser mayor a 0, usando 10');
        pageSize = 10;
      }
      if (pageSize > 50) {
        debugPrint('⚠️ MetricsService: pageSize excede el máximo de 50, usando 50');
        pageSize = 50;
      }
      
      final headers = await TokenManager.getAuthHeaders();
      
      // Construir query parameters
      final Map<String, String> queryParams = {
        'page': page.toString(),
        'pageSize': pageSize.toString(),
      };
      
      if (dateFrom != null && dateFrom.isNotEmpty) {
        // Formatear fecha según backend Zod schema: formato ISO datetime
        try {
          final date = DateTime.parse(dateFrom);
          // Backend espera formato ISO como: 2025-01-01T00:00:00Z
          queryParams['dateFrom'] = date.toUtc().toIso8601String().split('.')[0] + 'Z';
        } catch (e) {
          debugPrint('⚠️ MetricsService: Error parsing dateFrom: $e');
        }
      }
      
      if (dateTo != null && dateTo.isNotEmpty) {
        // Formatear fecha según backend Zod schema: formato ISO datetime
        try {
          final date = DateTime.parse(dateTo);
          // Backend espera formato ISO como: 2025-01-01T23:59:59Z
          queryParams['dateTo'] = date.toUtc().toIso8601String().split('.')[0] + 'Z';
        } catch (e) {
          debugPrint('⚠️ MetricsService: Error parsing dateTo: $e');
        }
      }
      
      // Validación según backend Zod schema: dateFrom no puede ser mayor a dateTo
      if (dateFrom != null && dateTo != null && 
          dateFrom.isNotEmpty && dateTo.isNotEmpty) {
        try {
          final fromDate = DateTime.parse(dateFrom);
          final toDate = DateTime.parse(dateTo);
          if (fromDate.isAfter(toDate)) {
            debugPrint('⚠️ MetricsService: dateFrom no puede ser mayor a dateTo');
            // No enviar los parámetros de fecha
            queryParams.remove('dateFrom');
            queryParams.remove('dateTo');
          }
        } catch (e) {
          debugPrint('⚠️ MetricsService: Error parsing dates: $e');
        }
      }
      
      // Debug: mostrar parámetros formateados
      if (queryParams.keys.any((key) => key == 'dateFrom' || key == 'dateTo')) {
        debugPrint('📋 Parámetros de fecha formateados: ${queryParams.entries.where((e) => e.key == 'dateFrom' || e.key == 'dateTo').toList()}');
      }
      
      // Construir URL con query parameters
      String endpoint = '/restaurant/wallet/transactions';
      if (queryParams.isNotEmpty) {
        final queryString = queryParams.entries
            .map((e) => '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
            .join('&');
        endpoint += '?$queryString';
      }
      
      final response = await ApiService.makeRequest<Map<String, dynamic>>(
        'GET',
        endpoint,
        headers,
        null,
        null,
      );

      if (response.isSuccess && response.data != null) {
        try {
          final transactionData = TransactionListResponse.fromJson(response.data!);
          
          return ApiResponse<TransactionListResponse>(
            status: 'success',
            message: response.message,
            data: transactionData,
          );
        } catch (e) {
          debugPrint('❌ Error parsing transaction data: $e');
          return ApiResponse<TransactionListResponse>(
            status: 'error',
            message: 'Error al procesar los datos de transacciones: ${e.toString()}',
            code: 'PARSE_ERROR',
          );
        }
      } else {
        debugPrint('❌ Error al obtener transacciones: ${response.message}');
        
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
            case 'RESTAURANT_NOT_FOUND':
              errorMessage = 'Restaurante no encontrado para este propietario';
              break;
            case 'RESTAURANT_WALLET_NOT_FOUND':
              errorMessage = 'Billetera del restaurante no encontrada';
              break;
            case 'INSUFFICIENT_PERMISSIONS':
              errorMessage = 'Permisos insuficientes para acceder a las transacciones';
              break;
            case 'LOCATION_REQUIRED':
              errorMessage = 'Debe configurar la ubicación del restaurante primero';
              break;
            default:
              errorMessage = response.message;
              break;
          }
        }
        
        return ApiResponse<TransactionListResponse>(
          status: response.status,
          message: errorMessage,
          code: response.code,
          errors: response.errors,
        );
      }
    } catch (e) {
      debugPrint('❌ Error en getWalletTransactions: $e');
      return ApiResponse<TransactionListResponse>(
        status: 'error',
        message: 'Error interno: ${e.toString()}',
        code: 'INTERNAL_ERROR',
      );
    }
  }

  /// Obtiene el resumen de ganancias del restaurante
  static Future<ApiResponse<EarningsResponse>> getEarningsSummary({
    String? dateFrom,
    String? dateTo,
  }) async {
    try {
      debugPrint('💰 MetricsService: Obteniendo resumen de ganancias...');
      debugPrint('📈 Parámetros originales: dateFrom=$dateFrom, dateTo=$dateTo');
      
      final headers = await TokenManager.getAuthHeaders();
      
      // Construir query parameters
      final Map<String, String> queryParams = {};
      
      if (dateFrom != null && dateFrom.isNotEmpty) {
        // Formatear fecha según backend Zod schema: formato ISO datetime
        try {
          final date = DateTime.parse(dateFrom);
          // Backend espera formato ISO como: 2025-01-01T00:00:00Z
          queryParams['dateFrom'] = date.toUtc().toIso8601String().split('.')[0] + 'Z';
        } catch (e) {
          debugPrint('⚠️ MetricsService: Error parsing dateFrom: $e');
        }
      }
      
      if (dateTo != null && dateTo.isNotEmpty) {
        // Formatear fecha según backend Zod schema: formato ISO datetime
        try {
          final date = DateTime.parse(dateTo);
          // Backend espera formato ISO como: 2025-01-01T23:59:59Z
          queryParams['dateTo'] = date.toUtc().toIso8601String().split('.')[0] + 'Z';
        } catch (e) {
          debugPrint('⚠️ MetricsService: Error parsing dateTo: $e');
        }
      }
      
      // Validación según backend Zod schema: dateFrom no puede ser mayor a dateTo
      if (dateFrom != null && dateTo != null && 
          dateFrom.isNotEmpty && dateTo.isNotEmpty) {
        try {
          final fromDate = DateTime.parse(dateFrom);
          final toDate = DateTime.parse(dateTo);
          if (fromDate.isAfter(toDate)) {
            debugPrint('⚠️ MetricsService: dateFrom no puede ser mayor a dateTo');
            // No enviar los parámetros de fecha
            queryParams.remove('dateFrom');
            queryParams.remove('dateTo');
          }
        } catch (e) {
          debugPrint('⚠️ MetricsService: Error parsing dates: $e');
        }
      }
      
      // Debug: mostrar parámetros formateados
      if (queryParams.isNotEmpty) {
        debugPrint('📈 Parámetros formateados: $queryParams');
      }
      
      // Construir URL con query parameters
      String endpoint = '/restaurant/metrics/earnings';
      if (queryParams.isNotEmpty) {
        final queryString = queryParams.entries
            .map((e) => '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
            .join('&');
        endpoint += '?$queryString';
        debugPrint('🌐 URL final: $endpoint');
      }
      
      final response = await ApiService.makeRequest<Map<String, dynamic>>(
        'GET',
        endpoint,
        headers,
        null,
        null,
      );

      if (response.isSuccess && response.data != null) {
        try {
          final earningsData = EarningsResponse.fromJson(response.data!);
          
          return ApiResponse<EarningsResponse>(
            status: 'success',
            message: response.message,
            data: earningsData,
          );
        } catch (e) {
          debugPrint('❌ Error parsing earnings data: $e');
          return ApiResponse<EarningsResponse>(
            status: 'error',
            message: 'Error al procesar los datos de ganancias: ${e.toString()}',
            code: 'PARSE_ERROR',
          );
        }
      } else {
        debugPrint('❌ Error al obtener resumen de ganancias: ${response.message}');
        
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
            case 'RESTAURANT_NOT_FOUND':
              errorMessage = 'Restaurante no encontrado para este propietario';
              break;
            case 'INSUFFICIENT_PERMISSIONS':
              errorMessage = 'Permisos insuficientes para acceder al resumen de ganancias';
              break;
            case 'LOCATION_REQUIRED':
              errorMessage = 'Debe configurar la ubicación del restaurante primero';
              break;
            default:
              // Para errores 500 del backend (como el error de validación de fecha)
              if (response.message.contains('Error interno del servidor') || 
                  response.message.toLowerCase().contains('internal server error')) {
                errorMessage = 'Error en el servidor al procesar las fechas. Verifique el formato de las fechas seleccionadas.';
              } else {
                errorMessage = response.message;
              }
              break;
          }
        }
        
        return ApiResponse<EarningsResponse>(
          status: response.status,
          message: errorMessage,
          code: response.code,
          errors: response.errors,
        );
      }
    } catch (e) {
      debugPrint('❌ Error en getEarningsSummary: $e');
      return ApiResponse<EarningsResponse>(
        status: 'error',
        message: 'Error interno: ${e.toString()}',
        code: 'INTERNAL_ERROR',
      );
    }
  }

  /// Obtiene el resumen completo del dashboard (endpoint "cerebro")
  static Future<ApiResponse<DashboardSummary>> getDashboardSummary() async {
    try {
      debugPrint('🚀 MetricsService: Obteniendo resumen del dashboard...');
      
      final headers = await TokenManager.getAuthHeaders();
      
      final response = await ApiService.makeRequest<Map<String, dynamic>>(
        'GET',
        '/restaurant/metrics/dashboard-summary',
        headers,
        null,
        null,
      );

      if (response.isSuccess && response.data != null) {
        try {
          final dashboardData = DashboardSummary.fromJson(response.data!);
          
          debugPrint('✅ Dashboard summary obtenido exitosamente');
          debugPrint('💰 Saldo: \$${dashboardData.data.financials.walletBalance}');
          debugPrint('📦 Pedidos pendientes: ${dashboardData.data.operations.pendingOrdersCount}');
          
          return ApiResponse<DashboardSummary>(
            status: 'success',
            message: response.message,
            data: dashboardData,
          );
        } catch (e) {
          debugPrint('❌ Error parsing dashboard data: $e');
          return ApiResponse<DashboardSummary>(
            status: 'error',
            message: 'Error al procesar los datos del dashboard: ${e.toString()}',
            code: 'PARSE_ERROR',
          );
        }
      } else {
        debugPrint('❌ Error al obtener resumen del dashboard: ${response.message}');
        
        // Manejar códigos de error específicos del backend
        String errorMessage = response.message;
        if (response.code != null) {
          switch (response.code) {
            case 'RESTAURANT_NOT_FOUND':
              errorMessage = 'Restaurante no encontrado para este propietario';
              break;
            case 'INSUFFICIENT_PERMISSIONS':
              errorMessage = 'Permisos insuficientes para acceder al dashboard';
              break;
            case 'LOCATION_REQUIRED':
              errorMessage = 'Debe configurar la ubicación del restaurante primero';
              break;
            default:
              errorMessage = response.message;
              break;
          }
        }
        
        return ApiResponse<DashboardSummary>(
          status: response.status,
          message: errorMessage,
          code: response.code,
        );
      }
    } catch (e) {
      debugPrint('❌ Error en getDashboardSummary: $e');
      return ApiResponse<DashboardSummary>(
        status: 'error',
        message: 'Error interno: ${e.toString()}',
        code: 'INTERNAL_ERROR',
      );
    }
  }
}
