import 'package:flutter/foundation.dart';

/// Represents the current weather conditions.
@immutable
class CurrentWeather {
  /// Creates a new [CurrentWeather] instance.
  const CurrentWeather({
    required this.timestamp,
    required this.dateTime,
    required this.temperature,
    required this.feelsLikeTemperature,
    required this.description,
    required this.iconCode,
    required this.humidity,
  });

  /// The raw Unix timestamp (seconds since epoch, UTC).
  final int timestamp;

  /// The date and time of the weather reading.
  final DateTime dateTime;

  /// The actual temperature in Celsius.
  final double temperature;

  /// The temperature perceived by humans (feels-like temperature) in Celsius.
  final double feelsLikeTemperature;

  /// A brief textual description of the weather conditions.
  final String description;

  /// The icon code representing the weather condition.
  final String iconCode;

  /// The humidity percentage.
  final double humidity;

  /// Creates an instance from JSON data.
  factory CurrentWeather.fromJson(Map<String, dynamic> json) {
    final weather =
        (json[CurrentWeatherField.weather] as List<dynamic>?)?.firstOrNull
            as Map<String, dynamic>?;

    final mainData =
        json[CurrentWeatherField.main] as Map<String, dynamic>? ?? {};

    return CurrentWeather(
      timestamp: json[CurrentWeatherField.timestamp] as int? ?? 0,
      dateTime: DateTime.fromMillisecondsSinceEpoch(
        (json[CurrentWeatherField.timestamp] as int? ?? 0) * 1000,
        isUtc: true,
      ),
      temperature:
          (mainData[CurrentWeatherField.temperature] as num?)?.toDouble() ??
          0.0,
      feelsLikeTemperature:
          (mainData[CurrentWeatherField.feelsLike] as num?)?.toDouble() ?? 0.0,
      description: weather?[CurrentWeatherField.description] ?? 'N/A',
      iconCode: weather?[CurrentWeatherField.icon] ?? '01d',
      humidity:
          (mainData[CurrentWeatherField.humidity] as num?)?.toDouble() ?? 0.0,
    );
  }

  @override
  String toString() {
    return '''CurrentWeather(
    timestamp: $timestamp, 
    dateTime: $dateTime, 
    temperature: $temperature, 
    feelsLikeTemperature: $feelsLikeTemperature, 
    description: $description, 
    icon: $iconCode, 
    humidity: $humidity
    )''';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is CurrentWeather &&
        other.runtimeType == runtimeType &&
        other.timestamp == timestamp &&
        other.dateTime == dateTime &&
        other.temperature == temperature &&
        other.feelsLikeTemperature == feelsLikeTemperature &&
        other.description == description &&
        other.iconCode == iconCode &&
        other.humidity == humidity;
  }

  @override
  int get hashCode =>
      runtimeType.hashCode ^
      timestamp.hashCode ^
      dateTime.hashCode ^
      temperature.hashCode ^
      feelsLikeTemperature.hashCode ^
      description.hashCode ^
      iconCode.hashCode ^
      humidity.hashCode;
}

/// Contains the field names of the OpenWeather API response for current weather.
@immutable
abstract class CurrentWeatherField {
  const CurrentWeatherField._();

  /// Main weather data.
  static const main = 'main';

  /// Unix timestamp of the weather observation.
  static const timestamp = 'dt';

  /// List of weather conditions.
  static const weather = 'weather';

  /// Textual description of the weather.
  static const description = 'description';

  /// Icon representation of the weather condition.
  static const icon = 'icon';

  /// Temperature-related fields.
  static const temperature = 'temp';

  /// Feels-like temperature.
  static const feelsLike = 'feels_like';

  /// Humidity percentage.
  static const humidity = 'humidity';
}
