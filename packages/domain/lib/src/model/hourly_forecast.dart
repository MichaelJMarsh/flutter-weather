import 'package:flutter/foundation.dart';

/// Represents an hourly forecast record.
@immutable
class HourlyForecast {
  /// Creates a new [HourlyForecast].
  const HourlyForecast({
    required this.timestamp,
    required this.dateTime,
    required this.temperature,
    required this.iconCode,
  });

  /// The raw Unix timestamp (seconds since epoch, UTC).
  final int timestamp;

  /// The date and time of the forecast.
  final DateTime dateTime;

  /// The temperature in Celsius.
  final double temperature;

  /// The icon code provided by OpenWeather.
  final String? iconCode;

  /// Creates an instance from JSON data.
  factory HourlyForecast.fromJson(Map<String, dynamic> json) {
    final int timestamp = json[HourlyForecastField.timestamp] as int? ?? 0;
    final weather =
        (json[HourlyForecastField.weather] as List<dynamic>?)?.firstOrNull
            as Map<String, dynamic>?;

    // Extracting temperature correctly from `main['temp']`
    final mainData =
        json[HourlyForecastField.main] as Map<String, dynamic>? ?? {};

    return HourlyForecast(
      timestamp: timestamp,
      dateTime: DateTime.fromMillisecondsSinceEpoch(
        timestamp * 1000,
        isUtc: true,
      ),
      temperature:
          (mainData[HourlyForecastField.temperature] as num?)?.toDouble() ??
          0.0,
      iconCode: weather?[HourlyForecastField.icon] ?? '01d',
    );
  }

  @override
  String toString() {
    return '''HourlyForecast(
    timestamp: $timestamp, 
    dateTime: $dateTime, 
    temperature: $temperature, 
    icon: $iconCode
    )''';
  }
}

/// Contains the field names of the OpenWeather API response for hourly forecasts.
@immutable
abstract class HourlyForecastField {
  const HourlyForecastField._();

  /// Unix timestamp of the forecast.
  static const timestamp = 'dt';

  /// List of weather conditions.
  static const weather = 'weather';

  /// Temperature key in the API response.
  static const temperature = 'temp';

  /// Main weather data block.
  static const main = 'main';

  /// Icon representation of the weather condition.
  static const icon = 'icon';
}
