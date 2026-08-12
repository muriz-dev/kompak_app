import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/community_announcement.dart';
import '../bloc/announcement_detail_cubit.dart';
import '../bloc/announcement_detail_state.dart';

@RoutePage()
class AnnouncementDetailPage extends StatelessWidget {
  const AnnouncementDetailPage({
    @PathParam('announcementId') required this.announcementId,
    super.key,
  });

  final String announcementId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          getIt<AnnouncementDetailCubit>()..loadAnnouncement(announcementId),
      child: Scaffold(
        backgroundColor: KompakColors.surface,
        appBar: AppBar(
          backgroundColor: KompakColors.surface,
          surfaceTintColor: Colors.transparent,
          centerTitle: true,
          title: const Text(
            'Detail Pengumuman',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
          ),
        ),
        body: BlocBuilder<AnnouncementDetailCubit, AnnouncementDetailState>(
          builder: (context, state) => switch (state) {
            AnnouncementDetailLoaded() => AnnouncementDetailView(
              announcement: state.announcement,
              onRefresh: () => context
                  .read<AnnouncementDetailCubit>()
                  .loadAnnouncement(announcementId, showLoading: false),
            ),
            AnnouncementDetailError() => _AnnouncementDetailErrorView(
              message: state.message,
              onRetry: () => context
                  .read<AnnouncementDetailCubit>()
                  .loadAnnouncement(announcementId),
            ),
            _ => const _AnnouncementDetailLoadingView(),
          },
        ),
      ),
    );
  }
}

class AnnouncementDetailView extends StatelessWidget {
  const AnnouncementDetailView({
    super.key,
    required this.announcement,
    required this.onRefresh,
  });

  final CommunityAnnouncement announcement;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    final wasUpdated =
        announcement.updatedAt.difference(announcement.createdAt).abs() >
        const Duration(minutes: 1);

    return RefreshIndicator(
      onRefresh: onRefresh,
      child: SelectionArea(
        child: ListView(
          key: const ValueKey('announcement-detail-scroll'),
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 48),
          children: [
            Semantics(
              label: 'Pengumuman dari Pengurus RT',
              child: const Row(
                children: [
                  _AnnouncementIcon(),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'PENGUMUMAN WARGA',
                          style: TextStyle(
                            color: KompakColors.primary,
                            fontSize: 12,
                            letterSpacing: 0.8,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        SizedBox(height: 3),
                        Text(
                          'Diterbitkan oleh Pengurus RT',
                          style: TextStyle(
                            color: KompakColors.mutedInk,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),
            Text(
              announcement.title,
              key: const ValueKey('announcement-detail-title'),
              style: const TextStyle(
                color: KompakColors.ink,
                fontSize: 28,
                height: 1.2,
                letterSpacing: -0.4,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                const Icon(
                  Icons.schedule_rounded,
                  color: KompakColors.mutedInk,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _dateLabel(announcement.createdAt),
                    style: const TextStyle(
                      color: KompakColors.mutedInk,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
            if (wasUpdated) ...[
              const SizedBox(height: 6),
              Padding(
                padding: const EdgeInsets.only(left: 26),
                child: Text(
                  'Diperbarui ${_dateLabel(announcement.updatedAt)}',
                  style: const TextStyle(
                    color: KompakColors.mutedInk,
                    fontSize: 13,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            ],
            const SizedBox(height: 24),
            const Divider(color: KompakColors.outline),
            const SizedBox(height: 24),
            Text(
              announcement.description,
              key: const ValueKey('announcement-detail-description'),
              style: const TextStyle(
                color: KompakColors.ink,
                fontSize: 16,
                height: 1.65,
                fontWeight: FontWeight.w400,
              ),
            ),
            const SizedBox(height: 36),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: KompakColors.softSurface,
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.info_outline_rounded,
                    color: KompakColors.primary,
                    size: 22,
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Pantau halaman utama untuk informasi terbaru dari pengurus lingkungan Anda.',
                      style: TextStyle(
                        color: KompakColors.mutedInk,
                        fontSize: 14,
                        height: 1.45,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AnnouncementIcon extends StatelessWidget {
  const _AnnouncementIcon();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: KompakColors.primarySurface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Icon(
        Icons.campaign_outlined,
        color: KompakColors.primary,
        size: 26,
      ),
    );
  }
}

class _AnnouncementDetailLoadingView extends StatelessWidget {
  const _AnnouncementDetailLoadingView();

  @override
  Widget build(BuildContext context) {
    return ListView(
      key: const ValueKey('announcement-detail-loading'),
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 48),
      children: const [
        Row(
          children: [
            _Skeleton(width: 48, height: 48, radius: 12),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _Skeleton(width: 132, height: 12),
                  SizedBox(height: 8),
                  _Skeleton(width: 190, height: 14),
                ],
              ),
            ),
          ],
        ),
        SizedBox(height: 30),
        _Skeleton(height: 32),
        SizedBox(height: 10),
        _Skeleton(width: 245, height: 32),
        SizedBox(height: 18),
        _Skeleton(width: 185, height: 14),
        SizedBox(height: 26),
        Divider(color: KompakColors.outline),
        SizedBox(height: 24),
        _Skeleton(height: 16),
        SizedBox(height: 12),
        _Skeleton(height: 16),
        SizedBox(height: 12),
        _Skeleton(width: 280, height: 16),
        SizedBox(height: 12),
        _Skeleton(height: 16),
        SizedBox(height: 12),
        _Skeleton(width: 215, height: 16),
      ],
    );
  }
}

class _Skeleton extends StatelessWidget {
  const _Skeleton({this.width, required this.height, this.radius = 7});

  final double? width;
  final double height;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: KompakColors.softSurface,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}

class _AnnouncementDetailErrorView extends StatelessWidget {
  const _AnnouncementDetailErrorView({
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: const BoxDecoration(
                color: KompakColors.errorSurface,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.campaign_outlined,
                color: KompakColors.error,
                size: 30,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Pengumuman tidak dapat dibuka',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: KompakColors.ink,
                fontSize: 19,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              key: const ValueKey('announcement-detail-error-message'),
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: KompakColors.mutedInk,
                fontSize: 14,
                height: 1.45,
              ),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              key: const ValueKey('announcement-detail-retry'),
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Coba Lagi'),
            ),
          ],
        ),
      ),
    );
  }
}

const _months = [
  'Januari',
  'Februari',
  'Maret',
  'April',
  'Mei',
  'Juni',
  'Juli',
  'Agustus',
  'September',
  'Oktober',
  'November',
  'Desember',
];

String _dateLabel(DateTime value) {
  final local = value.toLocal();
  final hour = local.hour.toString().padLeft(2, '0');
  final minute = local.minute.toString().padLeft(2, '0');
  return '${local.day} ${_months[local.month - 1]} ${local.year} • $hour.$minute';
}
