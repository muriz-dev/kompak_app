import 'package:injectable/injectable.dart';

import '../../domain/entities/community_announcement.dart';
import '../../domain/repositories/announcements_repository.dart';
import '../datasources/announcements_remote_data_source.dart';

@LazySingleton(as: AnnouncementsRepository)
class AnnouncementsRepositoryImpl implements AnnouncementsRepository {
  const AnnouncementsRepositoryImpl(this._remoteDataSource);

  final AnnouncementsRemoteDataSource _remoteDataSource;

  @override
  Future<List<CommunityAnnouncement>> getAnnouncements() =>
      _remoteDataSource.getAnnouncements();

  @override
  Future<CommunityAnnouncement> getAnnouncement(String announcementId) =>
      _remoteDataSource.getAnnouncement(announcementId);

  @override
  Future<void> createAnnouncement({
    required String title,
    required String description,
  }) => _remoteDataSource.createAnnouncement(
    title: title,
    description: description,
  );

  @override
  Future<CommunityAnnouncement> updateAnnouncement({
    required String announcementId,
    required String title,
    required String description,
  }) => _remoteDataSource.updateAnnouncement(
    announcementId: announcementId,
    title: title,
    description: description,
  );

  @override
  Future<void> deleteAnnouncement(String announcementId) =>
      _remoteDataSource.deleteAnnouncement(announcementId);
}
