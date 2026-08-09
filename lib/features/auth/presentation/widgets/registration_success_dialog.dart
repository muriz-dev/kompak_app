import 'dart:ui';

import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';

class RegistrationSuccessDialog extends StatelessWidget {
  const RegistrationSuccessDialog({required this.onLogin, super.key});

  final VoidCallback onLogin;

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Stack(
        fit: StackFit.expand,
        children: [
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
            child: const SizedBox.expand(),
          ),
          Center(
            child: Dialog(
              key: const ValueKey('registration-success-dialog'),
              insetPadding: const EdgeInsets.symmetric(horizontal: 24),
              elevation: 24,
              shadowColor: Colors.black.withValues(alpha: 0.25),
              backgroundColor: KompakColors.surface,
              surfaceTintColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 384),
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Semantics(
                        label: 'Pendaftaran berhasil',
                        image: true,
                        child: Container(
                          key: const ValueKey('registration-success-icon'),
                          width: 80,
                          height: 80,
                          alignment: Alignment.center,
                          decoration: const BoxDecoration(
                            color: KompakColors.success,
                            shape: BoxShape.circle,
                          ),
                          child: Container(
                            width: 40,
                            height: 40,
                            alignment: Alignment.center,
                            decoration: const BoxDecoration(
                              color: KompakColors.successSurface,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.check_rounded,
                              color: KompakColors.success,
                              size: 28,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'Berhasil Terdaftar',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: KompakColors.primary,
                          fontSize: 23,
                          height: 1.2,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Data wajah Anda telah berhasil\n'
                        'diverifikasi dan disimpan dalam sistem\n'
                        'KOMPAK.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Color(0xFF68696A),
                          fontSize: 16,
                          height: 1.2,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      const SizedBox(height: 32),
                      SizedBox(
                        width: double.infinity,
                        height: 44,
                        child: ElevatedButton(
                          key: const ValueKey(
                            'registration-success-login-button',
                          ),
                          onPressed: onLogin,
                          style: ElevatedButton.styleFrom(
                            elevation: 0,
                            backgroundColor: KompakColors.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'Login Sekarang',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w400,
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
