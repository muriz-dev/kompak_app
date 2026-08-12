import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/di/injection.dart';
import '../../../../../core/routes/app_router.dart';
import '../../../../../core/theme/app_theme.dart';
import '../../../providers/domain/entities/admin_point_shop_product.dart';
import '../../domain/entities/admin_leaderboard_reward.dart';
import '../bloc/admin_leaderboard_rewards_cubit.dart';
import '../bloc/admin_leaderboard_rewards_state.dart';

@RoutePage()
class AdminLeaderboardRewardsPage extends StatelessWidget {
  const AdminLeaderboardRewardsPage({super.key});

  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (_) => getIt<AdminLeaderboardRewardsCubit>()..load(),
    child: const _AdminLeaderboardRewardsView(),
  );
}

class _AdminLeaderboardRewardsView extends StatelessWidget {
  const _AdminLeaderboardRewardsView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFEFFFF),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFEFFFF),
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          onPressed: () => context.router.maybePop(),
          icon: const Icon(Icons.chevron_left_rounded, size: 28),
        ),
        title: const Text(
          'Hadiah Peringkat',
          style: TextStyle(
            color: Color(0xFF2F3236),
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body:
          BlocBuilder<
            AdminLeaderboardRewardsCubit,
            AdminLeaderboardRewardsState
          >(
            builder: (context, state) => switch (state) {
              AdminLeaderboardRewardsLoaded() => RefreshIndicator(
                onRefresh: context.read<AdminLeaderboardRewardsCubit>().refresh,
                child: ListView(
                  key: const ValueKey('admin-leaderboard-rewards-scroll'),
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
                  children: [
                    for (var position = 1; position <= 3; position++) ...[
                      _RankRewardSlot(
                        position: position,
                        reward: state.rewardAt(position),
                        onChanged: () => context
                            .read<AdminLeaderboardRewardsCubit>()
                            .refresh(),
                      ),
                      if (position < 3) const SizedBox(height: 16),
                    ],
                    const SizedBox(height: 20),
                    const _ResetRuleCard(),
                  ],
                ),
              ),
              AdminLeaderboardRewardsFailure() => _FailureView(
                message: state.message,
                onRetry: context.read<AdminLeaderboardRewardsCubit>().load,
              ),
              _ => const Center(child: CircularProgressIndicator()),
            },
          ),
    );
  }
}

class _RankRewardSlot extends StatelessWidget {
  const _RankRewardSlot({
    required this.position,
    required this.reward,
    required this.onChanged,
  });

  final int position;
  final AdminLeaderboardReward? reward;
  final VoidCallback onChanged;

  Color get color => switch (position) {
    1 => KompakColors.warning,
    2 => KompakColors.success,
    _ => KompakColors.primary,
  };

  String get ordinal => switch (position) {
    1 => '1st',
    2 => '2nd',
    _ => '3rd',
  };

  Future<void> _openEditor(BuildContext context) async {
    await context.router.push(
      AdminLeaderboardRewardFormRoute(position: position, reward: reward),
    );
    onChanged();
  }

  @override
  Widget build(BuildContext context) {
    final item = reward;
    if (item == null) {
      return InkWell(
        key: ValueKey('leaderboard-reward-empty-$position'),
        onTap: () => _openEditor(context),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          height: 154,
          decoration: BoxDecoration(
            color: const Color(0xFFFEFFFF),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: const Color(0xFFE2E4E5),
              width: 2,
              strokeAlign: BorderSide.strokeAlignInside,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                ordinal,
                style: TextStyle(
                  color: color,
                  fontSize: 25,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Hadiah masih kosong',
                style: TextStyle(
                  color: Color(0xFF3D4A42),
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 3),
              const Text(
                'Ketuk untuk menambahkan\nhadiah terlebih dahulu',
                textAlign: TextAlign.center,
                style: TextStyle(color: Color(0xFFB0B2B3), fontSize: 11),
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      key: ValueKey('leaderboard-reward-$position'),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFF1F1F2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Stack(
            children: [
              _RewardImage(reward: item, height: 150),
              Positioned(
                top: 10,
                right: 10,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 11,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    'Peringkat $position',
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(13),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  item.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF2F3236),
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 7),
                Text(
                  'Stock: ${item.stock}',
                  style: const TextStyle(
                    color: Color(0xFFB0B2B3),
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 13),
                FilledButton(
                  onPressed: () => _openEditor(context),
                  style: FilledButton.styleFrom(
                    backgroundColor: KompakColors.success,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Edit Hadiah'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ResetRuleCard extends StatelessWidget {
  const _ResetRuleCard();

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: const Color(0xFFE9EFFD),
      borderRadius: BorderRadius.circular(12),
    ),
    child: Column(
      children: [
        const Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: Color(0xFF316BF3),
              child: Icon(Icons.refresh_rounded, color: Colors.white),
            ),
            SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Aturan Reset Otomatis',
                    style: TextStyle(
                      color: Color(0xFF2F3236),
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 3),
                  Text(
                    'Leaderboard menggunakan periode distribusi bulanan.',
                    style: TextStyle(color: Color(0xFF8D9199), fontSize: 13),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        DropdownButtonFormField<String>(
          isExpanded: true,
          initialValue: 'MONTHLY',
          items: const [
            DropdownMenuItem(
              value: 'MONTHLY',
              child: Text('Bulanan (Standard)'),
            ),
          ],
          onChanged: null,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 8,
            ),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
      ],
    ),
  );
}

class _RewardImage extends StatelessWidget {
  const _RewardImage({required this.reward, required this.height});
  final AdminLeaderboardReward reward;
  final double height;

  @override
  Widget build(BuildContext context) {
    final fallback = ColoredBox(
      color: KompakColors.primarySurface,
      child: Center(
        child: Icon(
          switch (reward.type) {
            AdminPointShopProductType.voucher =>
              Icons.confirmation_number_outlined,
            AdminPointShopProductType.product => Icons.redeem_outlined,
            AdminPointShopProductType.service => Icons.handyman_outlined,
            AdminPointShopProductType.other => Icons.card_giftcard_outlined,
          },
          size: 46,
          color: KompakColors.primary,
        ),
      ),
    );
    final url = reward.imageUrl;
    return SizedBox(
      height: height,
      width: double.infinity,
      child: url != null && url.isNotEmpty
          ? Image.network(
              url,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => fallback,
            )
          : fallback,
    );
  }
}

class _FailureView extends StatelessWidget {
  const _FailureView({required this.message, required this.onRetry});
  final String message;
  final Future<void> Function({bool showLoading}) onRetry;

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.cloud_off_outlined, size: 44),
          const SizedBox(height: 12),
          Text(message, textAlign: TextAlign.center),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: () => onRetry(),
            child: const Text('Coba Lagi'),
          ),
        ],
      ),
    ),
  );
}
