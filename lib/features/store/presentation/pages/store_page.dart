import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/injection.dart';
import '../bloc/store_cubit.dart';
import '../bloc/store_state.dart';
import '../widgets/store_points_card.dart';
import '../widgets/category_chips.dart';
import '../widgets/featured_store_item.dart';
import '../widgets/store_item_grid_card.dart';
import '../../../../core/routes/app_router.dart';

@RoutePage()
class StorePage extends StatelessWidget {
  const StorePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<StoreCubit>()..loadStoreData(),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: BlocBuilder<StoreCubit, StoreState>(
            builder: (context, state) {
              if (state is StoreLoading) {
                return const Center(child: CircularProgressIndicator());
              } else if (state is StoreError) {
                return Center(child: Text(state.message));
              } else if (state is StoreLoaded) {
                return CustomScrollView(
                  slivers: [
                    SliverPadding(
                      padding: const EdgeInsets.all(20),
                      sliver: SliverList(
                        delegate: SliverChildListDelegate([
                          StorePointsCard(
                            stats: state.stats,
                            onHistoryTap: () {
                              context.router.push(const PointHistoryRoute());
                            },
                          ),
                          const SizedBox(height: 24),
                          CategoryChips(
                            categories: state.categories,
                            activeCategoryId: state.activeCategoryId,
                            onCategorySelected: (id) {
                              context.read<StoreCubit>().changeCategory(id);
                            },
                          ),
                          const SizedBox(height: 24),
                          if (state.featuredItem != null) ...[
                            FeaturedStoreItem(
                              item: state.featuredItem!,
                              onRedeem: () {},
                            ),
                            const SizedBox(height: 24),
                          ],
                        ]),
                      ),
                    ),
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      sliver: SliverGrid(
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              childAspectRatio:
                                  0.75, // Adjust for image+text+button
                              crossAxisSpacing: 16,
                              mainAxisSpacing: 16,
                            ),
                        delegate: SliverChildBuilderDelegate((context, index) {
                          return StoreItemGridCard(
                            item: state.regularItems[index],
                            onRedeem: () {},
                          );
                        }, childCount: state.regularItems.length),
                      ),
                    ),
                    SliverPadding(
                      padding: const EdgeInsets.all(20),
                      sliver: SliverList(
                        delegate: SliverChildListDelegate([
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: const Color(0xFFEFF6FF), // Blue 50
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: const BoxDecoration(
                                    color: Color(0xFF2563EB), // Blue 600
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.mood,
                                    color: Colors.white,
                                    size: 24,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Butuh Poin Tambahan?',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Ikuti kerja bakti atau bayar iuran tepat waktu untuk mendapatkan bonus poin.',
                                        style: TextStyle(
                                          color: Colors.grey.shade600,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20), // Bottom padding
                        ]),
                      ),
                    ),
                  ],
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ),
      ),
    );
  }
}
