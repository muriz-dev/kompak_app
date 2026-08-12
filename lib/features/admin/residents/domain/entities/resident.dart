import 'package:equatable/equatable.dart';

enum ResidentStatus {
  pending,
  active,
  rejected,
  inactive;

  static ResidentStatus fromApi(String value) => switch (value) {
    'PENDING' => ResidentStatus.pending,
    'ACTIVE' => ResidentStatus.active,
    'REJECTED' => ResidentStatus.rejected,
    'INACTIVE' => ResidentStatus.inactive,
    _ => throw FormatException('Unsupported resident status: $value'),
  };

  String get apiValue => name.toUpperCase();
}

enum ResidentRole {
  citizen,
  admin;

  static ResidentRole fromApi(String value) => switch (value) {
    'CITIZEN' => ResidentRole.citizen,
    'ADMIN' => ResidentRole.admin,
    _ => throw FormatException('Unsupported resident role: $value'),
  };
}

enum ResidentAvatarTone { mint, lavender, sky, peach }

class Resident extends Equatable {
  const Resident({
    required this.id,
    required this.name,
    required this.phoneNumber,
    required this.birthDate,
    required this.email,
    required this.points,
    required this.leaderboardPoints,
    required this.status,
    required this.role,
  });

  factory Resident.fromJson(Map<String, dynamic> json) => Resident(
    id: json['id'] as String,
    name: json['name'] as String,
    phoneNumber: json['phoneNumber'] as String,
    birthDate: json['birthDate'] as String,
    email: json['email'] as String,
    points: (json['balance'] as num?)?.toInt() ?? 0,
    leaderboardPoints: (json['leaderboardPoints'] as num?)?.toInt() ?? 0,
    status: ResidentStatus.fromApi(json['status'] as String),
    role: ResidentRole.fromApi(json['role'] as String),
  );

  final String id;
  final String name;
  final String phoneNumber;
  final String birthDate;
  final String email;
  final int points;
  final int leaderboardPoints;
  final ResidentStatus status;
  final ResidentRole role;

  String get initials {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return '?';
    return parts.take(2).map((part) => part[0].toUpperCase()).join();
  }

  String get roleLabel => role == ResidentRole.admin ? 'Pengurus' : 'Warga';

  ResidentAvatarTone get avatarTone =>
      ResidentAvatarTone.values[id.hashCode.abs() %
          ResidentAvatarTone.values.length];

  Resident copyWith({
    String? name,
    String? phoneNumber,
    String? birthDate,
    String? email,
    int? points,
    int? leaderboardPoints,
    ResidentStatus? status,
    ResidentRole? role,
  }) => Resident(
    id: id,
    name: name ?? this.name,
    phoneNumber: phoneNumber ?? this.phoneNumber,
    birthDate: birthDate ?? this.birthDate,
    email: email ?? this.email,
    points: points ?? this.points,
    leaderboardPoints: leaderboardPoints ?? this.leaderboardPoints,
    status: status ?? this.status,
    role: role ?? this.role,
  );

  @override
  List<Object?> get props => [
    id,
    name,
    phoneNumber,
    birthDate,
    email,
    points,
    leaderboardPoints,
    status,
    role,
  ];
}
