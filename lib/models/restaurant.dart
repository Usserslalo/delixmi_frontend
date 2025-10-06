class Restaurant {
  final int id;
  final String name;
  final String description;
  final String? logoUrl;
  final String? coverPhotoUrl;
  final String status;
  final double? rating;
  final int? deliveryTime;
  final double? deliveryFee;
  final String? currency;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Restaurant({
    required this.id,
    required this.name,
    required this.description,
    this.logoUrl,
    this.coverPhotoUrl,
    required this.status,
    this.rating,
    this.deliveryTime,
    this.deliveryFee,
    this.currency = 'MXN',
    this.createdAt,
    this.updatedAt,
  });

  factory Restaurant.fromJson(Map<String, dynamic> json) {
    return Restaurant(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      logoUrl: json['logoUrl'],
      coverPhotoUrl: json['coverPhotoUrl'],
      status: json['status'] ?? 'active',
      rating: json['rating']?.toDouble(),
      deliveryTime: json['deliveryTime'],
      deliveryFee: json['deliveryFee']?.toDouble(),
      currency: json['currency'] ?? 'MXN',
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
      'logoUrl': logoUrl,
      'coverPhotoUrl': coverPhotoUrl,
      'status': status,
      'rating': rating,
      'deliveryTime': deliveryTime,
      'deliveryFee': deliveryFee,
      'currency': currency,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  bool get isActive => status == 'active';
  bool get isInactive => status == 'inactive';
  
  String get formattedRating => rating != null ? rating!.toStringAsFixed(1) : 'N/A';
  String get formattedDeliveryTime => deliveryTime != null ? '${deliveryTime}-${deliveryTime! + 5} min' : 'N/A';
  String get formattedDeliveryFee => deliveryFee != null ? '\$${deliveryFee!.toStringAsFixed(2)} $currency' : 'Gratis';
}

class RestaurantListResponse {
  final List<Restaurant> restaurants;
  final Pagination pagination;

  RestaurantListResponse({
    required this.restaurants,
    required this.pagination,
  });

  factory RestaurantListResponse.fromJson(Map<String, dynamic> json) {
    return RestaurantListResponse(
      restaurants: (json['restaurants'] as List?)
          ?.map((restaurant) => Restaurant.fromJson(restaurant))
          .toList() ?? [],
      pagination: Pagination.fromJson(json['pagination'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'restaurants': restaurants.map((restaurant) => restaurant.toJson()).toList(),
      'pagination': pagination.toJson(),
    };
  }
}

class Pagination {
  final int totalRestaurants;
  final int currentPage;
  final int pageSize;
  final int totalPages;
  final bool hasNextPage;
  final bool hasPrevPage;

  Pagination({
    required this.totalRestaurants,
    required this.currentPage,
    required this.pageSize,
    required this.totalPages,
    required this.hasNextPage,
    required this.hasPrevPage,
  });

  factory Pagination.fromJson(Map<String, dynamic> json) {
    return Pagination(
      totalRestaurants: json['totalRestaurants'] ?? 0,
      currentPage: json['currentPage'] ?? 1,
      pageSize: json['pageSize'] ?? 10,
      totalPages: json['totalPages'] ?? 1,
      hasNextPage: json['hasNextPage'] ?? false,
      hasPrevPage: json['hasPrevPage'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalRestaurants': totalRestaurants,
      'currentPage': currentPage,
      'pageSize': pageSize,
      'totalPages': totalPages,
      'hasNextPage': hasNextPage,
      'hasPrevPage': hasPrevPage,
    };
  }
}
