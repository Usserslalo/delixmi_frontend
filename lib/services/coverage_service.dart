import 'package:flutter/material.dart';
import '../models/address.dart';
import 'address_service.dart';

class CoverageService {
  // Configuración de zonas de cobertura por defecto
  static const double _defaultCoverageRadius = 15.0; // km
  static const double _baseDeliveryFee = 25.0; // MXN
  static const double _perKmFee = 2.0; // MXN por km
  
  // Coordenadas de ejemplo para zonas de cobertura
  static const Map<String, Map<String, double>> _coverageZones = {
    'ciudad_mexico': {
      'center_lat': 19.4326,
      'center_lng': -99.1332,
      'radius': 15.0,
    },
    'guadalajara': {
      'center_lat': 20.6597,
      'center_lng': -103.3496,
      'radius': 12.0,
    },
    'monterrey': {
      'center_lat': 25.6866,
      'center_lng': -100.3161,
      'radius': 10.0,
    },
  };

  /// Validar si una dirección está dentro de la zona de cobertura
  static Future<CoverageResult> validateCoverage({
    required double latitude,
    required double longitude,
    required int restaurantId,
  }) async {
    try {
      debugPrint('📍 Validando cobertura para lat: $latitude, lng: $longitude, restaurant: $restaurantId');
      
      // Obtener información del restaurante
      final restaurantInfo = await _getRestaurantCoverageInfo(restaurantId);
      if (restaurantInfo == null) {
        return CoverageResult.error('No se pudo obtener información del restaurante');
      }
      
      // Calcular distancia desde el restaurante
      final distance = AddressService.calculateDistance(
        lat1: restaurantInfo['latitude']!,
        lng1: restaurantInfo['longitude']!,
        lat2: latitude,
        lng2: longitude,
      );
      
      debugPrint('📍 Distancia calculada: ${distance.toStringAsFixed(2)} km');
      
      // Verificar si está dentro del radio de cobertura
      final maxDistance = restaurantInfo['coverage_radius'] ?? _defaultCoverageRadius;
      final isWithinCoverage = distance <= maxDistance;
      
      if (!isWithinCoverage) {
        return CoverageResult.outOfCoverage(
          distance: distance,
          maxDistance: maxDistance,
          message: 'La dirección está fuera del área de cobertura. '
                   'Distancia máxima: ${maxDistance.toStringAsFixed(1)} km, '
                   'distancia actual: ${distance.toStringAsFixed(1)} km',
        );
      }
      
      // Calcular tarifa de envío
      final deliveryFee = _calculateDeliveryFee(distance);
      final estimatedTime = _calculateEstimatedTime(distance);
      
      return CoverageResult.success(
        distance: distance,
        deliveryFee: deliveryFee,
        estimatedTime: estimatedTime,
        coverageZone: restaurantInfo['zone'] ?? 'default',
      );
      
    } catch (e) {
      debugPrint('❌ Error al validar cobertura: $e');
      return CoverageResult.error('Error al validar zona de cobertura: $e');
    }
  }

  /// Obtener información de cobertura del restaurante
  static Future<Map<String, dynamic>?> _getRestaurantCoverageInfo(int restaurantId) async {
    try {
      // TODO: Implementar llamada al backend para obtener información del restaurante
      // Por ahora, usar datos de ejemplo
      
      // Simular diferentes restaurantes con diferentes zonas
      final restaurantZones = {
        1: 'ciudad_mexico',
        2: 'ciudad_mexico', // Pizzería de Ana
        3: 'guadalajara',
        4: 'monterrey',
      };
      
      final zone = restaurantZones[restaurantId] ?? 'ciudad_mexico';
      final zoneInfo = _coverageZones[zone]!;
      
      return {
        'restaurant_id': restaurantId,
        'latitude': zoneInfo['center_lat'],
        'longitude': zoneInfo['center_lng'],
        'coverage_radius': zoneInfo['radius'],
        'zone': zone,
      };
    } catch (e) {
      debugPrint('❌ Error al obtener información del restaurante: $e');
      return null;
    }
  }

  /// Calcular tarifa de envío basada en la distancia
  static double _calculateDeliveryFee(double distance) {
    if (distance <= 5.0) {
      return _baseDeliveryFee; // Tarifa base para distancias cortas
    } else {
      final extraDistance = distance - 5.0;
      final extraFee = extraDistance * _perKmFee;
      return _baseDeliveryFee + extraFee;
    }
  }

  /// Calcular tiempo estimado de entrega
  static int _calculateEstimatedTime(double distance) {
    // Tiempo base: 15 minutos
    // Tiempo adicional: 2 minutos por km
    final baseTime = 15;
    final additionalTime = (distance * 2).round();
    return baseTime + additionalTime;
  }

  /// Validar múltiples direcciones
  static Future<List<CoverageResult>> validateMultipleAddresses({
    required List<Address> addresses,
    required int restaurantId,
  }) async {
    final results = <CoverageResult>[];
    
    for (final address in addresses) {
      final result = await validateCoverage(
        latitude: address.latitude,
        longitude: address.longitude,
        restaurantId: restaurantId,
      );
      results.add(result);
    }
    
    return results;
  }

  /// Obtener zonas de cobertura disponibles
  static List<CoverageZone> getAvailableCoverageZones() {
    return _coverageZones.entries.map((entry) {
      final zoneInfo = entry.value;
      return CoverageZone(
        id: entry.key,
        name: _getZoneDisplayName(entry.key),
        centerLatitude: zoneInfo['center_lat']!,
        centerLongitude: zoneInfo['center_lng']!,
        radius: zoneInfo['radius']!,
      );
    }).toList();
  }

  /// Obtener nombre de visualización de la zona
  static String _getZoneDisplayName(String zoneId) {
    switch (zoneId) {
      case 'ciudad_mexico':
        return 'Ciudad de México';
      case 'guadalajara':
        return 'Guadalajara';
      case 'monterrey':
        return 'Monterrey';
      default:
        return 'Zona de Cobertura';
    }
  }

  /// Verificar si una dirección está en una zona específica
  static bool isAddressInZone({
    required Address address,
    required String zoneId,
  }) {
    final zoneInfo = _coverageZones[zoneId];
    if (zoneInfo == null) return false;
    
    final distance = AddressService.calculateDistance(
      lat1: zoneInfo['center_lat']!,
      lng1: zoneInfo['center_lng']!,
      lat2: address.latitude,
      lng2: address.longitude,
    );
    
    return distance <= zoneInfo['radius']!;
  }

  /// Obtener la zona más cercana a una dirección
  static String? getNearestZone({
    required double latitude,
    required double longitude,
  }) {
    String? nearestZone;
    double minDistance = double.infinity;
    
    for (final entry in _coverageZones.entries) {
      final zoneInfo = entry.value;
      final distance = AddressService.calculateDistance(
        lat1: zoneInfo['center_lat']!,
        lng1: zoneInfo['center_lng']!,
        lat2: latitude,
        lng2: longitude,
      );
      
      if (distance < minDistance) {
        minDistance = distance;
        nearestZone = entry.key;
      }
    }
    
    return nearestZone;
  }
}

/// Resultado de validación de cobertura
class CoverageResult {
  final bool isSuccess;
  final bool isError;
  final bool isOutOfCoverage;
  final String message;
  final double? distance;
  final double? deliveryFee;
  final int? estimatedTime;
  final double? maxDistance;
  final String? coverageZone;

  const CoverageResult._({
    required this.isSuccess,
    required this.isError,
    required this.isOutOfCoverage,
    required this.message,
    this.distance,
    this.deliveryFee,
    this.estimatedTime,
    this.maxDistance,
    this.coverageZone,
  });

  factory CoverageResult.success({
    required double distance,
    required double deliveryFee,
    required int estimatedTime,
    String? coverageZone,
  }) {
    return CoverageResult._(
      isSuccess: true,
      isError: false,
      isOutOfCoverage: false,
      message: 'Dirección dentro del área de cobertura',
      distance: distance,
      deliveryFee: deliveryFee,
      estimatedTime: estimatedTime,
      coverageZone: coverageZone,
    );
  }

  factory CoverageResult.outOfCoverage({
    required double distance,
    required double maxDistance,
    required String message,
  }) {
    return CoverageResult._(
      isSuccess: false,
      isError: false,
      isOutOfCoverage: true,
      message: message,
      distance: distance,
      maxDistance: maxDistance,
    );
  }

  factory CoverageResult.error(String message) {
    return CoverageResult._(
      isSuccess: false,
      isError: true,
      isOutOfCoverage: false,
      message: message,
    );
  }

  String get formattedDistance => distance != null 
      ? '${distance!.toStringAsFixed(1)} km' 
      : 'N/A';

  String get formattedDeliveryFee => deliveryFee != null 
      ? '\$${deliveryFee!.toStringAsFixed(2)}' 
      : 'N/A';

  String get formattedEstimatedTime => estimatedTime != null 
      ? '${estimatedTime!} min' 
      : 'N/A';
}

/// Zona de cobertura
class CoverageZone {
  final String id;
  final String name;
  final double centerLatitude;
  final double centerLongitude;
  final double radius;

  const CoverageZone({
    required this.id,
    required this.name,
    required this.centerLatitude,
    required this.centerLongitude,
    required this.radius,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'center_latitude': centerLatitude,
      'center_longitude': centerLongitude,
      'radius': radius,
    };
  }

  factory CoverageZone.fromJson(Map<String, dynamic> json) {
    return CoverageZone(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      centerLatitude: json['center_latitude'] ?? 0.0,
      centerLongitude: json['center_longitude'] ?? 0.0,
      radius: json['radius'] ?? 0.0,
    );
  }
}
