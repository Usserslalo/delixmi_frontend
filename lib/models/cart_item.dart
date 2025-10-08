import 'cart_modifier.dart';

class CartItem {
  final int id;
  final int productId;
  final int restaurantId;
  final String productName;
  final String productDescription;
  final String productImage;
  final double price;
  final int quantity;
  final String? specialInstructions;
  final List<CartModifier> modifiers;

  CartItem({
    required this.id,
    required this.productId,
    required this.restaurantId,
    required this.productName,
    required this.productDescription,
    required this.productImage,
    required this.price,
    required this.quantity,
    this.specialInstructions,
    this.modifiers = const [],
  });

  factory CartItem.fromJson(Map<String, dynamic> json) {
    // El backend devuelve: {id, product: {id, name, description, imageUrl, price, restaurant}, quantity, priceAtAdd, subtotal, modifiers}
    final product = json['product'] as Map<String, dynamic>? ?? {};
    final productRestaurant = product['restaurant'] as Map<String, dynamic>? ?? {};
    
    // Parsear modificadores si existen
    List<CartModifier> modifiers = [];
    if (json['modifiers'] != null && json['modifiers'] is List) {
      modifiers = (json['modifiers'] as List<dynamic>)
          .map((modifier) => CartModifier.fromJson(modifier))
          .toList();
    }
    
    return CartItem(
      id: json['id'] ?? 0,
      productId: product['id'] ?? json['productId'] ?? json['product_id'] ?? 0,
      restaurantId: productRestaurant['id'] ?? json['restaurantId'] ?? json['restaurant_id'] ?? 0,
      productName: product['name'] ?? json['productName'] ?? json['product_name'] ?? '',
      productDescription: product['description'] ?? json['productDescription'] ?? json['product_description'] ?? '',
      productImage: product['imageUrl'] ?? product['image_url'] ?? json['productImage'] ?? json['product_image'] ?? '',
      // Prioridad: priceAtAdd (precio con modificadores) > subtotal > price > product.price (precio base)
      price: _parseToDouble(json['priceAtAdd'] ?? json['subtotal'] ?? json['price'] ?? product['price'] ?? 0.0),
      quantity: json['quantity'] ?? 0,
      specialInstructions: json['specialInstructions'] ?? json['special_instructions'],
      modifiers: modifiers,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'quantity': quantity,
      if (specialInstructions != null) 'specialInstructions': specialInstructions,
      if (modifiers.isNotEmpty) 'modifiers': modifiers.map((m) => m.toJson()).toList(),
    };
  }

  CartItem copyWith({
    int? id,
    int? productId,
    int? restaurantId,
    String? productName,
    String? productDescription,
    String? productImage,
    double? price,
    int? quantity,
    String? specialInstructions,
    List<CartModifier>? modifiers,
  }) {
    return CartItem(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      restaurantId: restaurantId ?? this.restaurantId,
      productName: productName ?? this.productName,
      productDescription: productDescription ?? this.productDescription,
      productImage: productImage ?? this.productImage,
      price: price ?? this.price,
      quantity: quantity ?? this.quantity,
      specialInstructions: specialInstructions ?? this.specialInstructions,
      modifiers: modifiers ?? this.modifiers,
    );
  }

  double get subtotal => price * quantity;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CartItem && other.productId == productId;
  }

  @override
  int get hashCode => productId.hashCode;

  @override
  String toString() {
    return 'CartItem(id: $id, productId: $productId, productName: $productName, quantity: $quantity, price: $price)';
  }

  // Helper para convertir diferentes tipos a double
  static double _parseToDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) {
      return double.tryParse(value) ?? 0.0;
    }
    return 0.0;
  }
}
