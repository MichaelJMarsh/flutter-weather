import 'package:flutter/foundation.dart';

import 'package:collection/collection.dart';

import 'current_weather.dart';
import 'daily_forecast.dart';
import 'hourly_forecast.dart';

/// Represents the full weather forecast data retrieved from the OpenWeather One Call API.
@immutable
class WeatherForecast {
  /// Creates a new [WeatherForecast] instance.
  const WeatherForecast({
    required this.latitude,
    required this.longitude,
    required this.timezone,
    required this.current,
    required this.hourly,
    required this.daily,
  });

  /// The latitude of the requested location.
  final double latitude;

  /// The longitude of the requested location.
  final double longitude;

  /// The timezone of the requested location.
  final String timezone;

  /// The current weather conditions.
  final CurrentWeather current;

  /// Hourly forecast data for the next 48 hours.
  final List<HourlyForecast> hourly;

  /// Daily forecast data for the next 7-8 days.
  final List<DailyForecast> daily;

  /// Creates an instance from JSON data.
  factory WeatherForecast.fromJson(Map<String, dynamic> json) {
    return WeatherForecast(
      latitude: (json[WeatherForecastField.latitude] as num).toDouble(),
      longitude: (json[WeatherForecastField.longitude] as num).toDouble(),
      timezone: json[WeatherForecastField.timezone] as String? ?? 'Unknown',
      current: CurrentWeather.fromJson(json[WeatherForecastField.current]),
      hourly: _parseHourly(json),
      daily: _parseDaily(json),
    );
  }

  /// Parses the hourly forecast list.
  static List<HourlyForecast> _parseHourly(Map<String, dynamic> json) {
    return (json[WeatherForecastField.hourly] as List<dynamic>?)
            ?.map((e) => HourlyForecast.fromJson(e as Map<String, dynamic>))
            .toList() ??
        <HourlyForecast>[];
  }

  /// Parses the daily forecast list.
  static List<DailyForecast> _parseDaily(Map<String, dynamic> json) {
    return (json[WeatherForecastField.daily] as List<dynamic>?)
            ?.map((e) => DailyForecast.fromJson(e as Map<String, dynamic>))
            .toList() ??
        <DailyForecast>[];
  }

  @override
  String toString() {
    return '''WeatherForecast(
    latitude: $latitude, 
    longitude: $longitude, 
    timezone: $timezone, 
    current: $current, 
    hourly: $hourly, 
    daily: $daily,
    )''';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is WeatherForecast &&
        other.runtimeType == runtimeType &&
        other.latitude == latitude &&
        other.longitude == longitude &&
        other.timezone == timezone &&
        other.current == current &&
        const ListEquality().equals(other.hourly, hourly) &&
        const ListEquality().equals(other.daily, daily);
  }

  @override
  int get hashCode =>
      runtimeType.hashCode ^
      latitude.hashCode ^
      longitude.hashCode ^
      timezone.hashCode ^
      current.hashCode ^
      const ListEquality().hash(hourly) ^
      const ListEquality().hash(daily);
}

/// Contains the field names of the OpenWeather API response for the full weather forecast.
@immutable
abstract class WeatherForecastField {
  const WeatherForecastField._();

  /// Latitude of the location.
  static const latitude = 'lat';

  /// Longitude of the location.
  static const longitude = 'lon';

  /// Timezone name for the requested location.
  static const timezone = 'timezone';

  /// Current weather conditions.
  static const current = 'current';

  /// Hourly forecast.
  static const hourly = 'hourly';

  /// Daily forecast.
  static const daily = 'daily';
}
