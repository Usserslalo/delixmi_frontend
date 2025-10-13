import 'dart:math';
import 'cart_item.dart';
import 'address.dart';

class CheckoutSummary {
  final List<CartItem> items;
  final Address deliveryAddress;
  final double subtotal;
  final double deliveryFee;
  final double serviceFee;
  final double total;
  final String estimatedDeliveryTime;
  final String paymentMethod;

  CheckoutSummary({
    required this.items,
    required this.deliveryAddress,
    required this.subtotal,
    required this.deliveryFee,
    required this.serviceFee,
    required this.total,
    required this.estimatedDeliveryTime,
    this.paymentMethod = 'cash',
  });

  factory CheckoutSummary.fromJson(Map<String, dynamic> json) {
    return CheckoutSummary(
      items: (json['items'] as List<dynamic>? ?? [])
          .map((item) => CartItem.fromJson(item))
          .toList(),
      deliveryAddress: Address.fromJson(json['deliveryAddress'] ?? json['delivery_address'] ?? {}),
      subtotal: (json['subtotal'] ?? 0.0).toDouble(),
      deliveryFee: (json['deliveryFee'] ?? json['delivery_fee'] ?? 0.0).toDouble(),
      serviceFee: (json['serviceFee'] ?? json['service_fee'] ?? 0.0).toDouble(),
      total: (json['total'] ?? 0.0).toDouble(),
      estimatedDeliveryTime: json['estimatedDeliveryTime'] ?? json['estimated_delivery_time'] ?? '30-45 min',
      paymentMethod: json['paymentMethod'] ?? json['payment_method'] ?? 'cash',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'items': items.map((item) => item.toJson()).toList(),
      'deliveryAddress': deliveryAddress.toJson(),
      'subtotal': subtotal,
      'deliveryFee': deliveryFee,
      'serviceFee': serviceFee,
      'total': total,
      'estimatedDeliveryTime': estimatedDeliveryTime,
      'paymentMethod': paymentMethod,
    };
  }

  // Calcular totales
  static CheckoutSummary calculate({
    required List<CartItem> items,
    required Address deliveryAddress,
    double deliveryFee = 20.0, // Valor real del backend
    double serviceFeePercentage = 0.05, // 5%
    String? estimatedDeliveryTime,
    String paymentMethod = 'cash',
  }) {
    final subtotal = items.fold(0.0, (sum, item) => sum + item.subtotal);
    final serviceFee = subtotal * serviceFeePercentage;
    final total = subtotal + deliveryFee + serviceFee;

    // Calcular tiempo estimado basado en la ubicación
    final calculatedDeliveryTime = _calculateDeliveryTime(deliveryAddress);

    return CheckoutSummary(
      items: items,
      deliveryAddress: deliveryAddress,
      subtotal: subtotal,
      deliveryFee: deliveryFee,
      serviceFee: serviceFee,
      total: total,
      estimatedDeliveryTime: estimatedDeliveryTime ?? calculatedDeliveryTime,
      paymentMethod: paymentMethod,
    );
  }

  // Calcular tiempo de entrega basado en la ubicación
  static String _calculateDeliveryTime(Address address) {
    // Coordenadas de referencia (centro de la ciudad)
    const double centerLat = 20.480377;
    const double centerLng = -99.218668;
    
    // Calcular distancia aproximada
    final distance = _calculateDistance(
      centerLat, centerLng,
      address.latitude, address.longitude,
    );
    
    // Tiempo base + tiempo por distancia
    const int baseTime = 20; // 20 minutos base
    final int additionalTime = (distance * 2).round(); // 2 minutos por km
    final int totalMinutes = baseTime + additionalTime;
    
    // Redondear a múltiplos de 5
    final int roundedMinutes = ((totalMinutes / 5).round() * 5);
    
    if (roundedMinutes <= 30) {
      return '25-30 min';
    } else if (roundedMinutes <= 45) {
      return '30-45 min';
    } else if (roundedMinutes <= 60) {
      return '45-60 min';
    } else {
      return '60+ min';
    }
  }

  // Calcular distancia entre dos puntos (fórmula de Haversine)
  static double _calculateDistance(double lat1, double lng1, double lat2, double lng2) {
    const double earthRadius = 6371; // Radio de la Tierra en kilómetros
    
    final double dLat = _degreesToRadians(lat2 - lat1);
    final double dLng = _degreesToRadians(lng2 - lng1);
    
    final double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(lat1 * pi / 180) *
        cos(lat2 * pi / 180) *
        sin(dLng / 2) * sin(dLng / 2);
    
    final double c = 2 * asin(sqrt(a));
    
    return earthRadius * c;
  }

  static double _degreesToRadians(double degrees) {
    return degrees * (pi / 180);
  }

  CheckoutSummary copyWith({
    List<CartItem>? items,
    Address? deliveryAddress,
    double? subtotal,
    double? deliveryFee,
    double? serviceFee,
    double? total,
    String? estimatedDeliveryTime,
    String? paymentMethod,
  }) {
    return CheckoutSummary(
      items: items ?? this.items,
      deliveryAddress: deliveryAddress ?? this.deliveryAddress,
      subtotal: subtotal ?? this.subtotal,
      deliveryFee: deliveryFee ?? this.deliveryFee,
      serviceFee: serviceFee ?? this.serviceFee,
      total: total ?? this.total,
      estimatedDeliveryTime: estimatedDeliveryTime ?? this.estimatedDeliveryTime,
      paymentMethod: paymentMethod ?? this.paymentMethod,
    );
  }

  @override
  String toString() {
    return 'CheckoutSummary(subtotal: \$${subtotal.toStringAsFixed(2)}, deliveryFee: \$${deliveryFee.toStringAsFixed(2)}, serviceFee: \$${serviceFee.toStringAsFixed(2)}, total: \$${total.toStringAsFixed(2)})';
  }
}
