import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';

import '../../../../core/widgets/kompak_bottom_navigation.dart';
import '../../../../core/widgets/user_avatar.dart';
import '../../../auth/domain/entities/session_user.dart';

const _profileBlue = Color(0xFF2F67E8);
const _profileGreen = Color(0xFF0DBA75);
const _profileInk = Color(0xFF292D33);
const _profileMuted = Color(0xFF68707A);
const _fieldFill = Color(0xFFF0F1F3);

class ProfileViewData {
  const ProfileViewData({
    required this.name,
    required this.phone,
    required this.birthDate,
    required this.email,
  });

  factory ProfileViewData.fromSessionUser(SessionUser user) => ProfileViewData(
    name: user.name,
    phone: user.phoneNumber,
    birthDate: _formatBirthDate(user.birthDate),
    email: user.email,
  );

  static const helpPhone = '081234567890';

  final String name;
  final String phone;
  final String birthDate;
  final String email;
}

String _formatBirthDate(String value) {
  final date = DateTime.tryParse(value);
  return date == null ? value : DateFormat('dd/MM/yyyy').format(date);
}

class ProfileView extends StatefulWidget {
  const ProfileView({
    super.key,
    required this.data,
    required this.onBack,
    required this.onForgotPassword,
    required this.onHelpPhoneTap,
    required this.onLogout,
    required this.onNavigationSelected,
  });

  final ProfileViewData data;
  final VoidCallback onBack;
  final VoidCallback onForgotPassword;
  final VoidCallback onHelpPhoneTap;
  final VoidCallback onLogout;
  final ValueChanged<int> onNavigationSelected;

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  final _scrollController = ScrollController();
  bool _showAvatar = true;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_handleScroll);
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_handleScroll)
      ..dispose();
    super.dispose();
  }

  void _handleScroll() {
    final shouldShowAvatar = _scrollController.offset < 36;
    if (shouldShowAvatar == _showAvatar) return;
    setState(() => _showAvatar = shouldShowAvatar);
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Stack(
          children: [
            const Positioned.fill(child: ColoredBox(color: Colors.white)),
            const Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: 260,
              child: _ProfileHeaderBackground(),
            ),
            Positioned(
              top: 220,
              left: 0,
              right: 0,
              bottom: 0,
              child: DecoratedBox(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
                ),
                child: SingleChildScrollView(
                  key: const ValueKey('profile-scroll-view'),
                  controller: _scrollController,
                  padding: const EdgeInsets.fromLTRB(26, 96, 26, 32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _PersonalInformationCard(data: widget.data),
                      const SizedBox(height: 26),
                      _AccountCard(
                        email: widget.data.email,
                        onForgotPassword: widget.onForgotPassword,
                      ),
                      const SizedBox(height: 26),
                      _HelpCard(onTap: widget.onHelpPhoneTap),
                      const SizedBox(height: 26),
                      SizedBox(
                        height: 52,
                        child: TextButton(
                          key: const ValueKey('profile-logout-button'),
                          onPressed: widget.onLogout,
                          style: TextButton.styleFrom(
                            foregroundColor: const Color(0xFFF04438),
                            backgroundColor: const Color(0xFFFFE9E8),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: const Text(
                            'Log Out Akun',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 72),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              top: 164,
              left: 0,
              right: 0,
              child: IgnorePointer(
                ignoring: !_showAvatar,
                child: AnimatedOpacity(
                  opacity: _showAvatar ? 1 : 0,
                  duration: const Duration(milliseconds: 180),
                  curve: Curves.easeOutCubic,
                  child: AnimatedScale(
                    scale: _showAvatar ? 1 : 0.92,
                    duration: const Duration(milliseconds: 180),
                    curve: Curves.easeOutCubic,
                    child: Center(
                      child: UserAvatar(
                        name: widget.data.name,
                        size: 116,
                        borderColor: _profileGreen,
                        borderWidth: 4,
                        backgroundColor: const Color(0xFFE7EEFF),
                        foregroundColor: _profileBlue,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              top: MediaQuery.paddingOf(context).top + 10,
              left: 14,
              right: 14,
              child: _ProfileTopBar(onBack: widget.onBack),
            ),
          ],
        ),
        bottomNavigationBar: KompakBottomNavigation(
          currentIndex: 0,
          onSelected: widget.onNavigationSelected,
        ),
      ),
    );
  }
}

class _ProfileHeaderBackground extends StatelessWidget {
  const _ProfileHeaderBackground();

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: _profileBlue,
      child: IgnorePointer(
        child: Stack(
          clipBehavior: Clip.hardEdge,
          children: [
            Positioned(
              top: -56,
              right: -42,
              child: Transform.rotate(
                angle: math.pi / 18,
                child: Opacity(
                  opacity: 0.18,
                  child: SvgPicture.asset(
                    'assets/images/app_icon_white.svg',
                    width: 230,
                  ),
                ),
              ),
            ),
            Positioned(
              left: -58,
              bottom: -72,
              child: Transform.rotate(
                angle: -math.pi / 18,
                child: Opacity(
                  opacity: 0.18,
                  child: SvgPicture.asset(
                    'assets/images/app_icon_white.svg',
                    width: 210,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileTopBar extends StatelessWidget {
  const _ProfileTopBar({required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 52,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: IconButton(
              tooltip: 'Kembali',
              onPressed: onBack,
              icon: const Icon(Icons.chevron_left_rounded),
              iconSize: 32,
              color: Colors.white,
            ),
          ),
          const Text(
            'Profile Anda',
            style: TextStyle(
              color: Colors.white,
              fontSize: 21,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _PersonalInformationCard extends StatelessWidget {
  const _PersonalInformationCard({required this.data});

  final ProfileViewData data;

  @override
  Widget build(BuildContext context) {
    return _ProfileSection(
      child: Column(
        children: [
          _ReadOnlyProfileField(label: 'Nama Lengkap', value: data.name),
          const SizedBox(height: 18),
          _ReadOnlyProfileField(label: 'Nomor Telepon', value: data.phone),
          const SizedBox(height: 18),
          _ReadOnlyProfileField(label: 'Tanggal Lahir', value: data.birthDate),
        ],
      ),
    );
  }
}

class _AccountCard extends StatelessWidget {
  const _AccountCard({required this.email, required this.onForgotPassword});

  final String email;
  final VoidCallback onForgotPassword;

  @override
  Widget build(BuildContext context) {
    return _ProfileSection(
      child: Column(
        children: [
          _ReadOnlyProfileField(label: 'Email', value: email),
          const SizedBox(height: 18),
          const _ReadOnlyProfileField(label: 'Password', value: '*********'),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              key: const ValueKey('profile-forgot-password-button'),
              onPressed: onForgotPassword,
              style: TextButton.styleFrom(
                foregroundColor: _profileBlue,
                minimumSize: const Size(48, 44),
                padding: const EdgeInsets.only(left: 12, top: 8),
              ),
              child: const Text(
                'Lupa Password?',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileSection extends StatelessWidget {
  const _ProfileSection({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE6E8EB)),
      ),
      child: child,
    );
  }
}

class _ReadOnlyProfileField extends StatelessWidget {
  const _ReadOnlyProfileField({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      readOnly: true,
      label: '$label, $value',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: _profileInk,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            constraints: const BoxConstraints(minHeight: 58),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
            decoration: BoxDecoration(
              color: _fieldFill,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    value,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: _profileMuted,
                      fontSize: 15,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HelpCard extends StatelessWidget {
  const _HelpCard({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 26),
      decoration: BoxDecoration(
        color: _profileBlue,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Butuh Bantuan?',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Silahkan untuk menghubungi Ketua RT/RW dengan menghubungi nomor di bawah ini:',
            style: TextStyle(
              color: Colors.white,
              fontSize: 15,
              height: 1.35,
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(height: 16),
          Semantics(
            button: true,
            label: 'Salin nomor bantuan ${ProfileViewData.helpPhone}',
            child: Material(
              color: const Color(0xFFE7EEFF),
              borderRadius: BorderRadius.circular(14),
              child: InkWell(
                key: const ValueKey('profile-help-phone'),
                onTap: onTap,
                borderRadius: BorderRadius.circular(14),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 18,
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: const BoxDecoration(
                          color: _profileBlue,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.phone_outlined,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 14),
                      const Expanded(
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerLeft,
                          child: Text(
                            ': ${ProfileViewData.helpPhone}',
                            style: TextStyle(
                              color: _profileBlue,
                              fontSize: 24,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
