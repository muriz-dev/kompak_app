import '../../domain/entities/session_user.dart';

class LoginResponse {
  const LoginResponse({required this.token, required this.user});

  factory LoginResponse.fromJson(Map<String, dynamic> json) => LoginResponse(
    token: json['token'] as String,
    user: SessionUser.fromJson(Map<String, dynamic>.from(json['user'] as Map)),
  );

  final String token;
  final SessionUser user;
}
