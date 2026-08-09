import 'package:flutter/material.dart';

abstract final class KompakColors {
  static const primary = Color(0xFF2563EB);
  static const primaryPressed = Color(0xFF1D4ED8);
  static const primaryDisabled = Color(0xFFAFC4F9);
  static const primarySurface = Color(0xFFF1F5FF);
  static const primaryBorder = Color(0xFF8BA6FF);
  static const scannerBorder = Color(0xFFBBCFF9);
  static const scannerGuide = Color(0xFF5182EF);
  static const success = Color(0xFF12B76A);
  static const successSurface = Color(0xFFE7F8F0);
  static const surface = Colors.white;
  static const ink = Color(0xFF20242C);
  static const mutedInk = Color(0xFF5F6672);
  static const outline = Color(0xFFD6DAE1);
}

abstract final class AppTheme {
  static ThemeData get light {
    final colorScheme =
        ColorScheme.fromSeed(
          seedColor: KompakColors.primary,
          brightness: Brightness.light,
        ).copyWith(
          primary: KompakColors.primary,
          onPrimary: Colors.white,
          surface: KompakColors.surface,
          onSurface: KompakColors.ink,
          outline: KompakColors.outline,
          surfaceContainerHigh: KompakColors.surface,
          surfaceContainerHighest: KompakColors.primarySurface,
        );

    final primaryTextButton = TextButton.styleFrom(
      foregroundColor: KompakColors.primary,
      disabledForegroundColor: KompakColors.primaryDisabled,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: KompakColors.surface,
      dialogTheme: const DialogThemeData(
        backgroundColor: KompakColors.surface,
        surfaceTintColor: Colors.transparent,
      ),
      textButtonTheme: TextButtonThemeData(style: primaryTextButton),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: KompakColors.primary,
      ),
      datePickerTheme: DatePickerThemeData(
        backgroundColor: KompakColors.surface,
        surfaceTintColor: Colors.transparent,
        headerBackgroundColor: KompakColors.primarySurface,
        headerForegroundColor: KompakColors.ink,
        dividerColor: KompakColors.outline,
        dayBackgroundColor: WidgetStateProperty.resolveWith((states) {
          return states.contains(WidgetState.selected)
              ? KompakColors.primary
              : Colors.transparent;
        }),
        dayForegroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return Colors.white;
          if (states.contains(WidgetState.disabled)) {
            return KompakColors.mutedInk.withValues(alpha: 0.45);
          }
          return KompakColors.ink;
        }),
        todayForegroundColor: const WidgetStatePropertyAll(
          KompakColors.primary,
        ),
        todayBorder: const BorderSide(color: KompakColors.primary),
        cancelButtonStyle: primaryTextButton,
        confirmButtonStyle: primaryTextButton,
      ),
    );
  }
}
