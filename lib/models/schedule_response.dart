import 'branch_schedule.dart';

class ScheduleResponse {
  final BranchScheduleInfo branch;
  final List<BranchSchedule> schedules;

  ScheduleResponse({
    required this.branch,
    required this.schedules,
  });

  factory ScheduleResponse.fromJson(Map<String, dynamic> json) {
    return ScheduleResponse(
      branch: BranchScheduleInfo.fromJson(json['branch'] ?? {}),
      schedules: (json['schedules'] as List<dynamic>? ?? [])
          .map((schedule) => BranchSchedule.fromJson(schedule as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'branch': branch.toJson(),
      'schedules': schedules.map((schedule) => schedule.toJson()).toList(),
    };
  }

  @override
  String toString() {
    return 'ScheduleResponse(branch: ${branch.name}, schedules: ${schedules.length} días)';
  }
}

class SingleDayScheduleResponse {
  final BranchScheduleInfo branch;
  final BranchSchedule schedule;

  SingleDayScheduleResponse({
    required this.branch,
    required this.schedule,
  });

  factory SingleDayScheduleResponse.fromJson(Map<String, dynamic> json) {
    return SingleDayScheduleResponse(
      branch: BranchScheduleInfo.fromJson(json['branch'] ?? {}),
      schedule: BranchSchedule.fromJson(json['schedule'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'branch': branch.toJson(),
      'schedule': schedule.toJson(),
    };
  }

  @override
  String toString() {
    return 'SingleDayScheduleResponse(branch: ${branch.name}, day: ${schedule.dayName})';
  }
}

class WeeklyScheduleUpdateRequest {
  final List<ScheduleDayUpdate> schedules;

  WeeklyScheduleUpdateRequest({
    required this.schedules,
  });

  Map<String, dynamic> toJson() {
    return {
      'schedules': schedules.map((schedule) => schedule.toJson()).toList(),
    };
  }
}

class ScheduleDayUpdate {
  final int dayOfWeek;
  final String openingTime;
  final String closingTime;
  final bool isClosed;

  ScheduleDayUpdate({
    required this.dayOfWeek,
    required this.openingTime,
    required this.closingTime,
    required this.isClosed,
  });

  Map<String, dynamic> toJson() {
    return {
      'dayOfWeek': dayOfWeek,
      'openingTime': openingTime,
      'closingTime': closingTime,
      'isClosed': isClosed,
    };
  }

  factory ScheduleDayUpdate.fromBranchSchedule(BranchSchedule schedule) {
    return ScheduleDayUpdate(
      dayOfWeek: schedule.dayOfWeek,
      openingTime: schedule.openingTime,
      closingTime: schedule.closingTime,
      isClosed: schedule.isClosed,
    );
  }
}
