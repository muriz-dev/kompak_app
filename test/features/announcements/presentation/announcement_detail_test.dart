import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kompak_app/core/theme/app_theme.dart';
import 'package:kompak_app/features/announcements/data/datasources/announcements_remote_data_source.dart';
import 'package:kompak_app/features/announcements/domain/entities/community_announcement.dart';
import 'package:kompak_app/features/announcements/domain/repositories/announcements_repository.dart';
import 'package:kompak_app/features/announcements/presentation/bloc/announcement_detail_cubit.dart';
import 'package:kompak_app/features/announcements/presentation/bloc/announcement_detail_state.dart';
import 'package:kompak_app/features/announcements/presentation/pages/announcement_detail_page.dart';

void main() {
  final announcement = CommunityAnnouncement(
    id: 'announcement-1',
    createdBy: 'admin-1',
    title: 'Penyesuaian Jadwal Keamanan Malam',
    description:
        'Jadwal ronda malam diperbarui mulai pekan ini. Mohon seluruh warga memperhatikan pembagian jadwal terbaru.',
    createdAt: DateTime(2026, 8, 12, 9, 30),
    updatedAt: DateTime(2026, 8, 12, 10),
  );

  test('loads one announcement from its detail endpoint', () async {
    final adapter = _AnnouncementDetailAdapter(announcement);
    final dio = Dio(BaseOptions(baseUrl: 'http://kompak.test'))
      ..httpClientAdapter = adapter;
    final dataSource = AnnouncementsRemoteDataSourceImpl(dio);

    final result = await dataSource.getAnnouncement('announcement-1');

    expect(result, announcement);
    expect(adapter.lastRequest?.method, 'GET');
    expect(adapter.lastRequest?.path, '/announcements/announcement-1');
  });

  test('detail cubit exposes API errors for retry UI', () async {
    final cubit = AnnouncementDetailCubit(
      _AnnouncementDetailRepository(error: Exception('Pengumuman dihapus.')),
    );
    addTearDown(cubit.close);

    await cubit.loadAnnouncement('announcement-1');

    expect(cubit.state, const AnnouncementDetailError('Pengumuman dihapus.'));
  });

  testWidgets('shows the full announcement and supports pull to refresh', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(320, 700);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    var refreshCount = 0;

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: AnnouncementDetailView(
            announcement: announcement,
            onRefresh: () async => refreshCount++,
          ),
        ),
      ),
    );

    expect(find.text(announcement.title), findsOneWidget);
    expect(find.text(announcement.description), findsOneWidget);
    expect(find.text('Diterbitkan oleh Pengurus RT'), findsOneWidget);
    expect(find.textContaining('Diperbarui'), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.fling(
      find.byKey(const ValueKey('announcement-detail-scroll')),
      const Offset(0, 300),
      1000,
    );
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    expect(refreshCount, 1);
  });
}

class _AnnouncementDetailAdapter implements HttpClientAdapter {
  _AnnouncementDetailAdapter(this.announcement);

  final CommunityAnnouncement announcement;
  RequestOptions? lastRequest;

  @override
  void close({bool force = false}) {}

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    lastRequest = options;
    return ResponseBody.fromString(
      jsonEncode({
        'success': true,
        'data': {
          'id': announcement.id,
          'createdBy': announcement.createdBy,
          'title': announcement.title,
          'description': announcement.description,
          'createdAt': announcement.createdAt.millisecondsSinceEpoch,
          'updatedAt': announcement.updatedAt.millisecondsSinceEpoch,
        },
      }),
      200,
      headers: {
        Headers.contentTypeHeader: ['application/json'],
      },
    );
  }
}

class _AnnouncementDetailRepository implements AnnouncementsRepository {
  _AnnouncementDetailRepository({this.error});

  final Object? error;

  @override
  Future<CommunityAnnouncement> getAnnouncement(String announcementId) async {
    if (error case final failure?) throw failure;
    throw UnimplementedError();
  }

  @override
  Future<List<CommunityAnnouncement>> getAnnouncements() =>
      throw UnimplementedError();

  @override
  Future<void> createAnnouncement({
    required String title,
    required String description,
  }) => throw UnimplementedError();

  @override
  Future<void> deleteAnnouncement(String announcementId) =>
      throw UnimplementedError();

  @override
  Future<CommunityAnnouncement> updateAnnouncement({
    required String announcementId,
    required String title,
    required String description,
  }) => throw UnimplementedError();
}
