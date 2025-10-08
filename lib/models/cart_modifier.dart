class CartModifier {
  final int id;
  final String name;
  final double price;
  final CartModifierGroup group;

  CartModifier({
    required this.id,
    required this.name,
    required this.price,
    required this.group,
  });

  factory CartModifier.fromJson(Map<String, dynamic> json) {
    return CartModifier(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      price: _parseToDouble(json['price'] ?? 0.0),
      group: CartModifierGroup.fromJson(json['group'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'group': group.toJson(),
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CartModifier && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'CartModifier(id: $id, name: $name, price: \$${price.toStringAsFixed(2)}, group: ${group.name})';
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

class CartModifierGroup {
  final int id;
  final String name;

  CartModifierGroup({
    required this.id,
    required this.name,
  });

  factory CartModifierGroup.fromJson(Map<String, dynamic> json) {
    return CartModifierGroup(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CartModifierGroup && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'CartModifierGroup(id: $id, name: $name)';
  }
}
