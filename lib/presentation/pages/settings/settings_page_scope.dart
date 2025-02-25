import 'package:flutter/material.dart' hide ThemeMode;

import 'package:domain/domain.dart';
import 'package:provider/provider.dart';

/// The provider-scoped state management class which handles the management
/// of the app settings on the [SettingsPage].
class SettingsPageScope extends ChangeNotifier {
  /// Creates a new [SettingsPageScope].
  SettingsPageScope({
    required AuthenticationService authenticationService,
    required RemoteSettingsService remoteSettingsService,
  }) : _authenticationService = authenticationService,
       _remoteSettingsService = remoteSettingsService;

  final AuthenticationService _authenticationService;
  final RemoteSettingsService _remoteSettingsService;

  /// Creates a new [SettingsPageScope] from the [context].
  factory SettingsPageScope.of(final BuildContext context) {
    return SettingsPageScope(
      authenticationService: context.read(),
      remoteSettingsService: context.read(),
    );
  }

  /// The user ID for the current user.
  String get _userId => _authenticationService.userId;

  /// Whether the [SettingsPageScope] is currently loading.
  bool get isLoading => _isLoading;
  bool _isLoading = true;

  /// The selected temperature unit for the app.
  TemperatureUnit get temperatureUnit => _temperatureUnit;
  TemperatureUnit _temperatureUnit = TemperatureUnit.celsius;

  /// The selected theme mode for the app.
  ThemeMode get themeMode => _themeMode;
  ThemeMode _themeMode = ThemeMode.light;

  /// The selected time format for the app.
  TimeFormat get timeFormat => _timeFormat;
  TimeFormat _timeFormat = TimeFormat.twentyFourHour;

  /// Initializes the settings by fetching the current settings from Firebase.
  Future<void> initialize() async {
    final settings = await _remoteSettingsService.fetchSettings(_userId);
    _themeMode = settings.themeMode;
    _timeFormat = settings.timeFormat;
    _temperatureUnit = settings.temperatureUnit;

    _isLoading = false;
    notifyListeners();
  }

  /// Sets the temperature unit for the app.
  Future<void> setTemperatureUnit(TemperatureUnit value) async {
    if (temperatureUnit == value) return;

    _temperatureUnit = value;

    await _remoteSettingsService.saveSettings(
      _userId,
      UserSettings(
        themeMode: _themeMode,
        timeFormat: _timeFormat,
        temperatureUnit: _temperatureUnit,
      ),
    );

    notifyListeners();
  }

  /// Sets the time format for the app.
  Future<void> setTimeFormat(TimeFormat value) async {
    if (timeFormat == value) return;

    _timeFormat = value;

    await _remoteSettingsService.saveSettings(
      _userId,
      UserSettings(
        themeMode: _themeMode,
        timeFormat: _timeFormat,
        temperatureUnit: _temperatureUnit,
      ),
    );

    notifyListeners();
  }

  /// Toggles the theme mode for the app, based on whether the light mode
  /// is enabled.
  Future<void> toggleThemeMode(bool enabled) async {
    if (enabled == (_themeMode == ThemeMode.dark)) return;

    _themeMode = enabled ? ThemeMode.dark : ThemeMode.light;

    await _remoteSettingsService.saveSettings(
      _userId,
      UserSettings(
        themeMode: _themeMode,
        timeFormat: _timeFormat,
        temperatureUnit: _temperatureUnit,
      ),
    );

    notifyListeners();
  }
}
