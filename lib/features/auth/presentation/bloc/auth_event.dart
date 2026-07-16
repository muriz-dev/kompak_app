import 'package:equatable/equatable.dart';
import '../../data/models/login_request.dart';
import '../../data/models/register_request.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class LoginSubmitted extends AuthEvent {
  final LoginRequest request;

  const LoginSubmitted(this.request);

  @override
  List<Object?> get props => [request];
}

class RegisterSubmitted extends AuthEvent {
  final RegisterRequest request;

  const RegisterSubmitted(this.request);

  @override
  List<Object?> get props => [request];
}

class CheckAuthStatus extends AuthEvent {}

class LogoutRequested extends AuthEvent {}
