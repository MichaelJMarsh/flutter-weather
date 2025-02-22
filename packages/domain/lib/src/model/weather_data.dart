import 'package:flutter/foundation.dart';

/// A model class that represents weather data.
@immutable
class WeatherData {
  /// Creates a new [WeatherData].
  const WeatherData({
    required this.temperature,
    required this.humidity,
    required this.description,
    required this.icon,
  });

  /// Temperature in Celsius.
  final double temperature;

  /// Humidity in percentage.
  final int humidity;

  /// Weather description (e.g., "light rain").
  final String description;

  /// The icon code provided by OpenWeather (e.g., "10d").
  final String icon;

  /// Creates a new [WeatherData] from a JSON object.
  factory WeatherData.fromJson(Map<String, dynamic> json) {
    final main = json[WeatherDataField.main] as Map<String, dynamic>;
    final weatherList = json[WeatherDataField.weather] as List<dynamic>;
    final weather =
        weatherList.isNotEmpty ? weatherList.first as Map<String, dynamic> : {};

    return WeatherData(
      temperature:
          (main[WeatherDataField.temperature] as num)
              .toDouble(), // ✅ Fixed field mapping
      humidity: main[WeatherDataField.humidity] as int, // ✅ Fixed field mapping
      description:
          weather[WeatherDataField.description] as String? ??
          '', // ✅ Fixed field mapping
      icon:
          weather[WeatherDataField.icon] as String? ??
          '', // ✅ Fixed field mapping
    );
  }

  /// Converts this [WeatherData] to a JSON object.
  Map<String, dynamic> toJson() {
    return {
      WeatherDataField.temperature: temperature,
      WeatherDataField.humidity: humidity,
      WeatherDataField.description: description,
      WeatherDataField.icon: icon,
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is WeatherData &&
        other.runtimeType == runtimeType &&
        other.temperature == temperature &&
        other.humidity == humidity &&
        other.description == description &&
        other.icon == icon;
  }

  @override
  int get hashCode {
    return runtimeType.hashCode ^
        temperature.hashCode ^
        humidity.hashCode ^
        description.hashCode ^
        icon.hashCode;
  }
}

/// Contains the field names of the [WeatherDataField] table.
@immutable
abstract class WeatherDataField {
  const WeatherDataField._();

  static const main = 'main';
  static const weather = 'weather';

  static const temperature = 'temp';
  static const humidity = 'humidity';
  static const description = 'description';
  static const icon = 'icon';
}
