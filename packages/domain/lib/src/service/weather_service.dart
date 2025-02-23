import 'package:domain/src/model/current_weather.dart';
import 'package:domain/src/model/hourly_forecast.dart';
import 'package:domain/src/model/daily_forecast.dart';

/// The interface for accessing weather data.
abstract class WeatherService {
  const WeatherService._();

  /// Returns the current weather data from OpenWeather's free API.
  Future<CurrentWeather> getCurrentWeather({
    required double lat,
    required double lon,
  });

  /// Returns the 5-day/3-hour forecast from OpenWeather's free API.
  Future<List<HourlyForecast>> getHourlyForecast({
    required double lat,
    required double lon,
  });

  /// Returns the 7-day daily forecast from OpenWeather's free API.
  Future<List<DailyForecast>> getDailyForecast({
    required double lat,
    required double lon,
  });
}
