import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/user_avatar.dart';

enum ProfileAccountMode { resident, admin }

Future<void> showProfileModeMenu({
  required BuildContext context,
  required WidgetBuilder builder,
}) {
  return showGeneralDialog<void>(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'Tutup menu profil',
    barrierColor: Colors.black.withValues(alpha: 0.28),
    transitionDuration: const Duration(milliseconds: 220),
    pageBuilder: (dialogContext, _, _) =>
        Align(alignment: Alignment.topCenter, child: builder(dialogContext)),
    transitionBuilder: (_, animation, _, child) {
      final curved = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
      );
      return SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, -0.08),
          end: Offset.zero,
        ).animate(curved),
        child: FadeTransition(opacity: curved, child: child),
      );
    },
  );
}

class ProfileModeSheet extends StatelessWidget {
  const ProfileModeSheet({
    super.key,
    required this.name,
    required this.email,
    required this.canAccessAdmin,
    required this.onOpenProfile,
    required this.onSwitchProvider,
    required this.onLogout,
    this.currentMode = ProfileAccountMode.resident,
    this.onSwitchResident,
    this.onSwitchAdmin,
  });

  final String name;
  final String email;
  final bool canAccessAdmin;
  final VoidCallback onOpenProfile;
  final VoidCallback onSwitchProvider;
  final VoidCallback onLogout;
  final ProfileAccountMode currentMode;
  final VoidCallback? onSwitchResident;
  final VoidCallback? onSwitchAdmin;

  @override
  Widget build(BuildContext context) {
    final statusBarInset = MediaQuery.paddingOf(context).top;
    return Material(
      color: Colors.white,
      borderRadius: const BorderRadius.vertical(bottom: Radius.circular(22)),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: EdgeInsets.fromLTRB(20, statusBarInset + 16, 20, 18),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _AccountRow(
              name: name,
              email: email,
              accountLabel: currentMode == ProfileAccountMode.admin
                  ? 'Akun Admin'
                  : 'Akun Warga',
              onTap: onOpenProfile,
            ),
            const _SheetDivider(),
            if (currentMode == ProfileAccountMode.admin &&
                onSwitchResident != null)
              _SheetAction(
                key: const ValueKey('profile-sheet-resident-mode'),
                icon: Icons.home_outlined,
                label: 'Beralih ke Warga',
                onTap: onSwitchResident!,
              ),
            if (currentMode == ProfileAccountMode.resident &&
                canAccessAdmin &&
                onSwitchAdmin != null)
              _SheetAction(
                key: const ValueKey('profile-sheet-admin-mode'),
                icon: Icons.admin_panel_settings_outlined,
                label: 'Beralih ke Admin',
                onTap: onSwitchAdmin!,
              ),
            _SheetAction(
              key: const ValueKey('profile-sheet-provider-mode'),
              icon: Icons.storefront_outlined,
              label: 'Beralih ke akun UMKM',
              onTap: onSwitchProvider,
            ),
            const _SheetDivider(),
            _SheetAction(
              key: const ValueKey('profile-sheet-logout'),
              icon: Icons.logout_rounded,
              label: 'Log out',
              foregroundColor: const Color(0xFFD92D20),
              showChevron: false,
              onTap: onLogout,
            ),
          ],
        ),
      ),
    );
  }
}

class _AccountRow extends StatelessWidget {
  const _AccountRow({
    required this.name,
    required this.email,
    required this.accountLabel,
    required this.onTap,
  });

  final String name;
  final String email;
  final String accountLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Buka profil $name',
      child: InkWell(
        key: const ValueKey('profile-sheet-account'),
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              UserAvatar(
                name: name,
                size: 58,
                borderColor: KompakColors.success,
                borderWidth: 3,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: KompakColors.ink,
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      email,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: KompakColors.mutedInk,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 6),
                    _AccountPill(label: accountLabel),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                color: KompakColors.mutedInk,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AccountPill extends StatelessWidget {
  const _AccountPill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xFFF0F1F3),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        child: Text(
          label,
          style: const TextStyle(
            color: KompakColors.ink,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _SheetAction extends StatelessWidget {
  const _SheetAction({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
    this.foregroundColor = KompakColors.ink,
    this.showChevron = true,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color foregroundColor;
  final bool showChevron;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 13),
          child: Row(
            children: [
              Icon(icon, color: foregroundColor, size: 25),
              const SizedBox(width: 18),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    color: foregroundColor,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              if (showChevron)
                Icon(
                  Icons.chevron_right_rounded,
                  color: foregroundColor.withValues(alpha: 0.72),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SheetDivider extends StatelessWidget {
  const _SheetDivider();

  @override
  Widget build(BuildContext context) =>
      const Divider(height: 20, thickness: 1, color: KompakColors.outline);
}
