import '../entities/admin_event.dart';
import '../entities/create_admin_event_request.dart';

abstract class AdminEventsRepository {
  Future<List<AdminEvent>> getEvents();

  Future<AdminEvent> createEvent(CreateAdminEventRequest request);

  Future<AdminEvent> updateEventStatus(
    String eventId,
    AdminEventRecordStatus status,
  );
}
