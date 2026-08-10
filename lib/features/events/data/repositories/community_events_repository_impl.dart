import 'package:injectable/injectable.dart';

import '../../domain/entities/community_event.dart';
import '../../domain/repositories/community_events_repository.dart';
import '../datasources/community_events_remote_data_source.dart';

@LazySingleton(as: CommunityEventsRepository)
class CommunityEventsRepositoryImpl implements CommunityEventsRepository {
  CommunityEventsRepositoryImpl(this._remoteDataSource);

  final CommunityEventsRemoteDataSource _remoteDataSource;

  @override
  Future<CommunityEvent> getEvent(String eventId) =>
      _remoteDataSource.getEvent(eventId);

  @override
  Future<List<CommunityEvent>> getEvents(EventTimeframe timeframe) =>
      _remoteDataSource.getEvents(timeframe);
}
