import 'package:flutter/foundation.dart';

/// Represents a daily weather forecast.
@immutable
class DailyForecast {
  /// Creates a new [DailyForecast].
  const DailyForecast({
    required this.timestamp,
    required this.dateTime,
    required this.minTemperature,
    required this.maxTemperature,
    required this.iconCode,
  });

  /// The raw Unix timestamp (seconds since epoch, UTC).
  final int timestamp;

  /// The date and time of the forecast.
  final DateTime dateTime;

  /// The minimum temperature for the day (in Celsius).
  final double minTemperature;

  /// The maximum temperature for the day (in Celsius).
  final double maxTemperature;

  /// The icon code representing the weather condition.
  final String iconCode;

  /// Creates an instance from JSON data.
  factory DailyForecast.fromJson(Map<String, dynamic> json) {
    final int timestamp = json[DailyForecastField.timestamp] as int? ?? 0;
    final weather =
        (json[DailyForecastField.weather] as List<dynamic>?)?.firstOrNull
            as Map<String, dynamic>?;

    // Extract temperature correctly from `main`
    final mainData =
        json[DailyForecastField.main] as Map<String, dynamic>? ?? {};

    return DailyForecast(
      timestamp: timestamp,
      dateTime: DateTime.fromMillisecondsSinceEpoch(
        timestamp * 1000,
        isUtc: true,
      ),
      minTemperature:
          (mainData[DailyForecastField.min] as num?)?.toDouble() ?? 0.0,
      maxTemperature:
          (mainData[DailyForecastField.max] as num?)?.toDouble() ?? 0.0,
      iconCode: weather?[DailyForecastField.icon] ?? '01d',
    );
  }

  @override
  String toString() {
    return '''DailyForecast(
    timestamp: $timestamp, 
    dateTime: $dateTime, 
    minTemperature: $minTemperature, 
    maxTemperature: $maxTemperature, 
    icon: $iconCode
    )''';
  }
}

/// Contains the field names of the OpenWeather API response for daily forecasts.
@immutable
abstract class DailyForecastField {
  const DailyForecastField._();

  /// Unix timestamp of the forecast.
  static const timestamp = 'dt';

  /// List of weather conditions.
  static const weather = 'weather';

  /// Main weather data block.
  static const main = 'main';

  /// Minimum temperature.
  static const min = 'temp_min';

  /// Maximum temperature.
  static const max = 'temp_max';

  /// Icon representation of the weather condition.
  static const icon = 'icon';
}
