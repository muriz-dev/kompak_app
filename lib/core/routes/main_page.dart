import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

import 'app_router.dart';

@RoutePage()
class MainPage extends StatelessWidget {
  const MainPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AutoTabsRouter(
      routes: const [
        HomeRoute(),
        AttendanceRoute(),
        StoreRoute(),
        LeaderboardRoute(),
      ],
      transitionBuilder: (context, child, animation) => FadeTransition(
        opacity: animation,
        child: child,
      ),
      builder: (context, child) {
        final tabsRouter = AutoTabsRouter.of(context);
        return Scaffold(
          body: child,
          bottomNavigationBar: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: SafeArea(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildNavItem(
                    context: context,
                    icon: Icons.home_filled,
                    label: 'Home',
                    index: 0,
                    activeIndex: tabsRouter.activeIndex,
                    onTap: (idx) => tabsRouter.setActiveIndex(idx),
                  ),
                  _buildNavItem(
                    context: context,
                    icon: Icons.how_to_reg, // or Icons.person_add_alt_1 / Icons.how_to_reg
                    label: 'Absensi',
                    index: 1,
                    activeIndex: tabsRouter.activeIndex,
                    onTap: (idx) => tabsRouter.setActiveIndex(idx),
                  ),
                  _buildNavItem(
                    context: context,
                    icon: Icons.storefront,
                    label: 'Toko',
                    index: 2,
                    activeIndex: tabsRouter.activeIndex,
                    onTap: (idx) => tabsRouter.setActiveIndex(idx),
                  ),
                  _buildNavItem(
                    context: context,
                    icon: Icons.stars,
                    label: 'Peringkat',
                    index: 3,
                    activeIndex: tabsRouter.activeIndex,
                    onTap: (idx) => tabsRouter.setActiveIndex(idx),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildNavItem({
    required BuildContext context,
    required IconData icon,
    required String label,
    required int index,
    required int activeIndex,
    required Function(int) onTap,
  }) {
    final isActive = index == activeIndex;
    return GestureDetector(
      onTap: () => onTap(index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(
          horizontal: isActive ? 20 : 12,
          vertical: isActive ? 10 : 8,
        ),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFF2563EB) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isActive ? Colors.white : Colors.black87,
              size: isActive ? 20 : 24,
            ),
            if (isActive) const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                color: isActive ? Colors.white : Colors.black54,
                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                fontSize: isActive ? 12 : 10,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
