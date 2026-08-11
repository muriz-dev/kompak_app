import 'package:equatable/equatable.dart';

import '../../../../announcements/domain/entities/community_announcement.dart';

sealed class AdminAnnouncementsState extends Equatable {
  const AdminAnnouncementsState();

  @override
  List<Object?> get props => [];
}

class AdminAnnouncementsLoading extends AdminAnnouncementsState {}

class AdminAnnouncementsLoaded extends AdminAnnouncementsState {
  const AdminAnnouncementsLoaded(this.announcements);

  final List<CommunityAnnouncement> announcements;

  @override
  List<Object?> get props => [announcements];
}

class AdminAnnouncementsLoadFailure extends AdminAnnouncementsState {
  const AdminAnnouncementsLoadFailure(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
