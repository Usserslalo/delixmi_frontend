import 'package:flutter/material.dart';

class RestaurantWallet {
  final int id;
  final int restaurantId;
  final double balance;
  final DateTime? createdAt; // Opcional según respuesta del backend
  final DateTime updatedAt;
  final RestaurantInfo restaurant;

  RestaurantWallet({
    required this.id,
    required this.restaurantId,
    required this.balance,
    this.createdAt,
    required this.updatedAt,
    required this.restaurant,
  });

  factory RestaurantWallet.fromJson(Map<String, dynamic> json) {
    return RestaurantWallet(
      id: json['id'] as int,
      restaurantId: json['restaurantId'] as int,
      balance: (json['balance'] as num).toDouble(),
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt'] as String)
          : null,
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      restaurant: RestaurantInfo.fromJson(json['restaurant'] as Map<String, dynamic>),
    );
  }
}

class RestaurantInfo {
  final int id;
  final String name;
  final int ownerId;

  RestaurantInfo({
    required this.id,
    required this.name,
    required this.ownerId,
  });

  factory RestaurantInfo.fromJson(Map<String, dynamic> json) {
    return RestaurantInfo(
      id: json['id'] as int,
      name: json['name'] as String,
      ownerId: json['ownerId'] as int,
    );
  }
}

class WalletTransaction {
  final String id;
  final double amount;
  final double? balanceAfter; // Campo del backend
  final String type;
  final String description;
  final String? orderId;
  final DateTime createdAt;
  final TransactionOrder? order;

  WalletTransaction({
    required this.id,
    required this.amount,
    this.balanceAfter,
    required this.type,
    required this.description,
    this.orderId,
    required this.createdAt,
    this.order,
  });

  factory WalletTransaction.fromJson(Map<String, dynamic> json) {
    return WalletTransaction(
      id: json['id'].toString(),
      amount: (json['amount'] as num).toDouble(),
      balanceAfter: json['balanceAfter'] != null 
          ? (json['balanceAfter'] as num).toDouble() 
          : null,
      type: json['type'] as String,
      description: json['description'] as String,
      orderId: json['orderId']?.toString(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      order: json['order'] != null 
          ? TransactionOrder.fromJson(json['order'] as Map<String, dynamic>)
          : null,
    );
  }

  /// Color del tipo de transacción para mostrar en UI
  Color get typeColor {
    switch (type.toLowerCase()) {
      case 'earning':
        return Colors.green;
      case 'withdrawal':
        return Colors.red;
      case 'refund':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  /// Icono del tipo de transacción para mostrar en UI
  IconData get typeIcon {
    switch (type.toLowerCase()) {
      case 'earning':
        return Icons.trending_up_rounded;
      case 'withdrawal':
        return Icons.trending_down_rounded;
      case 'refund':
        return Icons.receipt_long_rounded;
      default:
        return Icons.account_balance_wallet_rounded;
    }
  }

  /// Nombre del tipo de transacción en español
  String get typeDisplayName {
    switch (type.toLowerCase()) {
      case 'earning':
        return 'Ganancia';
      case 'withdrawal':
        return 'Retiro';
      case 'refund':
        return 'Reembolso';
      default:
        return type;
    }
  }
}

class TransactionOrder {
  final String id;
  final double total;
  final double? restaurantPayout;
  final String status;
  final String? paymentMethod;

  TransactionOrder({
    required this.id,
    required this.total,
    this.restaurantPayout,
    required this.status,
    this.paymentMethod,
  });

  factory TransactionOrder.fromJson(Map<String, dynamic> json) {
    return TransactionOrder(
      id: json['id'].toString(),
      total: (json['total'] as num).toDouble(),
      restaurantPayout: json['restaurantPayout'] != null 
          ? (json['restaurantPayout'] as num).toDouble() 
          : null,
      status: json['status'] as String,
      paymentMethod: json['paymentMethod'] as String?,
    );
  }
}

class TransactionPagination {
  final int currentPage;
  final int pageSize;
  final int totalCount;
  final int totalPages;
  final bool hasNextPage;
  final bool hasPreviousPage;

  TransactionPagination({
    required this.currentPage,
    required this.pageSize,
    required this.totalCount,
    required this.totalPages,
    required this.hasNextPage,
    required this.hasPreviousPage,
  });

  factory TransactionPagination.fromJson(Map<String, dynamic> json) {
    return TransactionPagination(
      currentPage: json['currentPage'] as int,
      pageSize: json['pageSize'] as int,
      totalCount: json['totalCount'] as int,
      totalPages: json['totalPages'] as int,
      hasNextPage: json['hasNextPage'] as bool,
      hasPreviousPage: json['hasPreviousPage'] as bool,
    );
  }
}

class TransactionListResponse {
  final List<WalletTransaction> transactions;
  final TransactionPagination pagination;

  TransactionListResponse({
    required this.transactions,
    required this.pagination,
  });

  factory TransactionListResponse.fromJson(Map<String, dynamic> json) {
    return TransactionListResponse(
      transactions: (json['transactions'] as List<dynamic>)
          .map((transaction) => WalletTransaction.fromJson(transaction as Map<String, dynamic>))
          .toList(),
      pagination: TransactionPagination.fromJson(json['pagination'] as Map<String, dynamic>),
    );
  }
}

class EarningsPeriod {
  final DateTime? from;
  final DateTime? to;

  EarningsPeriod({
    this.from,
    this.to,
  });

  factory EarningsPeriod.fromJson(Map<String, dynamic> json) {
    return EarningsPeriod(
      from: json['from'] != null ? DateTime.parse(json['from'] as String) : null,
      to: json['to'] != null ? DateTime.parse(json['to'] as String) : null,
    );
  }
}

class EarningsSummary {
  final double totalEarnings;
  final double totalRevenue;
  final int ordersDelivered;
  final int transactionsCount;
  final double averageOrderValue;

  EarningsSummary({
    required this.totalEarnings,
    required this.totalRevenue,
    required this.ordersDelivered,
    required this.transactionsCount,
    required this.averageOrderValue,
  });

  factory EarningsSummary.fromJson(Map<String, dynamic> json) {
    return EarningsSummary(
      totalEarnings: (json['totalEarnings'] as num).toDouble(),
      totalRevenue: (json['totalRevenue'] as num).toDouble(),
      ordersDelivered: json['ordersDelivered'] as int,
      transactionsCount: json['transactionsCount'] as int,
      averageOrderValue: (json['averageOrderValue'] as num).toDouble(),
    );
  }
}

class EarningsBreakdown {
  final int earningsCount;
  final double earningsPercentage;

  EarningsBreakdown({
    required this.earningsCount,
    required this.earningsPercentage,
  });

  factory EarningsBreakdown.fromJson(Map<String, dynamic> json) {
    return EarningsBreakdown(
      earningsCount: json['earningsCount'] as int,
      earningsPercentage: (json['earningsPercentage'] as num).toDouble(),
    );
  }
}

class EarningsResponse {
  final EarningsPeriod period;
  final EarningsSummary summary;
  final EarningsBreakdown breakdown;

  EarningsResponse({
    required this.period,
    required this.summary,
    required this.breakdown,
  });

  factory EarningsResponse.fromJson(Map<String, dynamic> json) {
    // El backend real envía los datos directamente, no anidados en 'summary' y 'breakdown'
    // Según los logs: {"totalEarnings": 726.25, "totalRevenue": 830, "totalOrders": 2, "averageEarningPerOrder": 363.125, "period": {"from": null, "to": null}}
    
    // Manejar el periodo
    final periodData = json['period'];
    final period = periodData != null 
        ? EarningsPeriod.fromJson(periodData as Map<String, dynamic>)
        : EarningsPeriod();
    
    // Crear summary con los datos directos del backend
    final summary = EarningsSummary(
      totalEarnings: (json['totalEarnings'] as num?)?.toDouble() ?? 0.0,
      totalRevenue: (json['totalRevenue'] as num?)?.toDouble() ?? 0.0,
      ordersDelivered: json['totalOrders'] as int? ?? (json['ordersDelivered'] as int?) ?? 0,
      transactionsCount: json['transactionsCount'] as int? ?? 0,
      averageOrderValue: (json['averageEarningPerOrder'] as num?)?.toDouble() ?? 
                        (json['averageOrderValue'] as num?)?.toDouble() ?? 0.0,
    );
    
    // Crear breakdown calculado
    final earningsCount = json['earningsCount'] as int? ?? summary.ordersDelivered;
    final earningsPercentage = summary.totalRevenue > 0 
        ? (summary.totalEarnings / summary.totalRevenue) * 100 
        : 0.0;
    
    final breakdown = EarningsBreakdown(
      earningsCount: earningsCount,
      earningsPercentage: earningsPercentage,
    );
    
    return EarningsResponse(
      period: period,
      summary: summary,
      breakdown: breakdown,
    );
  }
}
