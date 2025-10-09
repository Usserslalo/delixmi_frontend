class Branch {
  final int id;
  final int restaurantId;
  final String name;
  final String address;
  final double latitude;
  final double longitude;
  final String? phone;
  final String? openingTime;
  final String? closingTime;
  final bool usesPlatformDrivers;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final double? distance; // Distancia en km desde la ubicación del usuario

  Branch({
    required this.id,
    required this.restaurantId,
    required this.name,
    required this.address,
    required this.latitude,
    required this.longitude,
    this.phone,
    this.openingTime,
    this.closingTime,
    required this.usesPlatformDrivers,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.distance,
  });

  factory Branch.fromJson(Map<String, dynamic> json) {
    return Branch(
      id: json['id'] ?? 0,
      restaurantId: json['restaurant_id'] ?? 0,
      name: json['name'] ?? '',
      address: json['address'] ?? '',
      latitude: (json['latitude'] ?? 0.0).toDouble(),
      longitude: (json['longitude'] ?? 0.0).toDouble(),
      phone: json['phone'],
      openingTime: json['opening_time'],
      closingTime: json['closing_time'],
      usesPlatformDrivers: json['uses_platform_drivers'] ?? false,
      status: json['status'] ?? 'active',
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updated_at'] ?? DateTime.now().toIso8601String()),
      distance: json['distance'] != null ? (json['distance'] as num).toDouble() : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'restaurant_id': restaurantId,
      'name': name,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'phone': phone,
      'opening_time': openingTime,
      'closing_time': closingTime,
      'uses_platform_drivers': usesPlatformDrivers,
      'status': status,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'distance': distance,
    };
  }

  Branch copyWith({
    int? id,
    int? restaurantId,
    String? name,
    String? address,
    double? latitude,
    double? longitude,
    String? phone,
    String? openingTime,
    String? closingTime,
    bool? usesPlatformDrivers,
    String? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    double? distance,
  }) {
    return Branch(
      id: id ?? this.id,
      restaurantId: restaurantId ?? this.restaurantId,
      name: name ?? this.name,
      address: address ?? this.address,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      phone: phone ?? this.phone,
      openingTime: openingTime ?? this.openingTime,
      closingTime: closingTime ?? this.closingTime,
      usesPlatformDrivers: usesPlatformDrivers ?? this.usesPlatformDrivers,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      distance: distance ?? this.distance,
    );
  }

  @override
  String toString() {
    return 'Branch(id: $id, name: $name, address: $address)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Branch && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
