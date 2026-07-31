import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/routes/app_router.dart';
import '../widgets/profile_view.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../../../auth/presentation/bloc/auth_state.dart';

@RoutePage()
class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<AuthBloc>(),
      child: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthUnauthenticated) {
            context.router.replaceAll([const LoginRoute()]);
          }
        },
        child: Builder(
          builder: (context) => ProfileView(
            data: ProfileViewData.placeholder,
            onBack: () => context.router.maybePop(),
            onForgotPassword: () =>
                context.router.push(const ForgotPasswordRoute()),
            onHelpPhoneTap: () => _copyHelpPhone(context),
            onLogout: () => context.read<AuthBloc>().add(LogoutRequested()),
            onNavigationSelected: (index) => _openMainTab(context, index),
          ),
        ),
      ),
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
