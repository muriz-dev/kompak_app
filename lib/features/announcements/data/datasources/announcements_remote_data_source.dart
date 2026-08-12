import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import '../../domain/entities/community_announcement.dart';

abstract class AnnouncementsRemoteDataSource {
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

@LazySingleton(as: AnnouncementsRemoteDataSource)
class AnnouncementsRemoteDataSourceImpl
    implements AnnouncementsRemoteDataSource {
  const AnnouncementsRemoteDataSourceImpl(this._dio);

  final Dio _dio;

  @override
  Future<List<CommunityAnnouncement>> getAnnouncements() async {
    try {
      final response = await _dio.get<Map<String, dynamic>>('/announcements');
      final data = response.data;
      if (data == null || data['success'] != true || data['data'] is! List) {
        throw const FormatException('Invalid announcements response');
      }

      return (data['data'] as List)
          .map(
            (item) => CommunityAnnouncement.fromJson(
              Map<String, dynamic>.from(item as Map),
            ),
          )
          .toList(growable: false);
    } on DioException catch (error) {
      throw Exception(
        _message(error, fallback: 'Gagal memuat daftar pengumuman.'),
      );
    }
  }

  @override
  Future<CommunityAnnouncement> getAnnouncement(String announcementId) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/announcements/$announcementId',
      );
      final data = response.data;
      if (data == null || data['success'] != true || data['data'] is! Map) {
        throw const FormatException('Invalid announcement detail response');
      }

      return CommunityAnnouncement.fromJson(
        Map<String, dynamic>.from(data['data'] as Map),
      );
    } on DioException catch (error) {
      throw Exception(
        _message(error, fallback: 'Gagal memuat detail pengumuman.'),
      );
    }
  }

  @override
  Future<void> createAnnouncement({
    required String title,
    required String description,
  }) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/announcements',
        data: {'title': title.trim(), 'description': description.trim()},
      );
      final data = response.data;
      if (data == null ||
          data['success'] != true ||
          data['data'] is! Map ||
          (data['data'] as Map)['announcementId'] is! String) {
        throw const FormatException('Invalid announcement creation response');
      }
    } on DioException catch (error) {
      throw Exception(
        _message(error, fallback: 'Gagal mempublikasikan pengumuman.'),
      );
    }
  }

  @override
  Future<CommunityAnnouncement> updateAnnouncement({
    required String announcementId,
    required String title,
    required String description,
  }) async {
    try {
      final response = await _dio.patch<Map<String, dynamic>>(
        '/announcements/$announcementId',
        data: {'title': title.trim(), 'description': description.trim()},
      );
      final data = response.data;
      if (data == null || data['success'] != true || data['data'] is! Map) {
        throw const FormatException('Invalid announcement update response');
      }

      return CommunityAnnouncement.fromJson(
        Map<String, dynamic>.from(data['data'] as Map),
      );
    } on DioException catch (error) {
      throw Exception(
        _message(error, fallback: 'Gagal menyimpan perubahan pengumuman.'),
      );
    }
  }

  @override
  Future<void> deleteAnnouncement(String announcementId) async {
    try {
      final response = await _dio.delete<Map<String, dynamic>>(
        '/announcements/$announcementId',
      );
      final data = response.data;
      if (data == null || data['success'] != true) {
        throw const FormatException('Invalid announcement deletion response');
      }
    } on DioException catch (error) {
      throw Exception(_message(error, fallback: 'Gagal menghapus pengumuman.'));
    }
  }

  String _message(DioException error, {required String fallback}) {
    final data = error.response?.data;
    return data is Map ? data['message']?.toString() ?? fallback : fallback;
  }
}
