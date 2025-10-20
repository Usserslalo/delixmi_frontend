class Employee {
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
  final RoleInfo? role;
  final RestaurantInfo? restaurant;
  final int? assignmentId; // ID of the UserRoleAssignment for updates

  Employee({
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
    this.role,
    this.restaurant,
    this.assignmentId,
  });

  factory Employee.fromJson(Map<String, dynamic> json) {
    // According to the updated documentation, the backend now includes assignmentId
    // which is the ID of the UserRoleAssignment and is critical for PATCH operations
    
    return Employee(
      id: json['id'] as int,
      name: json['name'] as String,
      lastname: json['lastname'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String,
      status: json['status'] as String,
      emailVerifiedAt: json['emailVerifiedAt'] != null 
          ? DateTime.parse(json['emailVerifiedAt'] as String)
          : null,
      phoneVerifiedAt: json['phoneVerifiedAt'] != null 
          ? DateTime.parse(json['phoneVerifiedAt'] as String)
          : null,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      role: json['role'] != null 
          ? RoleInfo.fromJson(json['role'] as Map<String, dynamic>)
          : null,
      restaurant: json['restaurant'] != null 
          ? RestaurantInfo.fromJson(json['restaurant'] as Map<String, dynamic>)
          : null,
      assignmentId: json['assignmentId'] as int?,
    );
  }

  String get fullName => '$name $lastname';
  
  bool get isActive => status == 'active';
  bool get isInactive => status == 'inactive';
  bool get isSuspended => status == 'suspended';

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
      'role': role?.toJson(),
      'restaurant': restaurant?.toJson(),
      'assignmentId': assignmentId,
    };
  }
}

class RoleInfo {
  final int id;
  final String name;
  final String displayName;
  final String? description;

  RoleInfo({
    required this.id,
    required this.name,
    required this.displayName,
    this.description,
  });

  factory RoleInfo.fromJson(Map<String, dynamic> json) {
    return RoleInfo(
      id: json['id'] as int,
      name: json['name'] as String,
      displayName: json['displayName'] as String,
      description: json['description'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'displayName': displayName,
      'description': description,
    };
  }
}

class RestaurantInfo {
  final int id;
  final String name;

  RestaurantInfo({
    required this.id,
    required this.name,
  });

  factory RestaurantInfo.fromJson(Map<String, dynamic> json) {
    return RestaurantInfo(
      id: json['id'] as int,
      name: json['name'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }
}

class PaginationInfo {
  final int currentPage;
  final int pageSize;
  final int totalItems;
  final int totalPages;
  final bool hasNextPage;
  final bool hasPrevPage;
  final int? nextPage;
  final int? prevPage;

  PaginationInfo({
    required this.currentPage,
    required this.pageSize,
    required this.totalItems,
    required this.totalPages,
    required this.hasNextPage,
    required this.hasPrevPage,
    this.nextPage,
    this.prevPage,
  });

  factory PaginationInfo.fromJson(Map<String, dynamic> json) {
    return PaginationInfo(
      currentPage: json['currentPage'] as int,
      pageSize: json['pageSize'] as int,
      totalItems: json['totalItems'] as int,
      totalPages: json['totalPages'] as int,
      hasNextPage: json['hasNextPage'] as bool,
      hasPrevPage: json['hasPrevPage'] as bool,
      nextPage: json['nextPage'] as int?,
      prevPage: json['prevPage'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'currentPage': currentPage,
      'pageSize': pageSize,
      'totalItems': totalItems,
      'totalPages': totalPages,
      'hasNextPage': hasNextPage,
      'hasPrevPage': hasPrevPage,
      'nextPage': nextPage,
      'prevPage': prevPage,
    };
  }
}

class EmployeeListResponse {
  final List<Employee> employees;
  final PaginationInfo pagination;

  EmployeeListResponse({
    required this.employees,
    required this.pagination,
  });

  factory EmployeeListResponse.fromJson(Map<String, dynamic> json) {
    final employeesData = json['employees'] as List<dynamic>;
    final paginationData = json['pagination'] as Map<String, dynamic>;
    
    return EmployeeListResponse(
      employees: employeesData
          .map((employeeJson) => Employee.fromJson(employeeJson as Map<String, dynamic>))
          .toList(),
      pagination: PaginationInfo.fromJson(paginationData),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'employees': employees.map((e) => e.toJson()).toList(),
      'pagination': pagination.toJson(),
    };
  }
}

/// Valid employee roles based on the documentation
class ValidEmployeeRoles {
  static const List<Map<String, dynamic>> roles = [
    {
      'id': 5,
      'name': 'branch_manager',
      'displayName': 'Gerente de Sucursal',
      'description': 'Gestiona las operaciones diarias de una sucursal específica.',
    },
    {
      'id': 6,
      'name': 'order_manager',
      'displayName': 'Gestor de Pedidos',
      'description': 'Acepta y gestiona los pedidos entrantes en una sucursal.',
    },
    {
      'id': 7,
      'name': 'kitchen_staff',
      'displayName': 'Personal de Cocina',
      'description': 'Prepara y gestiona los pedidos de cocina.',
    },
    {
      'id': 9,
      'name': 'driver_restaurant',
      'displayName': 'Repartidor de Restaurante',
      'description': 'Realiza entregas de pedidos del restaurante.',
    },
  ];

  static List<RoleInfo> get roleList => roles
      .map((roleData) => RoleInfo.fromJson(roleData))
      .toList();

  static bool isValidRoleId(int roleId) {
    return roles.any((role) => role['id'] == roleId);
  }

  static RoleInfo? getRoleById(int roleId) {
    try {
      final roleData = roles.firstWhere((role) => role['id'] == roleId);
      return RoleInfo.fromJson(roleData);
    } catch (e) {
      return null;
    }
  }
}
