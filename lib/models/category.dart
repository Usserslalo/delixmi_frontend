class Category {
  final int id;
  final String name;
  final String description;
  final String? icon;
  final String? emoji;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  
  // Nuevos campos opcionales del backend optimizado
  final String? displayName; // Nombre para mostrar (alias de name)
  final int? restaurantCount; // Cantidad de restaurantes en esta categoría

  Category({
    required this.id,
    required this.name,
    required this.description,
    this.icon,
    this.emoji,
    required this.isActive,
    this.createdAt,
    this.updatedAt,
    // Nuevos campos opcionales
    this.displayName,
    this.restaurantCount,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      icon: json['icon'],
      emoji: json['emoji'],
      isActive: json['isActive'] ?? true,
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt']) 
          : null,
      updatedAt: json['updatedAt'] != null 
          ? DateTime.parse(json['updatedAt']) 
          : null,
      // Nuevos campos opcionales (compatibles con backend optimizado)
      displayName: json['displayName'],
      restaurantCount: json['restaurantCount'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'icon': icon,
      'emoji': emoji,
      'isActive': isActive,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      // Nuevos campos opcionales
      'displayName': displayName,
      'restaurantCount': restaurantCount,
    };
  }
  
  // Getter para el nombre a mostrar (displayName o name como fallback)
  String get displayNameOrName => displayName ?? name;
  
  // Getter para verificar si tiene restaurantes
  bool get hasRestaurants => restaurantCount != null && restaurantCount! > 0;
  
  // Getter para el texto de cantidad de restaurantes
  String get restaurantCountText => restaurantCount != null ? '(${restaurantCount!})' : '';

  // Categorías predefinidas para el diseño
  static List<Category> get defaultCategories => [
    Category(
      id: 1,
      name: 'Pizzas',
      description: 'Pizzas clásicas y especialidades',
      emoji: '🍕',
      isActive: true,
    ),
    Category(
      id: 2,
      name: 'Tacos',
      description: 'Tacos auténticos mexicanos',
      emoji: '🌮',
      isActive: true,
    ),
    Category(
      id: 3,
      name: 'Hamburguesas',
      description: 'Hamburguesas gourmet',
      emoji: '🍔',
      isActive: true,
    ),
    Category(
      id: 4,
      name: 'Sushi',
      description: 'Sushi fresco y creativo',
      emoji: '🍣',
      isActive: true,
    ),
    Category(
      id: 5,
      name: 'Postres',
      description: 'Dulces y postres',
      emoji: '🍰',
      isActive: true,
    ),
    Category(
      id: 6,
      name: 'Bebidas',
      description: 'Bebidas y refrescos',
      emoji: '🍺',
      isActive: true,
    ),
  ];
}
