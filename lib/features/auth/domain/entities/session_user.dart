import 'package:equatable/equatable.dart';

enum UserStatus {
  pending,
  active,
  rejected,
  inactive;

  static UserStatus fromApi(String value) => switch (value) {
    'PENDING' => UserStatus.pending,
    'ACTIVE' => UserStatus.active,
    'REJECTED' => UserStatus.rejected,
    'INACTIVE' => UserStatus.inactive,
    _ => throw FormatException('Unsupported user status: $value'),
  };
}

enum UserRole {
  citizen,
  admin;

  static UserRole fromApi(String value) => switch (value) {
    'CITIZEN' => UserRole.citizen,
    'ADMIN' => UserRole.admin,
    _ => throw FormatException('Unsupported user role: $value'),
  };
}

class SessionUser extends Equatable {
  const SessionUser({
    required this.id,
    required this.name,
    required this.email,
    required this.phoneNumber,
    required this.birthDate,
    required this.balance,
    required this.leaderboardPoints,
    required this.status,
    required this.role,
  });

  factory SessionUser.fromJson(Map<String, dynamic> json) => SessionUser(
    id: json['id'] as String,
    name: json['name'] as String,
    email: json['email'] as String,
    phoneNumber: json['phoneNumber'] as String,
    birthDate: json['birthDate'] as String,
    balance: (json['balance'] as num?)?.toInt() ?? 0,
    leaderboardPoints: (json['leaderboardPoints'] as num?)?.toInt() ?? 0,
    status: UserStatus.fromApi(json['status'] as String),
    role: UserRole.fromApi(json['role'] as String),
  );

  final String id;
  final String name;
  final String email;
  final String phoneNumber;
  final String birthDate;
  final int balance;
  final int leaderboardPoints;
  final UserStatus status;
  final UserRole role;

  @override
  List<Object?> get props => [
    id,
    name,
    email,
    phoneNumber,
    birthDate,
    balance,
    leaderboardPoints,
    status,
    role,
  ];
}
