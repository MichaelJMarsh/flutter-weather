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

    final tempData =
        json[DailyForecastField.temp] as Map<String, dynamic>? ?? {};

    // Ensure `weather` list exists and is not empty.
    final weatherList =
        json[DailyForecastField.weather] as List<dynamic>? ?? [];
    final weatherMap =
        (weatherList.isNotEmpty)
            ? weatherList.first as Map<String, dynamic>?
            : null;

    return DailyForecast(
      timestamp: timestamp,
      dateTime: DateTime.fromMillisecondsSinceEpoch(
        timestamp * 1000,
        isUtc: true,
      ),
      minTemperature: (tempData['min'] as num?)?.toDouble() ?? 0.0,
      maxTemperature: (tempData['max'] as num?)?.toDouble() ?? 0.0,
      iconCode: weatherMap?[DailyForecastField.icon] ?? '01d',
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is DailyForecast &&
        other.runtimeType == runtimeType &&
        other.timestamp == timestamp &&
        other.dateTime == dateTime &&
        other.minTemperature == minTemperature &&
        other.maxTemperature == maxTemperature &&
        other.iconCode == iconCode;
  }

  @override
  int get hashCode {
    return runtimeType.hashCode ^
        timestamp.hashCode ^
        dateTime.hashCode ^
        minTemperature.hashCode ^
        maxTemperature.hashCode ^
        iconCode.hashCode;
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

  /// Temperature key in the API response.
  static const temp = 'temp';

  /// Minimum temperature.
  static const min = 'temp_min';

  /// Maximum temperature.
  static const max = 'temp_max';

  /// Icon representation of the weather condition.
  static const icon = 'icon';
}
