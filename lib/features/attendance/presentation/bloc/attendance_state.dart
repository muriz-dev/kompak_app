import 'package:equatable/equatable.dart';
import '../../domain/entities/attendance_data.dart';
import '../../domain/entities/attendance_record.dart';

abstract class AttendanceState extends Equatable {
  const AttendanceState();

  @override
  List<Object?> get props => [];
}

class AttendanceLoading extends AttendanceState {}

class AttendanceLoaded extends AttendanceState {
  final AttendanceStats stats;
  final OngoingEvent? ongoingEvent;
  final List<UpcomingEventItem> upcomingEvents;
  final List<AttendanceRecord> history;

  const AttendanceLoaded({
    required this.stats,
    this.ongoingEvent,
    required this.upcomingEvents,
    required this.history,
  });

  @override
  List<Object?> get props => [stats, ongoingEvent, upcomingEvents, history];
}

class AttendanceError extends AttendanceState {
  final String message;

  const AttendanceError(this.message);

  @override
  List<Object?> get props => [message];
}
