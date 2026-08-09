import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../core/theme/app_theme.dart';
import '../session/session_cubit.dart';
import '../session/session_navigation.dart';
import '../session/session_state.dart';

@RoutePage()
class SessionGatePage extends StatefulWidget {
  const SessionGatePage({super.key});

  @override
  State<SessionGatePage> createState() => _SessionGatePageState();
}

class _SessionGatePageState extends State<SessionGatePage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final cubit = context.read<SessionCubit>();
      if (cubit.state is SessionInitial) {
        cubit.restoreSession();
      } else {
        replaceForSession(context, cubit.state);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SessionCubit, SessionState>(
      builder: (context, state) {
        return Scaffold(
          backgroundColor: KompakColors.primary,
          body: SafeArea(
            child: Center(
              child: state is SessionFailure
                  ? _SessionRetry(message: state.message)
                  : Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SvgPicture.asset(
                          'assets/images/brand_logo_white.svg',
                          height: 48,
                        ),
                        const SizedBox(height: 28),
                        const CircularProgressIndicator(color: Colors.white),
                      ],
                    ),
            ),
          ),
        );
      },
    );
  }
}

class _SessionRetry extends StatelessWidget {
  const _SessionRetry({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.cloud_off_rounded, color: Colors.white, size: 52),
          const SizedBox(height: 16),
          const Text(
            'Tidak dapat memeriksa sesi',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white70),
          ),
          const SizedBox(height: 24),
          FilledButton.tonal(
            onPressed: context.read<SessionCubit>().restoreSession,
            child: const Text('Coba Lagi'),
          ),
        ],
      ),
    );
  }
}
