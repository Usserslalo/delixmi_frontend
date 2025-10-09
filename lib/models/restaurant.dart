class Restaurant {
  final int id;
  final int ownerId;
  final String name;
  final String? description;
  final String? logoUrl;
  final String? coverPhotoUrl;
  final double commissionRate;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final double? rating;
  final int? deliveryTime;
  final double? deliveryFee;
  final bool? isOpen; // Indica si el restaurante está abierto según horarios
  final String? category; // Categoría del restaurante (Pizzas, Sushi, Tacos, etc.)
  final double? minDistance; // Distancia mínima a la sucursal más cercana (solo con coordenadas)

  Restaurant({
    required this.id,
    required this.ownerId,
    required this.name,
    this.description,
    this.logoUrl,
    this.coverPhotoUrl,
    required this.commissionRate,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.rating,
    this.deliveryTime,
    this.deliveryFee,
    this.isOpen,
    this.category,
    this.minDistance,
  });

  factory Restaurant.fromJson(Map<String, dynamic> json) {
    final logoUrl = json['logoUrl'] ?? json['logo_url'];
    final coverPhotoUrl = json['coverPhotoUrl'] ?? json['cover_photo_url'];
    
    // Debug logs para verificar URLs de imágenes y estado
    final isOpenValue = json['isOpen'] ?? json['is_open'];
    print('🖼️ Restaurant ${json['name']}:');
    print('   Logo URL: $logoUrl');
    print('   Cover URL: $coverPhotoUrl');
    print('   isOpen: $isOpenValue (${isOpenValue.runtimeType})');
    
    return Restaurant(
      id: json['id'] ?? 0,
      ownerId: json['owner_id'] ?? 0,
      name: json['name'] ?? '',
      description: json['description'],
      logoUrl: logoUrl,
      coverPhotoUrl: coverPhotoUrl,
      commissionRate: (json['commission_rate'] ?? 0.0).toDouble(),
      status: json['status'] ?? 'pending_approval',
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updated_at'] ?? DateTime.now().toIso8601String()),
      rating: json['rating']?.toDouble(),
      deliveryTime: json['delivery_time'],
      deliveryFee: json['delivery_fee']?.toDouble(),
      // Usar el campo isOpen real del backend
      isOpen: isOpenValue,
      category: json['category'],
      minDistance: json['minDistance'] != null ? (json['minDistance'] as num).toDouble() : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'owner_id': ownerId,
      'name': name,
      'description': description,
      'logo_url': logoUrl,
      'cover_photo_url': coverPhotoUrl,
      'commission_rate': commissionRate,
      'status': status,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'rating': rating,
      'delivery_time': deliveryTime,
      'delivery_fee': deliveryFee,
      'isOpen': isOpen,
      'category': category,
    };
  }

  Restaurant copyWith({
    int? id,
    int? ownerId,
    String? name,
    String? description,
    String? logoUrl,
    String? coverPhotoUrl,
    double? commissionRate,
    String? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    double? rating,
    int? deliveryTime,
    double? deliveryFee,
    bool? isOpen,
    String? category,
  }) {
    return Restaurant(
      id: id ?? this.id,
      ownerId: ownerId ?? this.ownerId,
      name: name ?? this.name,
      description: description ?? this.description,
      logoUrl: logoUrl ?? this.logoUrl,
      coverPhotoUrl: coverPhotoUrl ?? this.coverPhotoUrl,
      commissionRate: commissionRate ?? this.commissionRate,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rating: rating ?? this.rating,
      deliveryTime: deliveryTime ?? this.deliveryTime,
      deliveryFee: deliveryFee ?? this.deliveryFee,
      isOpen: isOpen ?? this.isOpen,
      category: category ?? this.category,
    );
  }

  @override
  String toString() {
    return 'Restaurant(id: $id, name: $name, status: $status)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Restaurant && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  // Getters para el restaurant_card
  String get formattedRating => rating != null ? rating!.toStringAsFixed(1) : 'N/A';
  String get formattedDeliveryTime => deliveryTime != null ? '$deliveryTime min' : 'N/A';
  String get formattedDeliveryFee => deliveryFee != null ? '\$${deliveryFee!.toStringAsFixed(2)}' : 'N/A';
  
  // Getter para verificar si el restaurante está abierto
  // Usa el campo isOpen real del backend
  bool get isCurrentlyOpen => isOpen ?? false;
}