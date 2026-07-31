import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

import '../widgets/kompak_bottom_navigation.dart';
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
      transitionBuilder: (context, child, animation) =>
          FadeTransition(opacity: animation, child: child),
      builder: (context, child) {
        final tabsRouter = AutoTabsRouter.of(context);
        return Scaffold(
          body: child,
          bottomNavigationBar: KompakBottomNavigation(
            currentIndex: tabsRouter.activeIndex,
            onSelected: tabsRouter.setActiveIndex,
          ),
        );
      },
    );
  }
}
