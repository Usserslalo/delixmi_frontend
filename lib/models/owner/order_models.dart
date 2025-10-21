import 'package:flutter/material.dart';

class OrderCustomer {
  final int id;
  final String name;
  final String lastname;
  final String fullName;
  final String email;
  final String phone;

  OrderCustomer({
    required this.id,
    required this.name,
    required this.lastname,
    required this.fullName,
    required this.email,
    required this.phone,
  });

  factory OrderCustomer.fromJson(Map<String, dynamic> json) {
    return OrderCustomer(
      id: json['id'] as int,
      name: json['name'] as String,
      lastname: json['lastname'] as String,
      fullName: json['fullName'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String,
    );
  }
}

class OrderAddress {
  final int id;
  final String alias;
  final String street;
  final String? exteriorNumber;
  final String? interiorNumber;
  final String neighborhood;
  final String city;
  final String state;
  final String zipCode;
  final String? references;
  final String fullAddress;

  OrderAddress({
    required this.id,
    required this.alias,
    required this.street,
    this.exteriorNumber,
    this.interiorNumber,
    required this.neighborhood,
    required this.city,
    required this.state,
    required this.zipCode,
    this.references,
    required this.fullAddress,
  });

  factory OrderAddress.fromJson(Map<String, dynamic> json) {
    return OrderAddress(
      id: json['id'] as int,
      alias: json['alias'] as String,
      street: json['street'] as String,
      exteriorNumber: json['exteriorNumber'] as String?,
      interiorNumber: json['interiorNumber'] as String?,
      neighborhood: json['neighborhood'] as String,
      city: json['city'] as String,
      state: json['state'] as String,
      zipCode: json['zipCode'] as String,
      references: json['references'] as String?,
      fullAddress: json['fullAddress'] as String,
    );
  }
}

class OrderDeliveryDriver {
  final int id;
  final String name;
  final String lastname;
  final String phone;

  OrderDeliveryDriver({
    required this.id,
    required this.name,
    required this.lastname,
    required this.phone,
  });

  factory OrderDeliveryDriver.fromJson(Map<String, dynamic> json) {
    return OrderDeliveryDriver(
      id: json['id'] as int,
      name: json['name'] as String,
      lastname: json['lastname'] as String,
      phone: json['phone'] as String,
    );
  }
}

class OrderPayment {
  final String id;
  final String status;
  final String provider;
  final String? providerPaymentId;
  final double amount;
  final String currency;

  OrderPayment({
    required this.id,
    required this.status,
    required this.provider,
    this.providerPaymentId,
    required this.amount,
    required this.currency,
  });

  factory OrderPayment.fromJson(Map<String, dynamic> json) {
    return OrderPayment(
      id: json['id'].toString(),
      status: json['status'] as String,
      provider: json['provider'] as String,
      providerPaymentId: json['providerPaymentId'] as String?,
      amount: (json['amount'] as num).toDouble(),
      currency: json['currency'] as String,
    );
  }
}

class OrderModifierOption {
  final int id;
  final String name;
  final double price;
  final OrderModifierGroup modifierGroup;

  OrderModifierOption({
    required this.id,
    required this.name,
    required this.price,
    required this.modifierGroup,
  });

  factory OrderModifierOption.fromJson(Map<String, dynamic> json) {
    return OrderModifierOption(
      id: json['id'] as int,
      name: json['name'] as String,
      price: (json['price'] as num).toDouble(),
      modifierGroup: OrderModifierGroup.fromJson(json['modifierGroup'] as Map<String, dynamic>),
    );
  }
}

class OrderModifierGroup {
  final int id;
  final String name;

  OrderModifierGroup({
    required this.id,
    required this.name,
  });

  factory OrderModifierGroup.fromJson(Map<String, dynamic> json) {
    return OrderModifierGroup(
      id: json['id'] as int,
      name: json['name'] as String,
    );
  }
}

class OrderModifier {
  final String id;
  final OrderModifierOption modifierOption;

  OrderModifier({
    required this.id,
    required this.modifierOption,
  });

  factory OrderModifier.fromJson(Map<String, dynamic> json) {
    return OrderModifier(
      id: json['id'].toString(),
      modifierOption: OrderModifierOption.fromJson(json['modifierOption'] as Map<String, dynamic>),
    );
  }
}

class OrderProduct {
  final int id;
  final String name;
  final String? imageUrl;
  final double price;

  OrderProduct({
    required this.id,
    required this.name,
    this.imageUrl,
    required this.price,
  });

  factory OrderProduct.fromJson(Map<String, dynamic> json) {
    return OrderProduct(
      id: json['id'] as int,
      name: json['name'] as String,
      imageUrl: json['imageUrl'] as String?,
      price: (json['price'] as num).toDouble(),
    );
  }
}

class OrderItem {
  final String id;
  final int productId;
  final int quantity;
  final double pricePerUnit;
  final OrderProduct product;
  final List<OrderModifier> modifiers;

  OrderItem({
    required this.id,
    required this.productId,
    required this.quantity,
    required this.pricePerUnit,
    required this.product,
    required this.modifiers,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      id: json['id'].toString(),
      productId: json['productId'] as int,
      quantity: json['quantity'] as int,
      pricePerUnit: (json['pricePerUnit'] as num).toDouble(),
      product: OrderProduct.fromJson(json['product'] as Map<String, dynamic>),
      modifiers: (json['modifiers'] as List<dynamic>)
          .map((modifier) => OrderModifier.fromJson(modifier as Map<String, dynamic>))
          .toList(),
    );
  }
}

class Order {
  final String id;
  final String status;
  final double subtotal;
  final double deliveryFee;
  final double total;
  final double commissionRateSnapshot;
  final double platformFee;
  final double restaurantPayout;
  final String paymentMethod;
  final String paymentStatus;
  final String? specialInstructions;
  final DateTime orderPlacedAt;
  final DateTime? orderDeliveredAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  final OrderCustomer customer;
  final OrderAddress address;
  final OrderDeliveryDriver? deliveryDriver;
  final OrderPayment payment;
  final List<OrderItem> orderItems;

  Order({
    required this.id,
    required this.status,
    required this.subtotal,
    required this.deliveryFee,
    required this.total,
    required this.commissionRateSnapshot,
    required this.platformFee,
    required this.restaurantPayout,
    required this.paymentMethod,
    required this.paymentStatus,
    this.specialInstructions,
    required this.orderPlacedAt,
    this.orderDeliveredAt,
    required this.createdAt,
    required this.updatedAt,
    required this.customer,
    required this.address,
    this.deliveryDriver,
    required this.payment,
    required this.orderItems,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'].toString(),
      status: json['status'] as String,
      subtotal: (json['subtotal'] as num).toDouble(),
      deliveryFee: (json['deliveryFee'] as num).toDouble(),
      total: (json['total'] as num).toDouble(),
      commissionRateSnapshot: (json['commissionRateSnapshot'] as num).toDouble(),
      platformFee: (json['platformFee'] as num).toDouble(),
      restaurantPayout: (json['restaurantPayout'] as num).toDouble(),
      paymentMethod: json['paymentMethod'] as String,
      paymentStatus: json['paymentStatus'] as String,
      specialInstructions: json['specialInstructions'] as String?,
      orderPlacedAt: DateTime.parse(json['orderPlacedAt'] as String),
      orderDeliveredAt: json['orderDeliveredAt'] != null 
          ? DateTime.parse(json['orderDeliveredAt'] as String) 
          : null,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      customer: OrderCustomer.fromJson(json['customer'] as Map<String, dynamic>),
      address: OrderAddress.fromJson(json['address'] as Map<String, dynamic>),
      deliveryDriver: json['deliveryDriver'] != null 
          ? OrderDeliveryDriver.fromJson(json['deliveryDriver'] as Map<String, dynamic>)
          : null,
      payment: OrderPayment.fromJson(json['payment'] as Map<String, dynamic>),
      orderItems: (json['orderItems'] as List<dynamic>)
          .map((item) => OrderItem.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }

  /// Estado del pedido en español para mostrar en UI
  String get statusDisplayName {
    switch (status) {
      case 'pending':
        return 'Pendiente';
      case 'confirmed':
        return 'Confirmado';
      case 'preparing':
        return 'Preparando';
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
        return status;
    }
  }

  /// Color del estado para mostrar en UI
  Color get statusColor {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'confirmed':
        return Colors.blue;
      case 'preparing':
        return Colors.purple;
      case 'ready_for_pickup':
        return Colors.green;
      case 'out_for_delivery':
        return Colors.blue;
      case 'delivered':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      case 'refunded':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  /// Icono del estado para mostrar en UI
  IconData get statusIcon {
    switch (status) {
      case 'pending':
        return Icons.hourglass_empty;
      case 'confirmed':
        return Icons.check_circle_outline;
      case 'preparing':
        return Icons.restaurant;
      case 'ready_for_pickup':
        return Icons.check_circle;
      case 'out_for_delivery':
        return Icons.delivery_dining;
      case 'delivered':
        return Icons.done_all;
      case 'cancelled':
        return Icons.cancel;
      case 'refunded':
        return Icons.receipt;
      default:
        return Icons.info;
    }
  }

  /// Verifica si el pedido puede ser actualizado
  bool get canBeUpdated {
    return !['delivered', 'cancelled', 'refunded'].contains(status);
  }

  /// Obtiene los siguientes estados posibles
  List<String> get possibleNextStates {
    switch (status) {
      case 'pending':
        return ['confirmed', 'cancelled'];
      case 'confirmed':
        return ['preparing', 'cancelled'];
      case 'preparing':
        return ['ready_for_pickup'];
      case 'ready_for_pickup':
        return ['out_for_delivery'];
      case 'out_for_delivery':
        return ['delivered'];
      default:
        return [];
    }
  }
}

class OrderPagination {
  final int currentPage;
  final int pageSize;
  final int totalCount;
  final int totalPages;
  final bool hasNextPage;
  final bool hasPreviousPage;

  OrderPagination({
    required this.currentPage,
    required this.pageSize,
    required this.totalCount,
    required this.totalPages,
    required this.hasNextPage,
    required this.hasPreviousPage,
  });

  factory OrderPagination.fromJson(Map<String, dynamic> json) {
    return OrderPagination(
      currentPage: json['currentPage'] as int,
      pageSize: json['pageSize'] as int,
      totalCount: json['totalCount'] as int,
      totalPages: json['totalPages'] as int,
      hasNextPage: json['hasNextPage'] as bool,
      hasPreviousPage: json['hasPreviousPage'] as bool,
    );
  }
}

class OrderListResponse {
  final List<Order> orders;
  final OrderPagination pagination;

  OrderListResponse({
    required this.orders,
    required this.pagination,
  });

  factory OrderListResponse.fromJson(Map<String, dynamic> json) {
    return OrderListResponse(
      orders: (json['orders'] as List<dynamic>)
          .map((order) => Order.fromJson(order as Map<String, dynamic>))
          .toList(),
      pagination: OrderPagination.fromJson(json['pagination'] as Map<String, dynamic>),
    );
  }
}
