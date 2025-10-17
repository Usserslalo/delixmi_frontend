class RefreshResponse {
  final String status;
  final String message;
  final RefreshData data;
  
  RefreshResponse({
    required this.status,
    required this.message,
    required this.data,
  });
  
  factory RefreshResponse.fromJson(Map<String, dynamic> json) {
    return RefreshResponse(
      status: json['status'],
      message: json['message'],
      data: RefreshData.fromJson(json['data']),
    );
  }
}

class RefreshData {
  final String accessToken;
  final String refreshToken;
  final String expiresIn;
  
  RefreshData({
    required this.accessToken,
    required this.refreshToken,
    required this.expiresIn,
  });
  
  factory RefreshData.fromJson(Map<String, dynamic> json) {
    return RefreshData(
      accessToken: json['accessToken'],
      refreshToken: json['refreshToken'],
      expiresIn: json['expiresIn'],
    );
  }
}
