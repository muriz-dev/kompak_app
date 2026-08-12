import 'package:equatable/equatable.dart';

import '../../domain/entities/community_announcement.dart';

sealed class AnnouncementDetailState extends Equatable {
  const AnnouncementDetailState();

  @override
  List<Object?> get props => [];
}

class AnnouncementDetailLoading extends AnnouncementDetailState {}

class AnnouncementDetailLoaded extends AnnouncementDetailState {
  const AnnouncementDetailLoaded(this.announcement);

  final CommunityAnnouncement announcement;

  @override
  List<Object?> get props => [announcement];
}

class AnnouncementDetailError extends AnnouncementDetailState {
  const AnnouncementDetailError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
