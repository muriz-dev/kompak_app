import 'package:equatable/equatable.dart';

class CommunityAnnouncement extends Equatable {
  const CommunityAnnouncement({
    required this.id,
    required this.createdBy,
    required this.title,
    required this.description,
    required this.createdAt,
    required this.updatedAt,
  });

  factory CommunityAnnouncement.fromJson(Map<String, dynamic> json) {
    return CommunityAnnouncement(
      id: json['id'] as String,
      createdBy: json['createdBy'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      createdAt: _parseDate(json['createdAt']),
      updatedAt: _parseDate(json['updatedAt']),
    );
  }

  final String id;
  final String createdBy;
  final String title;
  final String description;
  final DateTime createdAt;
  final DateTime updatedAt;

  static DateTime _parseDate(Object? value) => switch (value) {
    String raw => DateTime.parse(raw),
    int milliseconds => DateTime.fromMillisecondsSinceEpoch(milliseconds),
    num milliseconds => DateTime.fromMillisecondsSinceEpoch(
      milliseconds.toInt(),
    ),
    _ => throw const FormatException('Invalid announcement date'),
  };

  @override
  List<Object?> get props => [
    id,
    createdBy,
    title,
    description,
    createdAt,
    updatedAt,
  ];
}
