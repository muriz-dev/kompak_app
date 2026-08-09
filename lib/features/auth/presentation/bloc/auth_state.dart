import 'package:equatable/equatable.dart';
import '../../data/models/registration_receipt.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthAuthenticated extends AuthState {}

class AuthUnauthenticated extends AuthState {}

class AuthError extends AuthState {
  final String message;
  final Map<String, String> fieldErrors;

  const AuthError(this.message, [this.fieldErrors = const {}]);

  @override
  List<Object?> get props => [message, fieldErrors];
}

class RegisterSuccess extends AuthState {
  final RegistrationReceipt receipt;

  const RegisterSuccess(this.receipt);

  @override
  List<Object?> get props => [receipt];
}
