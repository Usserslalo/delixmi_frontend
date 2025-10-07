class User {
  final String id;
  final String name;
  final String lastname;
  final String email;
  final String phone;
  final String status;
  final List<UserRole> roles;
  final DateTime? createdAt;

  User({
    required this.id,
    required this.name,
    required this.lastname,
    required this.email,
    required this.phone,
    required this.status,
    required this.roles,
    this.createdAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      lastname: json['lastname'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      status: json['status'] ?? 'pending',
      roles: (json['roles'] as List?)
          ?.map((role) => UserRole.fromJson(role))
          .toList() ?? [],
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt']) 
          : null,
    );
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
