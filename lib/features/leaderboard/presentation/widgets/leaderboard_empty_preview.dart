import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';

class LeaderboardEmptyPreview extends StatelessWidget {
  const LeaderboardEmptyPreview({super.key, required this.onRefresh});

  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
            sliver: SliverList.list(
              children: const [
                _EarnPointsCallout(),
                SizedBox(height: 26),
                _PodiumPreview(),
                SizedBox(height: 24),
                _StatsPreview(),
                SizedBox(height: 26),
                Text(
                  'Peringkat Lainnya',
                  style: TextStyle(
                    color: KompakColors.ink,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 10),
                _ListPreview(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _EarnPointsCallout extends StatelessWidget {
  const _EarnPointsCallout();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: KompakColors.primarySurface,
        borderRadius: BorderRadius.circular(14),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: KompakColors.primary,
            child: Icon(
              Icons.emoji_events_outlined,
              color: Colors.white,
              size: 24,
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Belum ada peringkat bulan ini',
                  style: TextStyle(
                    color: KompakColors.ink,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  'Ikuti kegiatan dan lakukan presensi untuk mengumpulkan poin kontribusi.',
                  style: TextStyle(
                    color: KompakColors.mutedInk,
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PodiumPreview extends StatelessWidget {
  const _PodiumPreview();

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: SizedBox(
        key: const ValueKey('leaderboard-empty-podium-preview'),
        height: 240,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: const [
            Expanded(child: _PodiumSlot(height: 104, avatarSize: 50)),
            SizedBox(width: 10),
            Expanded(child: _PodiumSlot(height: 142, avatarSize: 62)),
            SizedBox(width: 10),
            Expanded(child: _PodiumSlot(height: 84, avatarSize: 50)),
          ],
        ),
      ),
    );
  }
}

class _PodiumSlot extends StatelessWidget {
  const _PodiumSlot({required this.height, required this.avatarSize});

  final double height;
  final double avatarSize;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        _Skeleton(width: avatarSize, height: avatarSize, radius: avatarSize),
        const SizedBox(height: 8),
        const _Skeleton(width: 64, height: 10),
        const SizedBox(height: 8),
        _Skeleton(height: height, radius: 12),
      ],
    );
  }
}

class _StatsPreview extends StatelessWidget {
  const _StatsPreview();

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: Row(
        key: const ValueKey('leaderboard-empty-stats-preview'),
        children: const [
          Expanded(child: _PreviewMetric(label: 'TOTAL\nPARTISIPASI')),
          SizedBox(width: 12),
          Expanded(child: _PreviewMetric(label: 'POIN\nTERKUMPUL')),
        ],
      ),
    );
  }
}

class _PreviewMetric extends StatelessWidget {
  const _PreviewMetric({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 136,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: KompakColors.softSurface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: KompakColors.mutedInk,
              fontSize: 12,
              fontWeight: FontWeight.w600,
              height: 1.45,
            ),
          ),
          const Spacer(),
          const _Skeleton(width: 72, height: 20),
          const SizedBox(height: 7),
          const _Skeleton(width: 48, height: 9),
        ],
      ),
    );
  }
}

class _ListPreview extends StatelessWidget {
  const _ListPreview();

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: Column(
        key: const ValueKey('leaderboard-empty-list-preview'),
        children: const [
          _PreviewRow(rank: '4'),
          SizedBox(height: 10),
          _PreviewRow(rank: '5'),
          SizedBox(height: 10),
          _PreviewRow(rank: '6'),
        ],
      ),
    );
  }
}

class _PreviewRow extends StatelessWidget {
  const _PreviewRow({required this.rank});

  final String rank;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 68,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: KompakColors.softSurface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 22,
            child: Text(
              rank,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: KompakColors.mutedInk,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 12),
          const _Skeleton(width: 38, height: 38, radius: 38),
          const SizedBox(width: 12),
          const Expanded(child: _Skeleton(height: 11)),
          const SizedBox(width: 30),
          const _Skeleton(width: 34, height: 11),
        ],
      ),
    );
  }
}

class _Skeleton extends StatelessWidget {
  const _Skeleton({this.width, required this.height, this.radius = 6});

  final double? width;
  final double height;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: const Color(0xFFE4E9F2),
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}
