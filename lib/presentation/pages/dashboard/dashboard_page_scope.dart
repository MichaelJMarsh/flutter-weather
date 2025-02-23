import 'package:flutter/widgets.dart';

import 'package:domain/domain.dart';
import 'package:provider/provider.dart';

/// Dashboard scope responsible for fetching and storing weather data.
class DashboardPageScope extends ChangeNotifier {
  DashboardPageScope({required WeatherService weatherService})
    : _weatherService = weatherService;

  /// Retrieves an instance from the widget tree.
  factory DashboardPageScope.of(final BuildContext context) {
    return DashboardPageScope(weatherService: context.read<WeatherService>());
  }

  final WeatherService _weatherService;

  bool _isLoading = true;
  bool get isLoading => _isLoading;

  CurrentWeather? _currentWeather;
  CurrentWeather? get currentWeather => _currentWeather;

  List<HourlyForecast> _hourlyForecast = [];
  List<HourlyForecast> get hourlyForecast => _hourlyForecast;

  List<DailyForecast> _dailyForecast = [];
  List<DailyForecast> get dailyForecast => _dailyForecast;

  /// Initializes the dashboard by loading weather data.
  Future<void> initialize() async {
    await loadWeatherData();
    _isLoading = false;
    notifyListeners();
  }

  /// Loads current weather, hourly forecast, and daily forecast.
  Future<void> loadWeatherData() async {
    try {
      _isLoading = true;
      notifyListeners();

      // Example coordinates (Austin, TX)
      const double lat = 30.2672;
      const double lon = -97.7431;

      // Fetch current weather
      final current = await _weatherService.getCurrentWeather(
        lat: lat,
        lon: lon,
      );
      _currentWeather = current;

      // Fetch hourly forecast
      final hourly = await _weatherService.getHourlyForecast(
        lat: lat,
        lon: lon,
      );
      _hourlyForecast = hourly;

      // Fetch daily forecast
      final daily = await _weatherService.getDailyForecast(lat: lat, lon: lon);
      _dailyForecast = daily;
    } catch (e) {
      // ToDo: Handle error appropriately (logging, error state, etc.)

      _currentWeather = null;
      _hourlyForecast = [];
      _dailyForecast = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
