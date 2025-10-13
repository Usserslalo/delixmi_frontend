import 'user_role.dart';

class User {
  final int id;
  final String name;
  final String lastname;
  final String email;
  final String phone;
  final String status;
  final DateTime? emailVerifiedAt;
  final DateTime? phoneVerifiedAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<UserRole> roles;
  
  User({
    required this.id,
    required this.name,
    required this.lastname,
    required this.email,
    required this.phone,
    required this.status,
    this.emailVerifiedAt,
    this.phoneVerifiedAt,
    required this.createdAt,
    required this.updatedAt,
    required this.roles,
  });
  
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'] ?? '',
      lastname: json['lastname'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      status: json['status'] ?? 'pending',
      emailVerifiedAt: json['emailVerifiedAt'] != null
          ? DateTime.parse(json['emailVerifiedAt'])
          : null,
      phoneVerifiedAt: json['phoneVerifiedAt'] != null
          ? DateTime.parse(json['phoneVerifiedAt'])
          : null,
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : DateTime.now(),
      roles: json['roles'] != null && json['roles'] is List
          ? (json['roles'] as List).map((r) => UserRole.fromJson(r)).toList()
          : [],
    );
  }
  
  // Método auxiliar para obtener el rol principal
  UserRole? get primaryRole => roles.isNotEmpty ? roles.first : null;
  
  // Método auxiliar para verificar si tiene un rol específico
  bool hasRole(String roleName) {
    return roles.any((role) => role.roleName == roleName);
  }
  
  // Getters para verificación de estado
  bool get isActive => status == 'active';
  bool get isPending => status == 'pending';
  bool get isInactive => status == 'inactive';
  
  // Getters para verificación de roles (manejan lista vacía de manera segura)
  bool get isCustomer => roles.any((role) => role.roleName == 'customer');
  bool get isRestaurantOwner => roles.any((role) => 
      ['owner', 'branch_manager', 'order_manager', 'kitchen_staff'].contains(role.roleName));
  bool get isAdmin => roles.any((role) => role.roleName == 'admin');
  
  // Getter para verificar si tiene roles asignados
  bool get hasRoles => roles.isNotEmpty;
  
  // Getters para verificación de email/teléfono
  bool get isEmailVerified => emailVerifiedAt != null;
  bool get isPhoneVerified => phoneVerifiedAt != null;
  
  // Getter para nombre completo
  String get fullName => '$name $lastname';
  
  // Getter para iniciales del avatar
  String get initials {
    final firstInitial = name.isNotEmpty ? name[0].toUpperCase() : '';
    final lastInitial = lastname.isNotEmpty ? lastname[0].toUpperCase() : '';
    return firstInitial + lastInitial;
  }
  
  // Getter para antigüedad del cliente
  String get memberSince {
    final now = DateTime.now();
    final difference = now.difference(createdAt);
    final months = (difference.inDays / 30).floor();
    
    if (months < 1) return 'Cliente nuevo';
    if (months < 12) return 'Cliente desde hace $months ${months == 1 ? 'mes' : 'meses'}';
    
    final years = (months / 12).floor();
    return 'Cliente desde hace $years ${years == 1 ? 'año' : 'años'}';
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'lastname': lastname,
      'email': email,
      'phone': phone,
      'status': status,
      'emailVerifiedAt': emailVerifiedAt?.toIso8601String(),
      'phoneVerifiedAt': phoneVerifiedAt?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'roles': roles.map((r) => r.toJson()).toList(),
    };
  }
}
