import 'package:flutter/widgets.dart';

import 'package:domain/domain.dart';
import 'package:provider/provider.dart';

/// The provider-scoped state management class which handles the fetching
/// of the weather data for the [DashboardPage].
class DashboardPageScope extends ChangeNotifier {
  /// Creates a new [DashboardPageScope].
  DashboardPageScope({required WeatherService weatherService})
    : _weatherService = weatherService;

  /// Creates a new [DashboardPageScope] from the [context].
  factory DashboardPageScope.of(final BuildContext context) {
    return DashboardPageScope(weatherService: context.read());
  }

  final WeatherService _weatherService;

  /// Whether the [DashboardPageScope] is currently loading.
  bool get isLoading => _isLoading;
  bool _isLoading = true;

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
    await Future.wait([
      _loadCurrentWeather(),
      _loadHourlyForecast(),
      _loadDailyForecast(),
    ]);

    _isLoading = false;
    notifyListeners();
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
