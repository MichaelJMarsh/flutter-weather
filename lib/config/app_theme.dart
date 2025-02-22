import 'package:flutter/material.dart';

/// Defines the Flutter Weather app themes.
class AppTheme {
  const AppTheme._();

  static const primaryColor = Colors.indigo;

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
  static ThemeData getTheme({required Brightness platformBrightness}) {
    return platformBrightness == Brightness.light ? lightTheme : darkTheme;
  }
}
