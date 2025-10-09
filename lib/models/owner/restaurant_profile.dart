class RestaurantProfile {
  final int id;
  final String name;
  final String? description;
  final String? logoUrl;
  final String? coverPhotoUrl;
  final String? phone;
  final String? email;
  final String? address;
  final String status;
  final Owner owner;
  final List<RestaurantBranch> branches;
  final RestaurantStatistics statistics;
  final DateTime createdAt;
  final DateTime updatedAt;

  RestaurantProfile({
    required this.id,
    required this.name,
    this.description,
    this.logoUrl,
    this.coverPhotoUrl,
    this.phone,
    this.email,
    this.address,
    required this.status,
    required this.owner,
    required this.branches,
    required this.statistics,
    required this.createdAt,
    required this.updatedAt,
  });

  factory RestaurantProfile.fromJson(Map<String, dynamic> json) {
    return RestaurantProfile(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      logoUrl: json['logoUrl'],
      coverPhotoUrl: json['coverPhotoUrl'],
      phone: json['phone'],
      email: json['email'],
      address: json['address'],
      status: json['status'],
      owner: Owner.fromJson(json['owner']),
      branches: (json['branches'] as List)
          .map((b) => RestaurantBranch.fromJson(b))
          .toList(),
      statistics: RestaurantStatistics.fromJson(json['statistics']),
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'logoUrl': logoUrl,
      'coverPhotoUrl': coverPhotoUrl,
      'phone': phone,
      'email': email,
      'address': address,
      'status': status,
      'owner': owner.toJson(),
      'branches': branches.map((b) => b.toJson()).toList(),
      'statistics': statistics.toJson(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}

class Owner {
  final int id;
  final String name;
  final String lastname;
  final String email;
  final String phone;

  Owner({
    required this.id,
    required this.name,
    required this.lastname,
    required this.email,
    required this.phone,
  });

  String get fullName => '$name $lastname';

  factory Owner.fromJson(Map<String, dynamic> json) {
    return Owner(
      id: json['id'],
      name: json['name'],
      lastname: json['lastname'],
      email: json['email'],
      phone: json['phone'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'lastname': lastname,
      'email': email,
      'phone': phone,
    };
  }
}

class RestaurantBranch {
  final int id;
  final String name;
  final String address;
  final String? phone;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;

  RestaurantBranch({
    required this.id,
    required this.name,
    required this.address,
    this.phone,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  factory RestaurantBranch.fromJson(Map<String, dynamic> json) {
    return RestaurantBranch(
      id: json['id'],
      name: json['name'],
      address: json['address'],
      phone: json['phone'],
      status: json['status'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'phone': phone,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}

class RestaurantStatistics {
  final int totalBranches;
  final int totalSubcategories;
  final int totalProducts;

  RestaurantStatistics({
    required this.totalBranches,
    required this.totalSubcategories,
    required this.totalProducts,
  });

  factory RestaurantStatistics.fromJson(Map<String, dynamic> json) {
    return RestaurantStatistics(
      totalBranches: json['totalBranches'],
      totalSubcategories: json['totalSubcategories'],
      totalProducts: json['totalProducts'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalBranches': totalBranches,
      'totalSubcategories': totalSubcategories,
      'totalProducts': totalProducts,
    };
  }
}

class UploadImageResponse {
  final String? logoUrl;
  final String? coverPhotoUrl;
  final String filename;
  final String originalName;
  final int size;
  final String mimetype;

  UploadImageResponse({
    this.logoUrl,
    this.coverPhotoUrl,
    required this.filename,
    required this.originalName,
    required this.size,
    required this.mimetype,
  });

  factory UploadImageResponse.fromJson(Map<String, dynamic> json) {
    return UploadImageResponse(
      logoUrl: json['logoUrl'],
      coverPhotoUrl: json['coverPhotoUrl'],
      filename: json['filename'],
      originalName: json['originalName'],
      size: json['size'],
      mimetype: json['mimetype'],
    );
  }
}
