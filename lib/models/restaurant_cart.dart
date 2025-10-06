import 'cart_item.dart';

class RestaurantCart {
  final int restaurantId;
  final String restaurantName;
  final String restaurantImage;
  final List<CartItem> items;

  RestaurantCart({
    required this.restaurantId,
    required this.restaurantName,
    required this.restaurantImage,
    required this.items,
  });

  factory RestaurantCart.fromJson(Map<String, dynamic> json) {
    // El backend devuelve: {id, restaurant: {id, name, logoUrl}, items: [...]}
    final restaurant = json['restaurant'] as Map<String, dynamic>? ?? {};
    
    return RestaurantCart(
      restaurantId: restaurant['id'] ?? json['restaurantId'] ?? json['restaurant_id'] ?? 0,
      restaurantName: restaurant['name'] ?? json['restaurantName'] ?? json['restaurant_name'] ?? '',
      restaurantImage: restaurant['logoUrl'] ?? restaurant['logo_url'] ?? json['restaurantImage'] ?? json['restaurant_image'] ?? '',
      items: (json['items'] as List<dynamic>? ?? [])
          .map((item) => CartItem.fromJson(item))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'restaurantId': restaurantId,
      'restaurantName': restaurantName,
      'restaurantImage': restaurantImage,
      'items': items.map((item) => item.toJson()).toList(),
    };
  }

  // Obtener subtotal del restaurante
  double get subtotal {
    return items.fold(0.0, (sum, item) => sum + item.subtotal);
  }

  // Obtener cantidad total de items
  int get totalItems {
    return items.fold(0, (sum, item) => sum + item.quantity);
  }

  // Verificar si el carrito del restaurante está vacío
  bool get isEmpty => items.isEmpty;

  // Verificar si el carrito del restaurante no está vacío
  bool get isNotEmpty => items.isNotEmpty;

  // Obtener item por productId
  CartItem? getItemByProductId(int productId) {
    try {
      return items.firstWhere((item) => item.productId == productId);
    } catch (e) {
      return null;
    }
  }

  // Verificar si un producto está en el carrito
  bool hasProduct(int productId) {
    return items.any((item) => item.productId == productId);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is RestaurantCart && other.restaurantId == restaurantId;
  }

  @override
  int get hashCode => restaurantId.hashCode;

  @override
  String toString() {
    return 'RestaurantCart(restaurantId: $restaurantId, restaurantName: $restaurantName, totalItems: $totalItems, subtotal: \$${subtotal.toStringAsFixed(2)})';
  }
}
