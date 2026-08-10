import 'package:injectable/injectable.dart';

import '../../domain/entities/admin_event.dart';
import '../../domain/entities/create_admin_event_request.dart';
import '../../domain/repositories/admin_events_repository.dart';
import '../datasources/admin_events_remote_data_source.dart';

@LazySingleton(as: AdminEventsRepository)
class AdminEventsRepositoryImpl implements AdminEventsRepository {
  const AdminEventsRepositoryImpl(this._remoteDataSource);

  final AdminEventsRemoteDataSource _remoteDataSource;

  @override
  Future<List<AdminEvent>> getEvents() => _remoteDataSource.getEvents();

  @override
  Future<AdminEvent> createEvent(CreateAdminEventRequest request) =>
      _remoteDataSource.createEvent(request);

  @override
  Future<AdminEvent> updateEventStatus(
    String eventId,
    AdminEventRecordStatus status,
  ) => _remoteDataSource.updateEventStatus(eventId, status);
}
