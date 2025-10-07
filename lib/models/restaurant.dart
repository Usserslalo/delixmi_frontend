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
  });

  factory Restaurant.fromJson(Map<String, dynamic> json) {
    return Restaurant(
      id: json['id'] ?? 0,
      ownerId: json['owner_id'] ?? 0,
      name: json['name'] ?? '',
      description: json['description'],
      logoUrl: json['logo_url'],
      coverPhotoUrl: json['cover_photo_url'],
      commissionRate: (json['commission_rate'] ?? 0.0).toDouble(),
      status: json['status'] ?? 'pending_approval',
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updated_at'] ?? DateTime.now().toIso8601String()),
      rating: json['rating']?.toDouble(),
      deliveryTime: json['delivery_time'],
      deliveryFee: json['delivery_fee']?.toDouble(),
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
}