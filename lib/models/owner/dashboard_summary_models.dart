class DashboardSummary {
  final String status;
  final DashboardData data;

  DashboardSummary({
    required this.status,
    required this.data,
  });

  factory DashboardSummary.fromJson(Map<String, dynamic> json) {
    // Si no hay campo 'data', parsear directamente el JSON
    if (json['data'] == null) {
      return DashboardSummary(
        status: json['status'] ?? 'success',
        data: DashboardData.fromJson(json),
      );
    }
    
    return DashboardSummary(
      status: json['status'] ?? '',
      data: DashboardData.fromJson(json['data'] ?? {}),
    );
  }
}

class DashboardData {
  final Financials financials;
  final Operations operations;
  final StoreStatus storeStatus;
  final QuickStats quickStats;

  DashboardData({
    required this.financials,
    required this.operations,
    required this.storeStatus,
    required this.quickStats,
  });

  factory DashboardData.fromJson(Map<String, dynamic> json) {
    return DashboardData(
      financials: Financials.fromJson(json['financials'] ?? {}),
      operations: Operations.fromJson(json['operations'] ?? {}),
      storeStatus: StoreStatus.fromJson(json['storeStatus'] ?? {}),
      quickStats: QuickStats.fromJson(json['quickStats'] ?? {}),
    );
  }
}

class Financials {
  final double walletBalance;
  final double todaySales;
  final double todayEarnings;

  Financials({
    required this.walletBalance,
    required this.todaySales,
    required this.todayEarnings,
  });

  factory Financials.fromJson(Map<String, dynamic> json) {
    return Financials(
      walletBalance: (json['walletBalance'] ?? 0.0).toDouble(),
      todaySales: (json['todaySales'] ?? 0.0).toDouble(),
      todayEarnings: (json['todayEarnings'] ?? 0.0).toDouble(),
    );
  }

  // Helper para calcular el porcentaje de ganancias
  double get earningsPercentage {
    if (todaySales == 0) return 0.0;
    return (todayEarnings / todaySales) * 100;
  }
}

class Operations {
  final int pendingOrdersCount;
  final int preparingOrdersCount;
  final int readyForPickupCount;
  final int deliveredTodayCount;

  Operations({
    required this.pendingOrdersCount,
    required this.preparingOrdersCount,
    required this.readyForPickupCount,
    required this.deliveredTodayCount,
  });

  factory Operations.fromJson(Map<String, dynamic> json) {
    return Operations(
      pendingOrdersCount: json['pendingOrdersCount'] ?? 0,
      preparingOrdersCount: json['preparingOrdersCount'] ?? 0,
      readyForPickupCount: json['readyForPickupCount'] ?? 0,
      deliveredTodayCount: json['deliveredTodayCount'] ?? 0,
    );
  }

  // Helper para obtener el total de pedidos activos
  int get totalActiveOrders {
    return pendingOrdersCount + preparingOrdersCount + readyForPickupCount;
  }
}

class StoreStatus {
  final bool isOpen;
  final String? nextOpeningTime;
  final String? nextClosingTime;
  final CurrentDaySchedule currentDaySchedule;

  StoreStatus({
    required this.isOpen,
    this.nextOpeningTime,
    this.nextClosingTime,
    required this.currentDaySchedule,
  });

  factory StoreStatus.fromJson(Map<String, dynamic> json) {
    return StoreStatus(
      isOpen: json['isOpen'] ?? false,
      nextOpeningTime: json['nextOpeningTime'],
      nextClosingTime: json['nextClosingTime'],
      currentDaySchedule: CurrentDaySchedule.fromJson(json['currentDaySchedule'] ?? {}),
    );
  }

  // Helper para obtener el estado como texto
  String get statusText {
    if (isOpen) {
      return 'Abierto';
    } else if (nextOpeningTime != null) {
      return 'Cerrado - Abre a las $nextOpeningTime';
    } else {
      return 'Cerrado';
    }
  }

  // Helper para obtener el color del estado
  String get statusColor {
    return isOpen ? 'green' : 'red';
  }
}

class CurrentDaySchedule {
  final String day;
  final String opening;
  final String closing;

  CurrentDaySchedule({
    required this.day,
    required this.opening,
    required this.closing,
  });

  factory CurrentDaySchedule.fromJson(Map<String, dynamic> json) {
    return CurrentDaySchedule(
      day: json['day'] ?? '',
      opening: json['opening'] ?? '',
      closing: json['closing'] ?? '',
    );
  }

  // Helper para obtener el horario como texto
  String get scheduleText {
    return '$opening - $closing';
  }
}

class QuickStats {
  final int activeProductsCount;
  final int activeEmployeesCount;
  final int totalCategories;

  QuickStats({
    required this.activeProductsCount,
    required this.activeEmployeesCount,
    required this.totalCategories,
  });

  factory QuickStats.fromJson(Map<String, dynamic> json) {
    return QuickStats(
      activeProductsCount: json['activeProductsCount'] ?? 0,
      activeEmployeesCount: json['activeEmployeesCount'] ?? 0,
      totalCategories: json['totalCategories'] ?? 0,
    );
  }
}
