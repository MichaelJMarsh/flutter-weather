import 'package:domain/src/model/weather_data.dart';

/// The interface for accessing weather data.
abstract class WeatherService {
  const WeatherService._();

  /// Returns a list of weather data for the given [startDate] and [endDate].
  ///
  /// In this simple example, the date range may not actually affect the
  /// OpenWeather endpoint call, but you can adapt it for forecast/historical
  /// endpoints that use date ranges.
  Future<List<WeatherData>> getWeather({
    required DateTime startDate,
    required DateTime endDate,
  });
}
