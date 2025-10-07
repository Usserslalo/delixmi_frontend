import 'package:flutter/foundation.dart';

class Order {
  final String id;
  final String orderNumber;
  final String status;
  final String paymentMethod;
  final String paymentStatus;
  final double subtotal;
  final double deliveryFee;
  final double serviceFee;
  final double total;
  final String? specialInstructions;
  final DateTime orderPlacedAt;
  final DateTime? estimatedDeliveryAt;
  final String? estimatedDeliveryTime;
  final OrderRestaurant restaurant;
  final OrderAddress deliveryAddress;
  final List<OrderItem> items;
  final String? customerName;
  final DateTime createdAt;

  Order({
    required this.id,
    required this.orderNumber,
    required this.status,
    required this.paymentMethod,
    required this.paymentStatus,
    required this.subtotal,
    required this.deliveryFee,
    required this.serviceFee,
    required this.total,
    this.specialInstructions,
    required this.orderPlacedAt,
    this.estimatedDeliveryAt,
    this.estimatedDeliveryTime,
    required this.restaurant,
    required this.deliveryAddress,
    required this.items,
    this.customerName,
    required this.createdAt,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    try {
      debugPrint('🔍 Order.fromJson: Parseando JSON: $json');
      
      // Manejar tanto la estructura del historial como la de detalles
      final orderData = json.containsKey('order') ? json['order'] : json;
      
      debugPrint('🔍 Order.fromJson: OrderData: $orderData');
      
      // Parsear restaurant
      final restaurantData = orderData['restaurant'] as Map<String, dynamic>? ?? {};
      debugPrint('🔍 Order.fromJson: Restaurant data: $restaurantData');
      
      // Parsear deliveryAddress
      final addressData = orderData['deliveryAddress'] as Map<String, dynamic>? ?? {};
      debugPrint('🔍 Order.fromJson: Address data: $addressData');
      
      // Parsear items
      final itemsData = orderData['items'] as List<dynamic>? ?? [];
      debugPrint('🔍 Order.fromJson: Items data: $itemsData');
      
      final order = Order(
        id: orderData['id']?.toString() ?? '',
        orderNumber: orderData['orderNumber'] ?? '',
        status: orderData['status'] ?? 'pending',
        paymentMethod: orderData['paymentMethod'] ?? 'cash',
        paymentStatus: orderData['paymentStatus'] ?? 'pending',
        subtotal: (orderData['subtotal'] ?? 0.0).toDouble(),
        deliveryFee: (orderData['deliveryFee'] ?? 0.0).toDouble(),
        serviceFee: (orderData['serviceFee'] ?? 0.0).toDouble(),
        total: (orderData['total'] ?? 0.0).toDouble(),
        specialInstructions: orderData['specialInstructions'],
        orderPlacedAt: orderData['orderPlacedAt'] != null 
            ? DateTime.parse(orderData['orderPlacedAt']) 
            : DateTime.now(),
        estimatedDeliveryAt: orderData['estimatedDeliveryTime'] != null && orderData['estimatedDeliveryTime']['estimatedDeliveryAt'] != null
            ? DateTime.parse(orderData['estimatedDeliveryTime']['estimatedDeliveryAt'])
            : null,
        estimatedDeliveryTime: orderData['estimatedDeliveryTime'] != null 
            ? (orderData['estimatedDeliveryTime'] is String 
                ? orderData['estimatedDeliveryTime']
                : orderData['estimatedDeliveryTime']['timeRange'])
            : null,
        restaurant: OrderRestaurant.fromJson(restaurantData),
        deliveryAddress: OrderAddress.fromJson(addressData),
        items: itemsData.map((item) => OrderItem.fromJson(item)).toList(),
        customerName: orderData['customerName'],
        createdAt: orderData['createdAt'] != null 
            ? DateTime.parse(orderData['createdAt']) 
            : DateTime.now(),
      );
      
      debugPrint('✅ Order.fromJson: Order creado exitosamente - ID: ${order.id}');
      return order;
    } catch (e) {
      debugPrint('❌ Order.fromJson: Error parseando Order: $e');
      debugPrint('❌ Order.fromJson: Stack trace: ${StackTrace.current}');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'orderNumber': orderNumber,
      'status': status,
      'paymentMethod': paymentMethod,
      'paymentStatus': paymentStatus,
      'subtotal': subtotal,
      'deliveryFee': deliveryFee,
      'serviceFee': serviceFee,
      'total': total,
      'specialInstructions': specialInstructions,
      'orderPlacedAt': orderPlacedAt.toIso8601String(),
      'estimatedDeliveryAt': estimatedDeliveryAt?.toIso8601String(),
      'estimatedDeliveryTime': estimatedDeliveryTime,
      'restaurant': restaurant.toJson(),
      'deliveryAddress': deliveryAddress.toJson(),
      'items': items.map((item) => item.toJson()).toList(),
    };
  }

  /// Estado del pedido en español
  String get statusDisplayName {
    switch (status) {
      case 'pending':
        return 'Pendiente';
      case 'confirmed':
        return 'Confirmado';
      case 'preparing':
        return 'En preparación';
      case 'ready_for_pickup':
        return 'Listo para recoger';
      case 'out_for_delivery':
        return 'En camino';
      case 'delivered':
        return 'Entregado';
      case 'cancelled':
        return 'Cancelado';
      case 'refunded':
        return 'Reembolsado';
      default:
        return 'Desconocido';
    }
  }

  /// Estado del pago en español
  String get paymentStatusDisplayName {
    switch (paymentStatus) {
      case 'pending':
        return 'Pendiente';
      case 'processing':
        return 'Procesando';
      case 'completed':
        return 'Completado';
      case 'failed':
        return 'Fallido';
      case 'cancelled':
        return 'Cancelado';
      case 'refunded':
        return 'Reembolsado';
      default:
        return 'Desconocido';
    }
  }

  /// Verificar si el pedido puede ser cancelado
  bool get canBeCancelled {
    return status == 'pending' || status == 'confirmed';
  }

  /// Verificar si el pedido está en progreso
  bool get isInProgress {
    return status == 'confirmed' || 
           status == 'preparing' || 
           status == 'ready_for_pickup' || 
           status == 'out_for_delivery';
  }

  /// Verificar si el pedido está completado
  bool get isCompleted {
    return status == 'delivered';
  }

  /// Verificar si el pedido está cancelado
  bool get isCancelled {
    return status == 'cancelled' || status == 'refunded';
  }
}

class OrderRestaurant {
  final int id;
  final String name;
  final String? logoUrl;
  final OrderBranch branch;

  OrderRestaurant({
    required this.id,
    required this.name,
    this.logoUrl,
    required this.branch,
  });

  factory OrderRestaurant.fromJson(Map<String, dynamic> json) {
    try {
      debugPrint('🔍 OrderRestaurant.fromJson: Parseando: $json');
      
      final branchData = json['branch'] as Map<String, dynamic>? ?? {};
      debugPrint('🔍 OrderRestaurant.fromJson: Branch data: $branchData');
      
      final restaurant = OrderRestaurant(
        id: json['id'] ?? 0,
        name: json['name'] ?? '',
        logoUrl: json['logoUrl'],
        branch: OrderBranch.fromJson(branchData),
      );
      
      debugPrint('✅ OrderRestaurant.fromJson: Creado exitosamente - ${restaurant.name}');
      return restaurant;
    } catch (e) {
      debugPrint('❌ OrderRestaurant.fromJson: Error: $e');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'logoUrl': logoUrl,
      'branch': branch.toJson(),
    };
  }
}

class OrderBranch {
  final int id;
  final String name;
  final String address;
  final String phone;

  OrderBranch({
    required this.id,
    required this.name,
    required this.address,
    required this.phone,
  });

  factory OrderBranch.fromJson(Map<String, dynamic> json) {
    try {
      debugPrint('🔍 OrderBranch.fromJson: Parseando: $json');
      
      final branch = OrderBranch(
        id: json['id'] ?? 0,
        name: json['name'] ?? '',
        address: json['address'] ?? '',
        phone: json['phone'] ?? '',
      );
      
      debugPrint('✅ OrderBranch.fromJson: Creado exitosamente - ${branch.name}');
      return branch;
    } catch (e) {
      debugPrint('❌ OrderBranch.fromJson: Error: $e');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'phone': phone,
    };
  }
}

class OrderAddress {
  final int id;
  final String alias;
  final String street;
  final String exteriorNumber;
  final String? interiorNumber;
  final String neighborhood;
  final String city;
  final String state;
  final String zipCode;
  final double? latitude;
  final double? longitude;

  OrderAddress({
    required this.id,
    required this.alias,
    required this.street,
    required this.exteriorNumber,
    this.interiorNumber,
    required this.neighborhood,
    required this.city,
    required this.state,
    required this.zipCode,
    this.latitude,
    this.longitude,
  });

  factory OrderAddress.fromJson(Map<String, dynamic> json) {
    try {
      debugPrint('🔍 OrderAddress.fromJson: Parseando: $json');
      
      final address = OrderAddress(
        id: json['id'] ?? 0,
        alias: json['alias'] ?? '',
        street: json['street'] ?? '',
        exteriorNumber: json['exteriorNumber'] ?? '',
        interiorNumber: json['interiorNumber'],
        neighborhood: json['neighborhood'] ?? '',
        city: json['city'] ?? '',
        state: json['state'] ?? '',
        zipCode: json['zipCode'] ?? '',
        latitude: json['latitude']?.toDouble(),
        longitude: json['longitude']?.toDouble(),
      );
      
      debugPrint('✅ OrderAddress.fromJson: Creado exitosamente - ${address.alias}');
      return address;
    } catch (e) {
      debugPrint('❌ OrderAddress.fromJson: Error: $e');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'alias': alias,
      'street': street,
      'exteriorNumber': exteriorNumber,
      'interiorNumber': interiorNumber,
      'neighborhood': neighborhood,
      'city': city,
      'state': state,
      'zipCode': zipCode,
      'latitude': latitude,
      'longitude': longitude,
    };
  }

  String get fullAddress {
    final parts = [
      street,
      exteriorNumber,
      if (interiorNumber != null && interiorNumber!.isNotEmpty) 'Int. $interiorNumber',
      neighborhood,
      city,
      state,
      zipCode,
    ];
    return parts.where((part) => part.isNotEmpty).join(', ');
  }
}

class OrderItem {
  final String id;
  final int quantity;
  final double pricePerUnit;
  final double subtotal;
  final OrderProduct product;

  OrderItem({
    required this.id,
    required this.quantity,
    required this.pricePerUnit,
    required this.subtotal,
    required this.product,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      id: json['id']?.toString() ?? '',
      quantity: json['quantity'] ?? 0,
      pricePerUnit: (json['pricePerUnit'] ?? 0.0).toDouble(),
      subtotal: (json['subtotal'] ?? 0.0).toDouble(),
      product: OrderProduct.fromJson(json['product'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'quantity': quantity,
      'pricePerUnit': pricePerUnit,
      'subtotal': subtotal,
      'product': product.toJson(),
    };
  }
}

class OrderProduct {
  final int id;
  final String name;
  final String? imageUrl;

  OrderProduct({
    required this.id,
    required this.name,
    this.imageUrl,
  });

  factory OrderProduct.fromJson(Map<String, dynamic> json) {
    return OrderProduct(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      imageUrl: json['imageUrl'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'imageUrl': imageUrl,
    };
  }
}

/// Estados de pedidos disponibles
class OrderStatus {
  static const String pending = 'pending';
  static const String confirmed = 'confirmed';
  static const String preparing = 'preparing';
  static const String readyForPickup = 'ready_for_pickup';
  static const String outForDelivery = 'out_for_delivery';
  static const String delivered = 'delivered';
  static const String cancelled = 'cancelled';
  static const String refunded = 'refunded';
}

/// Estados de pago disponibles
class PaymentStatus {
  static const String pending = 'pending';
  static const String processing = 'processing';
  static const String completed = 'completed';
  static const String failed = 'failed';
  static const String cancelled = 'cancelled';
  static const String refunded = 'refunded';
}
