class BranchSchedule {
  final int id;
  final int branchId;
  final int dayOfWeek; // 0 = Domingo, 1 = Lunes, ..., 6 = Sábado
  final String dayName;
  final String openingTime; // Formato HH:MM:SS
  final String closingTime; // Formato HH:MM:SS
  final bool isClosed;

  BranchSchedule({
    required this.id,
    required this.branchId,
    required this.dayOfWeek,
    required this.dayName,
    required this.openingTime,
    required this.closingTime,
    required this.isClosed,
  });

  factory BranchSchedule.fromJson(Map<String, dynamic> json) {
    return BranchSchedule(
      id: json['id'] ?? 0,
      branchId: json['branchId'] ?? json['branch_id'] ?? 0,
      dayOfWeek: json['dayOfWeek'] ?? json['day_of_week'] ?? 0,
      dayName: json['dayName'] ?? json['day_name'] ?? _getDayName(json['dayOfWeek'] ?? json['day_of_week'] ?? 0),
      openingTime: json['openingTime'] ?? json['opening_time'] ?? '09:00:00',
      closingTime: json['closingTime'] ?? json['closing_time'] ?? '22:00:00',
      isClosed: json['isClosed'] ?? json['is_closed'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'branchId': branchId,
      'dayOfWeek': dayOfWeek,
      'dayName': dayName,
      'openingTime': openingTime,
      'closingTime': closingTime,
      'isClosed': isClosed,
    };
  }

  Map<String, dynamic> toUpdateJson() {
    return {
      'dayOfWeek': dayOfWeek,
      'openingTime': openingTime,
      'closingTime': closingTime,
      'isClosed': isClosed,
    };
  }

  static String _getDayName(int dayOfWeek) {
    const days = [
      'Domingo',
      'Lunes', 
      'Martes',
      'Miércoles',
      'Jueves',
      'Viernes',
      'Sábado'
    ];
    return days[dayOfWeek >= 0 && dayOfWeek <= 6 ? dayOfWeek : 0];
  }

  BranchSchedule copyWith({
    int? id,
    int? branchId,
    int? dayOfWeek,
    String? dayName,
    String? openingTime,
    String? closingTime,
    bool? isClosed,
  }) {
    return BranchSchedule(
      id: id ?? this.id,
      branchId: branchId ?? this.branchId,
      dayOfWeek: dayOfWeek ?? this.dayOfWeek,
      dayName: dayName ?? this.dayName,
      openingTime: openingTime ?? this.openingTime,
      closingTime: closingTime ?? this.closingTime,
      isClosed: isClosed ?? this.isClosed,
    );
  }

  @override
  String toString() {
    return 'BranchSchedule(id: $id, dayOfWeek: $dayOfWeek, dayName: $dayName, isClosed: $isClosed)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is BranchSchedule && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

class BranchScheduleInfo {
  final int id;
  final String name;
  final BranchRestaurantInfo restaurant;

  BranchScheduleInfo({
    required this.id,
    required this.name,
    required this.restaurant,
  });

  factory BranchScheduleInfo.fromJson(Map<String, dynamic> json) {
    return BranchScheduleInfo(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      restaurant: BranchRestaurantInfo.fromJson(json['restaurant'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'restaurant': restaurant.toJson(),
    };
  }
}

class BranchRestaurantInfo {
  final int id;
  final String name;

  BranchRestaurantInfo({
    required this.id,
    required this.name,
  });

  factory BranchRestaurantInfo.fromJson(Map<String, dynamic> json) {
    return BranchRestaurantInfo(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }
}
