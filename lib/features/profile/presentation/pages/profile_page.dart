import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/routes/app_router.dart';
import '../widgets/profile_view.dart';
import '../../../auth/presentation/session/session_cubit.dart';
import '../../../auth/presentation/session/session_state.dart';

@RoutePage()
class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final sessionState = context.watch<SessionCubit>().state;
    if (sessionState is! SessionWithUser) {
      return const Scaffold(
        backgroundColor: Colors.white,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return ProfileView(
      data: ProfileViewData.fromSessionUser(sessionState.user),
      onBack: () => context.router.maybePop(),
      onForgotPassword: () => context.router.push(const ForgotPasswordRoute()),
      onHelpPhoneTap: () => _copyHelpPhone(context),
      onLogout: context.read<SessionCubit>().logout,
      onNavigationSelected: (index) => _openMainTab(context, index),
    );
  }

  Future<void> _copyHelpPhone(BuildContext context) async {
    await Clipboard.setData(
      const ClipboardData(text: ProfileViewData.helpPhone),
    );
    if (!context.mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(const SnackBar(content: Text('Nomor bantuan disalin.')));
  }

  void _openMainTab(BuildContext context, int index) {
    final childRoute = switch (index) {
      1 => const AttendanceRoute(),
      2 => const StoreRoute(),
      3 => const LeaderboardRoute(),
      _ => const HomeRoute(),
    };
    context.router.replaceAll([
      MainRoute(children: [childRoute]),
    ]);
  }
}
