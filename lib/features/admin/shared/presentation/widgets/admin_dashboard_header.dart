import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../../core/theme/app_theme.dart';
import '../../../../../core/widgets/user_avatar.dart';

class AdminDashboardHeader extends StatelessWidget {
  const AdminDashboardHeader({
    super.key,
    required this.userName,
    required this.onProfileTap,
  });

  final String userName;
  final VoidCallback onProfileTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 52,
      child: Row(
        children: [
          Expanded(
            child: Row(
              children: [
                Flexible(
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: SvgPicture.asset(
                      'assets/images/brand_logo_blue.svg',
                      width: 148,
                      height: 44,
                      fit: BoxFit.contain,
                      alignment: Alignment.centerLeft,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  key: const ValueKey('admin-mode-badge'),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: KompakColors.primarySurface,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: const Text(
                    'Admin',
                    style: TextStyle(
                      color: KompakColors.primary,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Semantics(
            button: true,
            label: 'Buka menu akun admin',
            child: Material(
              color: Colors.transparent,
              shape: const CircleBorder(),
              child: InkWell(
                key: const ValueKey('admin-profile-button'),
                onTap: onProfileTap,
                customBorder: const CircleBorder(),
                child: UserAvatar(
                  name: userName,
                  size: 48,
                  borderColor: KompakColors.primary,
                  borderWidth: 3,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
