/// Ejemplo de cómo integrar el nuevo servicio de Dashboard en la HomeScreen
/// 
/// Este archivo muestra cómo migrar gradualmente de múltiples llamadas API
/// a una sola llamada unificada usando el nuevo endpoint de dashboard.
/// 
/// IMPLEMENTACIÓN ACTUAL (múltiples llamadas):
/// - _loadCategories() → GET /api/categories
/// - _loadAddresses() → GET /api/customer/addresses  
/// - checkCoverageForAddress() → POST /api/customer/check-coverage
/// - _loadRestaurants() → GET /api/restaurants?page=1&...
/// - _loadCartSummary() → GET /api/cart/summary
/// 
/// IMPLEMENTACIÓN OPTIMIZADA (una sola llamada):
/// - _loadDashboard() → GET /api/home/dashboard

import 'package:flutter/material.dart';
import '../services/dashboard_service.dart';
import '../models/restaurant.dart';
import '../models/category.dart';
import '../models/address.dart';

class DashboardIntegrationExample {
  /// Ejemplo de implementación del nuevo método de carga unificada
  static Future<Map<String, dynamic>?> loadDashboardData({
    required double? latitude,
    required double? longitude,
    required int? addressId,
  }) async {
    try {
      // Una sola llamada API que obtiene todos los datos necesarios
      final response = await DashboardService.getDashboard(
        latitude: latitude,
        longitude: longitude,
        addressId: addressId,
      );

      if (response.isSuccess && response.data != null) {
        // Parsear la respuesta unificada
        final dashboardData = DashboardService.parseDashboardResponse(response.data!);
        
        return {
          'categories': dashboardData['categories'] as List<Category>,
          'restaurants': dashboardData['restaurants'] as List<Restaurant>,
          'addresses': dashboardData['addresses'] as List<Address>,
          'cartSummary': dashboardData['cartSummary'],
          'coverage': dashboardData['coverage'],
          'userLocation': dashboardData['userLocation'],
          'metadata': dashboardData['metadata'],
        };
      } else {
        throw Exception(response.message);
      }
    } catch (e) {
      debugPrint('❌ Error cargando dashboard: $e');
      return null;
    }
  }

  /// Ejemplo de cómo reemplazar el método _loadInitialData() en HomeScreen
  static Future<void> loadInitialDataOptimized({
    required Function(List<Category>) setCategories,
    required Function(List<Restaurant>) setRestaurants,
    required Function(List<Address>) setAddresses,
    required Function(Map<String, dynamic>) setCartSummary,
    required Function(Map<String, dynamic>) setCoverage,
    required double? latitude,
    required double? longitude,
    required int? addressId,
  }) async {
    // Cargar todos los datos en una sola llamada
    final dashboardData = await loadDashboardData(
      latitude: latitude,
      longitude: longitude,
      addressId: addressId,
    );

    if (dashboardData != null) {
      // Actualizar estado con todos los datos obtenidos
      setCategories(dashboardData['categories']);
      setRestaurants(dashboardData['restaurants']);
      setAddresses(dashboardData['addresses']);
      setCartSummary(dashboardData['cartSummary']);
      setCoverage(dashboardData['coverage']);
      
      debugPrint('✅ Dashboard cargado: ${dashboardData['restaurants'].length} restaurantes, ${dashboardData['categories'].length} categorías');
    }
  }

  /// Ejemplo de verificación de cobertura optimizada
  static Future<bool> checkCoverageOptimized({
    required double latitude,
    required double longitude,
  }) async {
    try {
      final response = await DashboardService.checkCoverageByCoordinates(
        latitude: latitude,
        longitude: longitude,
      );

      if (response.isSuccess && response.data != null) {
        final coverageData = response.data!['data'];
        return coverageData['hasCoverage'] ?? false;
      }
      
      return false;
    } catch (e) {
      debugPrint('❌ Error verificando cobertura: $e');
      return false;
    }
  }

  /// Ejemplo de cómo mostrar nuevos metadatos en la UI
  static Widget buildRestaurantCardWithNewFeatures(Restaurant restaurant) {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header con nombre y badge de promoción
          Row(
            children: [
              Expanded(
                child: Text(
                  restaurant.name,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              // Badge de promoción (si está disponible)
              if (restaurant.hasPromotion)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.orange,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.local_fire_department, size: 12, color: Colors.white),
                      SizedBox(width: 4),
                      Text('🔥 Promo', style: TextStyle(color: Colors.white, fontSize: 10)),
                    ],
                  ),
                ),
            ],
          ),
          
          const SizedBox(height: 8),
          
          // Información mejorada con nuevos campos
          Wrap(
            spacing: 8,
            children: [
              // Tiempo de preparación estimado (nuevo campo)
              if (restaurant.estimatedWaitTime != null)
                _buildInfoChip(
                  icon: Icons.access_time,
                  text: '${restaurant.estimatedWaitTime} min',
                  color: Colors.blue,
                ),
              
              // Tarifa mínima de envío (nuevo campo)
              if (restaurant.minDeliveryFee != null)
                _buildInfoChip(
                  icon: Icons.local_shipping,
                  text: '\$${restaurant.minDeliveryFee!.toStringAsFixed(2)}',
                  color: Colors.green,
                ),
              
              // Monto mínimo de pedido (nuevo campo)
              if (restaurant.minOrderAmount != null)
                _buildInfoChip(
                  icon: Icons.shopping_bag,
                  text: 'Mín. \$${restaurant.minOrderAmount!.toStringAsFixed(2)}',
                  color: Colors.orange,
                ),
            ],
          ),
          
          const SizedBox(height: 8),
          
          // Métodos de pago (nuevo campo)
          if (restaurant.paymentMethods != null && restaurant.paymentMethods!.isNotEmpty)
            Text(
              'Pagos: ${restaurant.paymentMethods!.join(', ')}',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
        ],
      ),
    );
  }

  /// Widget helper para mostrar información en chips
  static Widget _buildInfoChip({
    required IconData icon,
    required String text,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

/// Ejemplo de cómo migrar gradualmente en HomeScreen
/// 
/// PASO 1: Mantener implementación actual funcionando
/// PASO 2: Agregar método alternativo con dashboard API
/// PASO 3: Probar en desarrollo
/// PASO 4: Migrar gradualmente en producción
/// PASO 5: Deprecar métodos antiguos

class HomeScreenMigrationExample {
  /// Método actual (mantener funcionando)
  static Future<void> loadDataCurrent() async {
    // Implementación actual con múltiples llamadas
    // - _loadCategories()
    // - _loadAddresses()
    // - checkCoverageForAddress()
    // - _loadRestaurants()
    // - _loadCartSummary()
  }

  /// Método optimizado (implementar gradualmente)
  static Future<void> loadDataOptimized() async {
    // Nueva implementación con dashboard API
    // - _loadDashboard()
  }

  /// Método híbrido (transición)
  static Future<void> loadDataHybrid() async {
    try {
      // Intentar cargar con dashboard API
      await loadDataOptimized();
    } catch (e) {
      debugPrint('⚠️ Dashboard API falló, usando método actual: $e');
      // Fallback al método actual
      await loadDataCurrent();
    }
  }
}
