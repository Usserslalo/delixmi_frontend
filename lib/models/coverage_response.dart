/// Modelo de respuesta de cobertura de entrega
class CoverageResponse {
  final String status;
  final String message;
  final CoverageData data;

  CoverageResponse({
    required this.status,
    required this.message,
    required this.data,
  });

  factory CoverageResponse.fromJson(Map<String, dynamic> json) {
    return CoverageResponse(
      status: json['status'] ?? 'error',
      message: json['message'] ?? '',
      data: CoverageData.fromJson(json['data'] ?? {}),
    );
  }

  bool get isSuccess => status == 'success';
}

/// Datos de cobertura
class CoverageData {
  final bool hasCoverage;
  final int totalRestaurants;
  final int totalBranches;
  final int coveredBranches;
  final int notCoveredBranches;
  final String coveragePercentage;

  CoverageData({
    required this.hasCoverage,
    this.totalRestaurants = 0,
    this.totalBranches = 0,
    this.coveredBranches = 0,
    this.notCoveredBranches = 0,
    this.coveragePercentage = '0.00',
  });

  factory CoverageData.fromJson(Map<String, dynamic> json) {
    // Manejar el campo hasCoverage
    bool hasCoverage = false;
    if (json['hasCoverage'] != null) {
      hasCoverage = json['hasCoverage'] as bool;
    }

    // Obtener estadísticas si están disponibles
    final stats = json['stats'] as Map<String, dynamic>?;

    return CoverageData(
      hasCoverage: hasCoverage,
      totalRestaurants: stats?['totalRestaurants'] ?? 0,
      totalBranches: stats?['totalBranches'] ?? 0,
      coveredBranches: stats?['coveredBranches'] ?? 0,
      notCoveredBranches: stats?['notCoveredBranches'] ?? 0,
      coveragePercentage: stats?['coveragePercentage']?.toString() ?? '0.00',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'hasCoverage': hasCoverage,
      'totalRestaurants': totalRestaurants,
      'totalBranches': totalBranches,
      'coveredBranches': coveredBranches,
      'notCoveredBranches': notCoveredBranches,
      'coveragePercentage': coveragePercentage,
    };
  }

  @override
  String toString() {
    return 'CoverageData(hasCoverage: $hasCoverage, coveredBranches: $coveredBranches/$totalBranches)';
  }
}

