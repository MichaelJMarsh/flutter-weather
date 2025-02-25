import 'package:flutter/material.dart' hide ThemeMode;

import 'package:domain/domain.dart';

/// Defines the Flutter Weather app themes.
class AppTheme {
  const AppTheme._();

  static const primaryColor = Colors.cyan;

  /// Light theme configuration.
  static final lightTheme = ThemeData(
    brightness: Brightness.light,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primaryColor,
      brightness: Brightness.light,
    ),
    useMaterial3: true,
  );

  /// Dark theme configuration.
  static final darkTheme = ThemeData(
    brightness: Brightness.dark,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primaryColor,
      brightness: Brightness.dark,
    ),
    useMaterial3: true,
  );

  /// Determines the correct theme based on user settings and system brightness.
  static ThemeData getTheme({
    required ThemeMode mode,
    required Brightness brightness,
  }) {
    return switch (mode) {
      ThemeMode.light => lightTheme,
      ThemeMode.dark => darkTheme,
      ThemeMode.system =>
        brightness == Brightness.dark ? darkTheme : lightTheme,
    };
  }
}
