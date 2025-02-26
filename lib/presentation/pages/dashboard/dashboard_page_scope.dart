import 'dart:async';

import 'package:flutter/widgets.dart';

import 'package:domain/domain.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

/// The provider-scoped state management class which handles the fetching
/// of the weather data for the [DashboardPage].
class DashboardPageScope extends ChangeNotifier {
  /// Creates a new [DashboardPageScope].
  DashboardPageScope({
    required RemoteSettingsService remoteSettingsService,
    required WeatherService weatherService,
  })  : _remoteSettingsService = remoteSettingsService,
        _weatherService = weatherService;

  /// Creates a new [DashboardPageScope] from the [context].
  factory DashboardPageScope.of(final BuildContext context) {
    return DashboardPageScope(
      remoteSettingsService: context.read(),
      weatherService: context.read(),
    );
  }

  final RemoteSettingsService _remoteSettingsService;
  final WeatherService _weatherService;

  /// The subscription to the user settings stream.
  late final StreamSubscription<UserSettings> _userSettingsSubscription;

  /// Whether the [DashboardPageScope] is currently loading.
  bool get isLoading => _isLoading;
  bool _isLoading = true;

  /// The current temperature unit.
  TemperatureUnit get temperatureUnit => _temperatureUnit;
  TemperatureUnit _temperatureUnit = TemperatureUnit.celsius;

  /// The current time format.
  TimeFormat get timeFormat => _timeFormat;
  TimeFormat _timeFormat = TimeFormat.twentyFourHour;

  /// The weather data for the current day.
  CurrentWeather? get currentWeather => _currentWeather;
  CurrentWeather? _currentWeather;

  /// The hourly forecast for the current day.
  List<HourlyForecast> get hourlyForecast => _hourlyForecast;
  List<HourlyForecast> _hourlyForecast = [];

  /// The daily forecast for the next 7 days.
  List<DailyForecast> get dailyForecast => _dailyForecast;
  List<DailyForecast> _dailyForecast = [];

  /// The current coordinates for the weather data.
  ///
  /// This is currently hardcoded to Austin, TX.
  static const _coordinates = Coordinates(
    latitude: 30.2672,
    longitude: -97.7431,
  );

  /// Initializes the dashboard by loading weather data.
  Future<void> initialize() async {
    final userSettings = _remoteSettingsService.userSettings;
    _temperatureUnit = userSettings.temperatureUnit;
    _timeFormat = userSettings.timeFormat;

    await Future.wait([
      _loadCurrentWeather(),
      _loadHourlyForecast(),
      _loadDailyForecast(),
    ]);

    _userSettingsSubscription =
        _remoteSettingsService.userSettingsStream.listen((userSettings) {
      final didUpdateTemperatureUnit =
          _temperatureUnit != userSettings.temperatureUnit;
      if (didUpdateTemperatureUnit) {
        _temperatureUnit = userSettings.temperatureUnit;
      }

      final didUpdateTimeFormat = _timeFormat != userSettings.timeFormat;
      if (didUpdateTimeFormat) {
        _timeFormat = userSettings.timeFormat;
      }

      // Only update state if the temperature unit or time format has changed.
      if (didUpdateTemperatureUnit || didUpdateTimeFormat) {
        notifyListeners();
      }
    });

    _isLoading = false;
    notifyListeners();
  }

  @override
  void dispose() {
    _userSettingsSubscription.cancel();

    super.dispose();
  }

  /// Formats the given [temperature] into a string.
  String formatTemperature(double? temperature, {bool displayUnit = true}) {
    if (temperature == null) return 'N/A';

    if (_temperatureUnit == TemperatureUnit.celsius) {
      return '${temperature.round()}°${displayUnit ? 'C' : ''}';
    }

    // Convert to Fahrenheit.
    return '${(temperature * 1.8 + 32).round()}°${displayUnit ? 'F' : ''}';
  }

  /// Formats the given [time] into a string.
  String formatTime(DateTime time) {
    if (_timeFormat == TimeFormat.twentyFourHour) {
      return DateFormat.H().format(time);
    }

    return DateFormat.j().format(time);
  }

  /// Loads the current weather.
  Future<void> _loadCurrentWeather() async {
    try {
      _currentWeather = await _weatherService.getCurrentWeather(
        coordinates: _coordinates,
      );
    } catch (e) {
      // ToDo: Log error to crashlytics.
      _currentWeather = null;
    }
  }

  /// Loads the hourly forecast.
  Future<void> _loadHourlyForecast() async {
    try {
      _hourlyForecast = await _weatherService.getHourlyForecast(
        coordinates: _coordinates,
      );
    } catch (e) {
      // ToDo: Log error to crashlytics.
      _hourlyForecast = [];
    }
  }

  /// Loads the daily forecast.
  Future<void> _loadDailyForecast() async {
    try {
      _dailyForecast = await _weatherService.getDailyForecast(
        coordinates: _coordinates,
      );
    } catch (e) {
      // ToDo: Log error to crashlytics.
      _dailyForecast = [];
    }
  }
}
