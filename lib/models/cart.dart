import 'product.dart';
import 'restaurant.dart';

class CartItem {
  final int id;
  final Product product;
  final int quantity;
  final double priceAtAdd;
  final double subtotal;
  final DateTime createdAt;
  final DateTime updatedAt;

  CartItem({
    required this.id,
    required this.product,
    required this.quantity,
    required this.priceAtAdd,
    required this.subtotal,
    required this.createdAt,
    required this.updatedAt,
  });

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      id: json['id'] ?? 0,
      product: Product.fromJson(json['product'] ?? {}),
      quantity: json['quantity'] ?? 0,
      priceAtAdd: _parsePrice(json['priceAtAdd']),
      subtotal: _parsePrice(json['subtotal']),
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt']) 
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null 
          ? DateTime.parse(json['updatedAt']) 
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'product': product.toJson(),
      'quantity': quantity,
      'priceAtAdd': priceAtAdd,
      'subtotal': subtotal,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  static double _parsePrice(dynamic price) {
    if (price == null) return 0.0;
    if (price is double) return price;
    if (price is int) return price.toDouble();
    if (price is String) {
      return double.tryParse(price) ?? 0.0;
    }
    return 0.0;
  }

  CartItem copyWith({
    int? id,
    Product? product,
    int? quantity,
    double? priceAtAdd,
    double? subtotal,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CartItem(
      id: id ?? this.id,
      product: product ?? this.product,
      quantity: quantity ?? this.quantity,
      priceAtAdd: priceAtAdd ?? this.priceAtAdd,
      subtotal: subtotal ?? this.subtotal,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class CartTotals {
  final double subtotal;
  final double deliveryFee;
  final double total;

  CartTotals({
    required this.subtotal,
    required this.deliveryFee,
    required this.total,
  });

  factory CartTotals.fromJson(Map<String, dynamic> json) {
    return CartTotals(
      subtotal: _parsePrice(json['subtotal']),
      deliveryFee: _parsePrice(json['deliveryFee']),
      total: _parsePrice(json['total']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'subtotal': subtotal,
      'deliveryFee': deliveryFee,
      'total': total,
    };
  }

  static double _parsePrice(dynamic price) {
    if (price == null) return 0.0;
    if (price is double) return price;
    if (price is int) return price.toDouble();
    if (price is String) {
      return double.tryParse(price) ?? 0.0;
    }
    return 0.0;
  }

  String get formattedSubtotal => '\$${subtotal.toStringAsFixed(2)}';
  String get formattedDeliveryFee => '\$${deliveryFee.toStringAsFixed(2)}';
  String get formattedTotal => '\$${total.toStringAsFixed(2)}';
}

class Cart {
  final int id;
  final Restaurant restaurant;
  final List<CartItem> items;
  final CartTotals totals;
  final int itemCount;
  final int totalQuantity;
  final DateTime createdAt;
  final DateTime updatedAt;

  Cart({
    required this.id,
    required this.restaurant,
    required this.items,
    required this.totals,
    required this.itemCount,
    required this.totalQuantity,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Cart.fromJson(Map<String, dynamic> json) {
    return Cart(
      id: json['id'] ?? 0,
      restaurant: Restaurant.fromJson(json['restaurant'] ?? {}),
      items: (json['items'] as List?)
          ?.map((item) => CartItem.fromJson(item))
          .toList() ?? [],
      totals: CartTotals.fromJson(json['totals'] ?? {}),
      itemCount: json['itemCount'] ?? 0,
      totalQuantity: json['totalQuantity'] ?? 0,
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt']) 
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null 
          ? DateTime.parse(json['updatedAt']) 
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'restaurant': restaurant.toJson(),
      'items': items.map((item) => item.toJson()).toList(),
      'totals': totals.toJson(),
      'itemCount': itemCount,
      'totalQuantity': totalQuantity,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  bool get isEmpty => items.isEmpty;
  bool get isNotEmpty => items.isNotEmpty;
}

class CartSummary {
  final int totalCarts;
  final int activeRestaurants;
  final int totalItems;
  final int totalQuantity;
  final double subtotal;
  final double estimatedDeliveryFee;
  final double estimatedTotal;

  CartSummary({
    required this.totalCarts,
    required this.activeRestaurants,
    required this.totalItems,
    required this.totalQuantity,
    required this.subtotal,
    required this.estimatedDeliveryFee,
    required this.estimatedTotal,
  });

  factory CartSummary.fromJson(Map<String, dynamic> json) {
    return CartSummary(
      totalCarts: json['totalCarts'] ?? 0,
      activeRestaurants: json['activeRestaurants'] ?? 0,
      totalItems: json['totalItems'] ?? 0,
      totalQuantity: json['totalQuantity'] ?? 0,
      subtotal: _parsePrice(json['subtotal']),
      estimatedDeliveryFee: _parsePrice(json['estimatedDeliveryFee']),
      estimatedTotal: _parsePrice(json['estimatedTotal']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalCarts': totalCarts,
      'activeRestaurants': activeRestaurants,
      'totalItems': totalItems,
      'totalQuantity': totalQuantity,
      'subtotal': subtotal,
      'estimatedDeliveryFee': estimatedDeliveryFee,
      'estimatedTotal': estimatedTotal,
    };
  }

  static double _parsePrice(dynamic price) {
    if (price == null) return 0.0;
    if (price is double) return price;
    if (price is int) return price.toDouble();
    if (price is String) {
      return double.tryParse(price) ?? 0.0;
    }
    return 0.0;
  }

  String get formattedSubtotal => '\$${subtotal.toStringAsFixed(2)}';
  String get formattedEstimatedDeliveryFee => '\$${estimatedDeliveryFee.toStringAsFixed(2)}';
  String get formattedEstimatedTotal => '\$${estimatedTotal.toStringAsFixed(2)}';

  bool get isEmpty => totalItems == 0;
  bool get isNotEmpty => totalItems > 0;
}

class CartResponse {
  final List<Cart> carts;
  final CartSummary summary;
  final DateTime retrievedAt;

  CartResponse({
    required this.carts,
    required this.summary,
    required this.retrievedAt,
  });

  factory CartResponse.fromJson(Map<String, dynamic> json) {
    return CartResponse(
      carts: (json['carts'] as List?)
          ?.map((cart) => Cart.fromJson(cart))
          .toList() ?? [],
      summary: CartSummary.fromJson(json['summary'] ?? {}),
      retrievedAt: json['retrievedAt'] != null 
          ? DateTime.parse(json['retrievedAt']) 
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'carts': carts.map((cart) => cart.toJson()).toList(),
      'summary': summary.toJson(),
      'retrievedAt': retrievedAt.toIso8601String(),
    };
  }

  bool get isEmpty => carts.isEmpty;
  bool get isNotEmpty => carts.isNotEmpty;
}
