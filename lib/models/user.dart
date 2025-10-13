class User {
  final String id;
  final String name;
  final String lastname;
  final String email;
  final String phone;
  final String status;
  final List<UserRole> roles;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime? emailVerifiedAt;
  final DateTime? phoneVerifiedAt;

  User({
    required this.id,
    required this.name,
    required this.lastname,
    required this.email,
    required this.phone,
    required this.status,
    required this.roles,
    this.createdAt,
    this.updatedAt,
    this.emailVerifiedAt,
    this.phoneVerifiedAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    
    final user = User(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      lastname: json['lastname'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '', // Campo phone puede estar ausente
      status: json['status'] ?? 'pending',
      roles: (json['roles'] as List?)
          ?.map((role) => UserRole.fromJson(role))
          .toList() ?? [],
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt']) 
          : null,
      updatedAt: json['updatedAt'] != null 
          ? DateTime.parse(json['updatedAt']) 
          : null,
      emailVerifiedAt: json['emailVerifiedAt'] != null 
          ? DateTime.parse(json['emailVerifiedAt']) 
          : null,
      phoneVerifiedAt: json['phoneVerifiedAt'] != null 
          ? DateTime.parse(json['phoneVerifiedAt']) 
          : null,
    );
    
    
    return user;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'lastname': lastname,
      'email': email,
      'phone': phone,
      'status': status,
      'roles': roles.map((role) => role.toJson()).toList(),
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'emailVerifiedAt': emailVerifiedAt?.toIso8601String(),
      'phoneVerifiedAt': phoneVerifiedAt?.toIso8601String(),
    };
  }

  String get fullName => '$name $lastname';
  
  bool get isActive => status == 'active';
  bool get isPending => status == 'pending';
  bool get isInactive => status == 'inactive';
  
  bool get isCustomer => roles.any((role) => role.roleName == 'customer');
  bool get isRestaurantOwner => roles.any((role) => 
      ['owner', 'branch_manager', 'order_manager', 'kitchen_staff'].contains(role.roleName));
  bool get isAdmin => roles.any((role) => role.roleName == 'admin');
  
  // Getters para verificación
  bool get isEmailVerified => emailVerifiedAt != null;
  bool get isPhoneVerified => phoneVerifiedAt != null;
  
  // Getter para iniciales del avatar
  String get initials {
    final firstInitial = name.isNotEmpty ? name[0].toUpperCase() : '';
    final lastInitial = lastname.isNotEmpty ? lastname[0].toUpperCase() : '';
    return firstInitial + lastInitial;
  }
  
  // Getter para antigüedad del cliente
  String get memberSince {
    if (createdAt == null) return 'Cliente';
    final now = DateTime.now();
    final difference = now.difference(createdAt!);
    final months = (difference.inDays / 30).floor();
    
    if (months < 1) return 'Cliente nuevo';
    if (months < 12) return 'Cliente desde hace $months ${months == 1 ? 'mes' : 'meses'}';
    
    final years = (months / 12).floor();
    return 'Cliente desde hace $years ${years == 1 ? 'año' : 'años'}';
  }
}

class UserRole {
  final String roleId;
  final String roleName;
  final String roleDisplayName;
  final String? restaurantId;
  final String? branchId;

  UserRole({
    required this.roleId,
    required this.roleName,
    required this.roleDisplayName,
    this.restaurantId,
    this.branchId,
  });

  factory UserRole.fromJson(Map<String, dynamic> json) {
    return UserRole(
      roleId: json['roleId']?.toString() ?? '',
      roleName: json['roleName'] ?? '',
      roleDisplayName: json['roleDisplayName'] ?? '',
      restaurantId: json['restaurantId']?.toString(),
      branchId: json['branchId']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'roleId': roleId,
      'roleName': roleName,
      'roleDisplayName': roleDisplayName,
      'restaurantId': restaurantId,
      'branchId': branchId,
    };
  }
}
