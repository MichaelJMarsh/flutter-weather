import 'dart:async';

import 'package:flutter/widgets.dart';

import 'package:domain/domain.dart';
import 'package:provider/provider.dart';

class DashboardPageScope extends ChangeNotifier {
  /// Creates a new [DashboardPageScope].
  DashboardPageScope({required WeatherService weatherService})
    : _weatherService = weatherService;

  /// Creates a new [DashboardPageScope] from the [context].
  factory DashboardPageScope.of(final BuildContext context) {
    return DashboardPageScope(weatherService: context.read<WeatherService>());
  }

  final WeatherService _weatherService;

  /// Whether the page is loading.
  bool get isLoading => _isLoading;
  bool _isLoading = true;

  /// The list of fetched [WeatherData].
  List<WeatherData> get weatherDataList => _weatherDataList;
  List<WeatherData> _weatherDataList = [];

  /// Initializes the dashboard by loading initial weather data.
  Future<void> initialize() async {
    await loadWeatherData();

    _isLoading = false;
    notifyListeners();
  }

  /// Loads weather data for the current date range.
  ///
  /// In a real scenario, you'd pass actual [startDate] & [endDate], but
  /// here's a simple method to demonstrate usage.
  Future<void> loadWeatherData({DateTime? startDate, DateTime? endDate}) async {
    try {
      _isLoading = true;
      notifyListeners();

      final now = DateTime.now();
      final start = startDate ?? now.subtract(const Duration(days: 7));
      final end = endDate ?? now;

      final weatherList = await _weatherService.getWeather(
        startDate: start,
        endDate: end,
      );
      _weatherDataList = weatherList;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
