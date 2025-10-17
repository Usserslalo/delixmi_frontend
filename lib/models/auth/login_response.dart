import 'user.dart';

class LoginResponse {
  final String status;
  final String message;
  final LoginData data;
  
  LoginResponse({
    required this.status,
    required this.message,
    required this.data,
  });
  
  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      status: json['status'],
      message: json['message'],
      data: LoginData.fromJson(json['data']),
    );
  }
}

class LoginData {
  final String accessToken;
  final String refreshToken;
  final User user;
  final String expiresIn;
  
  LoginData({
    required this.accessToken,
    required this.refreshToken,
    required this.user,
    required this.expiresIn,
  });
  
  factory LoginData.fromJson(Map<String, dynamic> json) {
    return LoginData(
      accessToken: json['accessToken'] ?? json['token'] ?? '', // Compatibilidad con versión anterior
      refreshToken: json['refreshToken'] ?? '',
      user: User.fromJson(json['user']),
      expiresIn: json['expiresIn'],
    );
  }
  
  // Getter para compatibilidad con código existente
  String get token => accessToken;
}
