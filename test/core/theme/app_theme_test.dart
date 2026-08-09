import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kompak_app/core/theme/app_theme.dart';

void main() {
  test('uses Kompak blue for inherited Material controls', () {
    final theme = AppTheme.light;

    expect(theme.colorScheme.primary, KompakColors.primary);
    expect(
      theme.textButtonTheme.style?.foregroundColor?.resolve({}),
      KompakColors.primary,
    );
    expect(theme.datePickerTheme.backgroundColor, KompakColors.surface);
    expect(
      theme.datePickerTheme.dayBackgroundColor?.resolve({WidgetState.selected}),
      KompakColors.primary,
    );
    expect(
      theme.datePickerTheme.confirmButtonStyle?.foregroundColor?.resolve({}),
      KompakColors.primary,
    );
  });
}
