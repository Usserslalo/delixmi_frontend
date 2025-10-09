class UserRole {
  final int roleId;
  final String roleName;
  final String roleDisplayName;
  final int? restaurantId;
  final int? branchId;
  
  UserRole({
    required this.roleId,
    required this.roleName,
    required this.roleDisplayName,
    this.restaurantId,
    this.branchId,
  });
  
  factory UserRole.fromJson(Map<String, dynamic> json) {
    return UserRole(
      roleId: json['roleId'],
      roleName: json['roleName'],
      roleDisplayName: json['roleDisplayName'],
      restaurantId: json['restaurantId'],
      branchId: json['branchId'],
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
