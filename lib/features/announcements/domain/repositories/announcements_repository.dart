import '../entities/community_announcement.dart';

abstract class AnnouncementsRepository {
  Future<List<CommunityAnnouncement>> getAnnouncements();

  Future<CommunityAnnouncement> getAnnouncement(String announcementId);

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
