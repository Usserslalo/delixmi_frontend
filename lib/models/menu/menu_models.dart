/// Categoría Global (de la plataforma)
class Category {
  final int id;
  final String name;
  final String? imageUrl;
  final List<Subcategory> subcategories;

  Category({
    required this.id,
    required this.name,
    this.imageUrl,
    required this.subcategories,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'],
      name: json['name'],
      imageUrl: json['imageUrl'],
      subcategories: (json['subcategories'] as List?)
          ?.map((s) => Subcategory.fromJson(s))
          .toList() ?? [],
    );
  }
}

/// Subcategoría del Restaurante
class Subcategory {
  final int id;
  final String name;
  final int displayOrder;
  final CategoryInfo? category;
  final RestaurantInfo? restaurant;
  final int? productsCount;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Subcategory({
    required this.id,
    required this.name,
    required this.displayOrder,
    this.category,
    this.restaurant,
    this.productsCount,
    this.createdAt,
    this.updatedAt,
  });

  factory Subcategory.fromJson(Map<String, dynamic> json) {
    return Subcategory(
      id: json['id'],
      name: json['name'],
      displayOrder: json['displayOrder'] ?? 0,
      category: json['category'] != null 
          ? CategoryInfo.fromJson(json['category']) 
          : null,
      restaurant: json['restaurant'] != null 
          ? RestaurantInfo.fromJson(json['restaurant']) 
          : null,
      productsCount: json['productsCount'],
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt']) 
          : null,
      updatedAt: json['updatedAt'] != null 
          ? DateTime.parse(json['updatedAt']) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'displayOrder': displayOrder,
      'category': category?.toJson(),
      'restaurant': restaurant?.toJson(),
      'productsCount': productsCount,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }
}

/// Información básica de Categoría
class CategoryInfo {
  final int id;
  final String name;

  CategoryInfo({
    required this.id,
    required this.name,
  });

  factory CategoryInfo.fromJson(Map<String, dynamic> json) {
    return CategoryInfo(
      id: json['id'],
      name: json['name'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }
}

/// Información básica de Restaurante
class RestaurantInfo {
  final int id;
  final String name;

  RestaurantInfo({
    required this.id,
    required this.name,
  });

  factory RestaurantInfo.fromJson(Map<String, dynamic> json) {
    return RestaurantInfo(
      id: json['id'],
      name: json['name'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }
}

/// Grupo de Modificadores
class ModifierGroup {
  final int id;
  final String name;
  final int minSelection;
  final int maxSelection;
  final RestaurantInfo? restaurant;
  final List<ModifierOption> options;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  ModifierGroup({
    required this.id,
    required this.name,
    required this.minSelection,
    required this.maxSelection,
    this.restaurant,
    required this.options,
    this.createdAt,
    this.updatedAt,
  });

  bool get isRequired => minSelection > 0;
  bool get isMultipleSelection => maxSelection > 1;

  factory ModifierGroup.fromJson(Map<String, dynamic> json) {
    return ModifierGroup(
      id: json['id'],
      name: json['name'],
      minSelection: json['minSelection'] ?? 1,
      maxSelection: json['maxSelection'] ?? 1,
      restaurant: json['restaurant'] != null 
          ? RestaurantInfo.fromJson(json['restaurant']) 
          : null,
      options: (json['options'] as List?)
          ?.map((o) => ModifierOption.fromJson(o))
          .toList() ?? [],
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt']) 
          : null,
      updatedAt: json['updatedAt'] != null 
          ? DateTime.parse(json['updatedAt']) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'minSelection': minSelection,
      'maxSelection': maxSelection,
      'restaurant': restaurant?.toJson(),
      'options': options.map((o) => o.toJson()).toList(),
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }
}

/// Opción de Modificador
class ModifierOption {
  final int id;
  final String name;
  final double price;

  ModifierOption({
    required this.id,
    required this.name,
    required this.price,
  });

  factory ModifierOption.fromJson(Map<String, dynamic> json) {
    return ModifierOption(
      id: json['id'],
      name: json['name'],
      price: (json['price'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'price': price,
    };
  }
}

/// Producto del Menú
class MenuProduct {
  final int id;
  final String name;
  final String? description;
  final String? imageUrl;
  final double price;
  final bool isAvailable;
  final String? tags;
  final SubcategoryInfo? subcategory;
  final RestaurantInfo? restaurant;
  final List<ModifierGroup> modifierGroups;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  MenuProduct({
    required this.id,
    required this.name,
    this.description,
    this.imageUrl,
    required this.price,
    required this.isAvailable,
    this.tags,
    this.subcategory,
    this.restaurant,
    required this.modifierGroups,
    this.createdAt,
    this.updatedAt,
  });

  factory MenuProduct.fromJson(Map<String, dynamic> json) {
    return MenuProduct(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      imageUrl: json['imageUrl'],
      price: (json['price'] as num).toDouble(),
      isAvailable: json['isAvailable'] ?? true,
      tags: json['tags'],
      subcategory: json['subcategory'] != null 
          ? SubcategoryInfo.fromJson(json['subcategory']) 
          : null,
      restaurant: json['restaurant'] != null 
          ? RestaurantInfo.fromJson(json['restaurant']) 
          : null,
      modifierGroups: (json['modifierGroups'] as List?)
          ?.map((g) => ModifierGroup.fromJson(g))
          .toList() ?? [],
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt']) 
          : null,
      updatedAt: json['updatedAt'] != null 
          ? DateTime.parse(json['updatedAt']) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'imageUrl': imageUrl,
      'price': price,
      'isAvailable': isAvailable,
      'tags': tags,
      'subcategory': subcategory?.toJson(),
      'restaurant': restaurant?.toJson(),
      'modifierGroups': modifierGroups.map((g) => g.toJson()).toList(),
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }
}

/// Información de Subcategoría (para producto)
class SubcategoryInfo {
  final int id;
  final String name;
  final int displayOrder;
  final CategoryInfo? category;

  SubcategoryInfo({
    required this.id,
    required this.name,
    required this.displayOrder,
    this.category,
  });

  factory SubcategoryInfo.fromJson(Map<String, dynamic> json) {
    return SubcategoryInfo(
      id: json['id'],
      name: json['name'],
      displayOrder: json['displayOrder'] ?? 0,
      category: json['category'] != null 
          ? CategoryInfo.fromJson(json['category']) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'displayOrder': displayOrder,
      'category': category?.toJson(),
    };
  }
}
