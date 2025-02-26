import 'package:flutter/material.dart' hide ThemeMode;

import 'package:domain/domain.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_weather/config/app_theme.dart';

void main() {
  group('AppTheme', () {
    test('getTheme returns lightTheme when platformBrightness is light', () {
      final theme = AppTheme.getTheme(
        mode: ThemeMode.light,
        brightness: Brightness.light,
      );
      expect(theme.brightness, Brightness.light);
      expect(theme.colorScheme.brightness, Brightness.light);
    });

    test('getTheme returns darkTheme when platformBrightness is dark', () {
      final theme = AppTheme.getTheme(
        mode: ThemeMode.dark,
        brightness: Brightness.dark,
      );
      expect(theme.brightness, Brightness.dark);
      expect(theme.colorScheme.brightness, Brightness.dark);
    });

    test('lightTheme has correct primary color based on seed color', () {
      final expectedPrimary = ColorScheme.fromSeed(
        seedColor: AppTheme.primaryColor,
        brightness: Brightness.light,
      ).primary;

      expect(AppTheme.lightTheme.colorScheme.primary, equals(expectedPrimary));
    });

    test('darkTheme has correct primary color based on seed color', () {
      final expectedPrimary = ColorScheme.fromSeed(
        seedColor: AppTheme.primaryColor,
        brightness: Brightness.dark,
      ).primary;

      expect(AppTheme.darkTheme.colorScheme.primary, equals(expectedPrimary));
    });
  });
}
