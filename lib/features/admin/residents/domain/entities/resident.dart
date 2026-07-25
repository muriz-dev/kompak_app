import 'package:equatable/equatable.dart';

enum ResidentStatus { active, inactive }

enum ResidentAvatarTone { mint, lavender, sky, peach }

class Resident extends Equatable {
  final String id;
  final String initials;
  final String name;
  final String householdRole;
  final int points;
  final String address;
  final ResidentStatus status;
  final ResidentAvatarTone avatarTone;

  const Resident({
    required this.id,
    required this.initials,
    required this.name,
    required this.householdRole,
    required this.points,
    required this.address,
    required this.status,
    required this.avatarTone,
  });

  bool get isActive => status == ResidentStatus.active;

  @override
  List<Object?> get props => [
    id,
    initials,
    name,
    householdRole,
    points,
    address,
    status,
    avatarTone,
  ];
}
