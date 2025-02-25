import 'package:flutter/material.dart';

/// The format for the time display.
enum TimeFormat {
  twelveHour(displayText: '12-hour'),
  twentyFourHour(displayText: '24-hour');

  const TimeFormat({required this.displayText});

  /// The display text for the [TimeFormat].
  final String displayText;

  /// The list of display text for each [TimeFormat].
  static List<String> get displayTexts {
    return values.map((timeFormat) => timeFormat.displayText).toList();
  }
}

/// The unit for the temperature display.
enum TemperatureUnit {
  celsius(displayText: 'Celcius (C°)'),
  fahrenheit(displayText: 'Farhenheit (F°)');

  const TemperatureUnit({required this.displayText});

  /// The display text for the [TemperatureUnit].
  final String displayText;

  /// The list of display text for each [TemperatureUnit].
  static List<String> get displayTexts {
    return values
        .map((temperatureUnit) => temperatureUnit.displayText)
        .toList();
  }
}

/// The provider-scoped state management class which handles the management
/// of the app settings on the [SettingsPage].
class SettingsPageScope extends ChangeNotifier {
  /// Creates a new [SettingsPageScope].
  SettingsPageScope();

  /// Creates a new [SettingsPageScope] from the [context].
  factory SettingsPageScope.of(final BuildContext context) {
    return SettingsPageScope();
  }

  /// Whether the [SettingsPageScope] is currently loading.
  bool get isLoading => _isLoading;
  bool _isLoading = true;

  /// The selected theme mode for the app.
  ThemeMode get themeMode => _themeMode;
  ThemeMode _themeMode = ThemeMode.light;

  /// The selected time format for the app.
  TimeFormat get timeFormat => _timeFormat;
  TimeFormat _timeFormat = TimeFormat.twentyFourHour;

  set timeFormat(TimeFormat value) {
    if (timeFormat == value) return;

    _timeFormat = value;

    notifyListeners();
  }

  /// The selected temperature unit for the app.
  TemperatureUnit get temperatureUnit => _temperatureUnit;
  TemperatureUnit _temperatureUnit = TemperatureUnit.celsius;

  set temperatureUnit(TemperatureUnit value) {
    if (temperatureUnit == value) return;

    _temperatureUnit = value;

    notifyListeners();
  }

  /// Initializes the settings by fetching the current settings from Firebase.
  Future<void> initialize() async {
    _isLoading = false;
    notifyListeners();
  }

  /// Toggles the theme mode for the app, based on whether the light mode
  /// is enabled.
  Future<void> toggleThemeMode(bool enabled) async {
    _themeMode = enabled ? ThemeMode.dark : ThemeMode.light;

    notifyListeners();
  }
}
