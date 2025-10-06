class CheckoutRequest {
  final int addressId;
  final bool useCart;
  final int? restaurantId;
  final List<CheckoutItem>? items;
  final String? specialInstructions;
  final String? paymentMethod;

  CheckoutRequest({
    required this.addressId,
    required this.useCart,
    this.restaurantId,
    this.items,
    this.specialInstructions,
    this.paymentMethod,
  });

  Map<String, dynamic> toJson() {
    return {
      'addressId': addressId,
      'useCart': useCart,
      if (restaurantId != null) 'restaurantId': restaurantId,
      if (items != null) 'items': items!.map((item) => item.toJson()).toList(),
      if (specialInstructions != null) 'specialInstructions': specialInstructions,
      if (paymentMethod != null) 'paymentMethod': paymentMethod,
    };
  }
}

class CheckoutItem {
  final int productId;
  final int quantity;

  CheckoutItem({
    required this.productId,
    required this.quantity,
  });

  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'quantity': quantity,
    };
  }
}

class CheckoutResponse {
  final String status;
  final String message;
  final CheckoutData? data;

  CheckoutResponse({
    required this.status,
    required this.message,
    this.data,
  });

  factory CheckoutResponse.fromJson(Map<String, dynamic> json) {
    return CheckoutResponse(
      status: json['status'] ?? '',
      message: json['message'] ?? '',
      data: json['data'] != null ? CheckoutData.fromJson(json['data']) : null,
    );
  }

  bool get isSuccess => status == 'success';
}

class CheckoutData {
  final String initPoint;
  final String preferenceId;
  final String orderId;
  final double total;
  final String currency;
  final DateTime createdAt;

  CheckoutData({
    required this.initPoint,
    required this.preferenceId,
    required this.orderId,
    required this.total,
    required this.currency,
    required this.createdAt,
  });

  factory CheckoutData.fromJson(Map<String, dynamic> json) {
    return CheckoutData(
      initPoint: json['init_point'] ?? '',
      preferenceId: json['preference_id'] ?? '',
      orderId: json['order_id'] ?? '',
      total: _parseDouble(json['total']),
      currency: json['currency'] ?? 'MXN',
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at']) 
          : DateTime.now(),
    );
  }

  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) {
      return double.tryParse(value) ?? 0.0;
    }
    return 0.0;
  }

  String get formattedTotal => '\$${total.toStringAsFixed(2)}';
}

class PaymentStatus {
  final String status;
  final String message;
  final PaymentData? data;

  PaymentStatus({
    required this.status,
    required this.message,
    this.data,
  });

  factory PaymentStatus.fromJson(Map<String, dynamic> json) {
    return PaymentStatus(
      status: json['status'] ?? '',
      message: json['message'] ?? '',
      data: json['data'] != null ? PaymentData.fromJson(json['data']) : null,
    );
  }

  bool get isSuccess => status == 'success';
}

class PaymentData {
  final String orderId;
  final String paymentId;
  final String status;
  final double amount;
  final String currency;
  final DateTime createdAt;
  final DateTime? updatedAt;

  PaymentData({
    required this.orderId,
    required this.paymentId,
    required this.status,
    required this.amount,
    required this.currency,
    required this.createdAt,
    this.updatedAt,
  });

  factory PaymentData.fromJson(Map<String, dynamic> json) {
    return PaymentData(
      orderId: json['order_id'] ?? '',
      paymentId: json['payment_id'] ?? '',
      status: json['status'] ?? '',
      amount: _parseDouble(json['amount']),
      currency: json['currency'] ?? 'MXN',
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at']) 
          : DateTime.now(),
      updatedAt: json['updated_at'] != null 
          ? DateTime.parse(json['updated_at']) 
          : null,
    );
  }

  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) {
      return double.tryParse(value) ?? 0.0;
    }
    return 0.0;
  }

  String get formattedAmount => '\$${amount.toStringAsFixed(2)}';

  bool get isPaid => status == 'approved';
  bool get isPending => status == 'pending';
  bool get isRejected => status == 'rejected';
  bool get isCancelled => status == 'cancelled';
}

class ShippingCalculation {
  final double distance;
  final double baseFee;
  final double perKmFee;
  final double totalFee;
  final int estimatedTime;

  ShippingCalculation({
    required this.distance,
    required this.baseFee,
    required this.perKmFee,
    required this.totalFee,
    required this.estimatedTime,
  });

  factory ShippingCalculation.fromJson(Map<String, dynamic> json) {
    return ShippingCalculation(
      distance: _parseDouble(json['distance']),
      baseFee: _parseDouble(json['base_fee']),
      perKmFee: _parseDouble(json['per_km_fee']),
      totalFee: _parseDouble(json['total_fee']),
      estimatedTime: json['estimated_time'] ?? 0,
    );
  }

  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) {
      return double.tryParse(value) ?? 0.0;
    }
    return 0.0;
  }

  String get formattedDistance => '${distance.toStringAsFixed(1)} km';
  String get formattedTotalFee => '\$${totalFee.toStringAsFixed(2)}';
  String get formattedEstimatedTime => '${estimatedTime} min';
}

enum PaymentMethod {
  cash('Efectivo'),
  card('Tarjeta');

  const PaymentMethod(this.displayName);
  final String displayName;
}

enum CheckoutStep {
  address('Dirección'),
  payment('Pago'),
  confirmation('Confirmación');

  const CheckoutStep(this.displayName);
  final String displayName;
}
