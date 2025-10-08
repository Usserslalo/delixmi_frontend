class Product {
  final int id;
  final String name;
  final String? description;
  final double price;
  final String? imageUrl;
  final bool isAvailable;
  final int subcategoryId;
  final List<ModifierGroup> modifierGroups;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Product({
    required this.id,
    required this.name,
    this.description,
    required this.price,
    this.imageUrl,
    required this.isAvailable,
    required this.subcategoryId,
    this.modifierGroups = const [],
    this.createdAt,
    this.updatedAt,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    // Parsear modificadores si existen
    List<ModifierGroup> modifierGroups = [];
    if (json['modifierGroups'] != null && json['modifierGroups'] is List) {
      modifierGroups = (json['modifierGroups'] as List<dynamic>)
          .map((group) => ModifierGroup.fromJson(group))
          .toList();
    }
    
    return Product(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      price: _parsePrice(json['price']),
      imageUrl: json['imageUrl'],
      isAvailable: json['isAvailable'] ?? true,
      subcategoryId: json['subcategoryId'] ?? 0,
      modifierGroups: modifierGroups,
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt']) 
          : null,
      updatedAt: json['updatedAt'] != null 
          ? DateTime.parse(json['updatedAt']) 
          : null,
    );
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

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'imageUrl': imageUrl,
      'isAvailable': isAvailable,
      'subcategoryId': subcategoryId,
      'modifierGroups': modifierGroups.map((group) => group.toJson()).toList(),
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  String get formattedPrice => '\$${price.toStringAsFixed(2)}';
}

class Subcategory {
  final int id;
  final String name;
  final String description;
  final int categoryId;
  final List<Product> products;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Subcategory({
    required this.id,
    required this.name,
    required this.description,
    required this.categoryId,
    required this.products,
    this.createdAt,
    this.updatedAt,
  });

  factory Subcategory.fromJson(Map<String, dynamic> json) {
    return Subcategory(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      categoryId: json['categoryId'] ?? 0,
      products: (json['products'] as List?)
          ?.map((product) => Product.fromJson(product))
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
      'categoryId': categoryId,
      'products': products.map((product) => product.toJson()).toList(),
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }
}

class Category {
  final int id;
  final String name;
  final String description;
  final List<Subcategory> subcategories;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Category({
    required this.id,
    required this.name,
    required this.description,
    required this.subcategories,
    this.createdAt,
    this.updatedAt,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      subcategories: (json['subcategories'] as List?)
          ?.map((subcategory) => Subcategory.fromJson(subcategory))
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
      'subcategories': subcategories.map((subcategory) => subcategory.toJson()).toList(),
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }
}

class RestaurantDetail {
  final int id;
  final String name;
  final String description;
  final String? logoUrl;
  final String? coverPhotoUrl;
  final String status;
  final List<Category> categories;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  RestaurantDetail({
    required this.id,
    required this.name,
    required this.description,
    this.logoUrl,
    this.coverPhotoUrl,
    required this.status,
    required this.categories,
    this.createdAt,
    this.updatedAt,
  });

  factory RestaurantDetail.fromJson(Map<String, dynamic> json) {
    // El backend envía los datos dentro de 'restaurant'
    final restaurantData = json['restaurant'] ?? json;
    
    return RestaurantDetail(
      id: restaurantData['id'] ?? 0,
      name: restaurantData['name'] ?? '',
      description: restaurantData['description'] ?? '',
      logoUrl: restaurantData['logoUrl'],
      coverPhotoUrl: restaurantData['coverPhotoUrl'],
      status: restaurantData['status'] ?? 'active',
      categories: (restaurantData['menu'] as List?)
          ?.map((category) => Category.fromJson(category))
          .toList() ?? [],
      createdAt: restaurantData['createdAt'] != null 
          ? DateTime.parse(restaurantData['createdAt']) 
          : null,
      updatedAt: restaurantData['updatedAt'] != null 
          ? DateTime.parse(restaurantData['updatedAt']) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'logoUrl': logoUrl,
      'coverPhotoUrl': coverPhotoUrl,
      'status': status,
      'categories': categories.map((category) => category.toJson()).toList(),
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  bool get isActive => status == 'active';
}

class ModifierGroup {
  final int id;
  final String name;
  final int minSelection;
  final int maxSelection;
  final List<ModifierOption> options;

  ModifierGroup({
    required this.id,
    required this.name,
    required this.minSelection,
    required this.maxSelection,
    required this.options,
  });

  factory ModifierGroup.fromJson(Map<String, dynamic> json) {
    return ModifierGroup(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      minSelection: json['minSelection'] ?? 0,
      maxSelection: json['maxSelection'] ?? 1,
      options: (json['options'] as List<dynamic>?)
          ?.map((option) => ModifierOption.fromJson(option))
          .toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'minSelection': minSelection,
      'maxSelection': maxSelection,
      'options': options.map((option) => option.toJson()).toList(),
    };
  }

  bool get isRequired => minSelection > 0;
  bool get isSingleSelection => maxSelection == 1;
  bool get isMultipleSelection => maxSelection > 1;
}

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
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      price: _parsePrice(json['price']),
    );
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

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'price': price,
    };
  }

  String get formattedPrice {
    if (price == 0) return '';
    return price > 0 ? '+\$${price.toStringAsFixed(2)}' : '\$${price.abs().toStringAsFixed(2)}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ModifierOption && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
