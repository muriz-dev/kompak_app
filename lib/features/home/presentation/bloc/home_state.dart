import 'package:equatable/equatable.dart';
import '../../domain/entities/home_data.dart';

abstract class HomeState extends Equatable {
  const HomeState();

  @override
  List<Object?> get props => [];
}

class HomeLoading extends HomeState {}

class HomeLoaded extends HomeState {
  final UserSummary userSummary;
  final List<UpcomingActivity> upcomingActivities;
  final List<Announcement> announcements;

  const HomeLoaded({
    required this.userSummary,
    required this.upcomingActivities,
    required this.announcements,
  });

  @override
  List<Object?> get props => [userSummary, upcomingActivities, announcements];
}

class HomeError extends HomeState {
  final String message;

  const HomeError(this.message);

  @override
  List<Object?> get props => [message];
}
