import '../entities/community_announcement.dart';

abstract class AnnouncementsRepository {
  Future<List<CommunityAnnouncement>> getAnnouncements();

  Future<void> createAnnouncement({
    required String title,
    required String description,
  });

  Future<CommunityAnnouncement> updateAnnouncement({
    required String announcementId,
    required String title,
    required String description,
  });

  Future<void> deleteAnnouncement(String announcementId);
}
