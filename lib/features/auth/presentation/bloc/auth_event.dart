import 'package:equatable/equatable.dart';
import '../../data/models/register_request.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class RegisterSubmitted extends AuthEvent {
  final RegisterRequest request;

  const RegisterSubmitted(this.request);

  @override
  List<Object?> get props => [request];
}
