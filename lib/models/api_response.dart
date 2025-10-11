class ApiResponse<T> {
  final String status;
  final String message;
  final T? data;
  final List<dynamic>? errors;
  final String? code;
  final Map<String, dynamic>? details;
  final String? suggestion;

  ApiResponse({
    required this.status,
    required this.message,
    this.data,
    this.errors,
    this.code,
    this.details,
    this.suggestion,
  });

  bool get isSuccess => status == 'success';
  bool get isError => status == 'error';

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic)? fromJsonT,
  ) {
    return ApiResponse<T>(
      status: json['status'] ?? 'error',
      message: json['message'] ?? 'Error desconocido',
      data: json['data'] != null && fromJsonT != null 
          ? fromJsonT(json['data']) 
          : json['data'],
      errors: json['errors'],
      code: json['code'],
      details: json['details'] as Map<String, dynamic>?,
      suggestion: json['suggestion'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'message': message,
      'data': data,
      'errors': errors,
      'code': code,
      'details': details,
      'suggestion': suggestion,
    };
  }

  @override
  String toString() {
    return 'ApiResponse(status: $status, message: $message, data: $data, errors: $errors, code: $code, details: $details, suggestion: $suggestion)';
  }
}
