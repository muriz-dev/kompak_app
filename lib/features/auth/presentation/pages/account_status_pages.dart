import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_theme.dart';
import '../session/session_cubit.dart';
import '../session/session_state.dart';

@RoutePage()
class PendingApprovalPage extends StatefulWidget {
  const PendingApprovalPage({super.key});

  @override
  State<PendingApprovalPage> createState() => _PendingApprovalPageState();
}

class _PendingApprovalPageState extends State<PendingApprovalPage>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      context.read<SessionCubit>().refreshSession();
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SessionCubit, SessionState>(
      listener: (context, state) {
        if (state is SessionFailure) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(SnackBar(content: Text(state.message)));
          return;
        }
      },
      builder: (context, state) => _AccountStatusScaffold(
        icon: Icons.hourglass_top_rounded,
        iconColor: KompakColors.primary,
        iconBackground: const Color(0xFFE8F0FF),
        title: 'Menunggu Persetujuan',
        message:
            'Pendaftaran Anda sedang diperiksa oleh pengurus. Cek kembali untuk melihat status terbaru akun Anda.',
        primaryLabel: 'Cek Status',
        loading: state is SessionChecking,
        onPrimary: context.read<SessionCubit>().refreshSession,
        onLogout: context.read<SessionCubit>().logout,
      ),
    );
  }
}

@RoutePage()
class RejectedAccountPage extends StatelessWidget {
  const RejectedAccountPage({super.key});

  @override
  Widget build(BuildContext context) => _AccountStatusScaffold(
    icon: Icons.close_rounded,
    iconColor: const Color(0xFFD92D20),
    iconBackground: const Color(0xFFFEE4E2),
    title: 'Pendaftaran Ditolak',
    message:
        'Pendaftaran Anda belum dapat disetujui. Silakan hubungi pengurus lingkungan untuk informasi lebih lanjut.',
    primaryLabel: 'Kembali ke Login',
    onPrimary: context.read<SessionCubit>().logout,
  );
}

@RoutePage()
class BlockedAccountPage extends StatelessWidget {
  const BlockedAccountPage({super.key});

  @override
  Widget build(BuildContext context) => _AccountStatusScaffold(
    icon: Icons.lock_outline_rounded,
    iconColor: KompakColors.mutedInk,
    iconBackground: const Color(0xFFF2F4F7),
    title: 'Akun Tidak Aktif',
    message:
        'Akun ini sedang tidak aktif. Silakan hubungi pengurus lingkungan untuk mendapatkan bantuan.',
    primaryLabel: 'Kembali ke Login',
    onPrimary: context.read<SessionCubit>().logout,
  );
}

class _AccountStatusScaffold extends StatelessWidget {
  const _AccountStatusScaffold({
    required this.icon,
    required this.iconColor,
    required this.iconBackground,
    required this.title,
    required this.message,
    required this.primaryLabel,
    required this.onPrimary,
    this.onLogout,
    this.loading = false,
  });

  final IconData icon;
  final Color iconColor;
  final Color iconBackground;
  final String title;
  final String message;
  final String primaryLabel;
  final VoidCallback onPrimary;
  final VoidCallback? onLogout;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const Spacer(),
              Container(
                width: 88,
                height: 88,
                decoration: BoxDecoration(
                  color: iconBackground,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: iconColor, size: 44),
              ),
              const SizedBox(height: 24),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: KompakColors.ink,
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: KompakColors.mutedInk,
                  fontSize: 16,
                  height: 1.5,
                ),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: loading ? null : onPrimary,
                  child: loading
                      ? const SizedBox.square(
                          dimension: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(primaryLabel),
                ),
              ),
              if (onLogout != null) ...[
                const SizedBox(height: 12),
                TextButton(onPressed: onLogout, child: const Text('Keluar')),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
