import '../entities/admin_event.dart';
import '../entities/admin_event_overview.dart';
import '../entities/create_admin_event_request.dart';
import '../entities/update_admin_event_request.dart';

abstract class AdminEventsRepository {
  Future<List<AdminEvent>> getEvents();

  Future<AdminEvent> createEvent(CreateAdminEventRequest request);

  Future<AdminEventOverview> getEventOverview(String eventId);

  Future<AdminEvent> updateEvent(
    String eventId,
    UpdateAdminEventRequest request,
  );

  Future<void> deleteEvent(String eventId);

  Future<AdminEvent> updateEventStatus(
    String eventId,
    AdminEventRecordStatus status,
  );
}
