import 'package:equatable/equatable.dart';

class RegistrationReceipt extends Equatable {
  final String id;
  final String status;
  final String role;

  const RegistrationReceipt({
    required this.id,
    required this.status,
    required this.role,
  });

  factory RegistrationReceipt.fromJson(Map<String, dynamic> json) {
    return RegistrationReceipt(
      id: json['id'] as String,
      status: json['status'] as String,
      role: json['role'] as String,
    );
  }

  @override
  List<Object?> get props => [id, status, role];
}
