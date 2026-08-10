import '../entities/community_event.dart';

abstract class CommunityEventsRepository {
  Future<List<CommunityEvent>> getEvents(EventTimeframe timeframe);

  Future<CommunityEvent> getEvent(String eventId);
}
