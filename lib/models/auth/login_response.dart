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
  final String token;
  final User user;
  final String expiresIn;
  
  LoginData({
    required this.token,
    required this.user,
    required this.expiresIn,
  });
  
  factory LoginData.fromJson(Map<String, dynamic> json) {
    return LoginData(
      token: json['token'],
      user: User.fromJson(json['user']),
      expiresIn: json['expiresIn'],
    );
  }
}
