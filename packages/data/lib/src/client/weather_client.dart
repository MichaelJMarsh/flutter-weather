import 'dart:convert';

import 'package:clock/clock.dart';
import 'package:flutter/foundation.dart';

import 'package:domain/domain.dart';
import 'package:http/http.dart' as http;

/// A client for fetching weather data from OpenWeather's Free APIs.
class WeatherClient implements WeatherService {
  /// Creates a new [WeatherClient].
  WeatherClient({required String? apiKey, http.Client? client})
    : _apiKey = apiKey,
      _client = client ?? http.Client();

  /// The key used to authenticate with the OpenWeather API.
  final String? _apiKey;

  /// The HTTP client used to make requests.
  final http.Client _client;

  /// The base URL path for the OpenWeather API.
  static const _baseUrl = 'https://api.openweathermap.org/data/2.5';

  @override
  Future<CurrentWeather> getCurrentWeather({
    required Coordinates coordinates,
  }) async {
    if (_apiKey == null || _apiKey.isEmpty) throw MissingApiKeyException();

    final uri = _getCoordinatesURI(
      path: '$_baseUrl/weather',
      coordinates: coordinates,
    );

    final response = await _client.get(uri);

    if (response.statusCode == _HttpStatusCode.unauthorized.code) {
      throw InvalidApiKeyException();
    }

    if (response.statusCode != _HttpStatusCode.successful.code) {
      throw Exception(
        'Failed to load current weather. Status code: ${response.statusCode}\nResponse: ${response.body}',
      );
    }

    final jsonBody = json.decode(response.body) as Map<String, dynamic>;
    final currentWeather = CurrentWeather.fromJson(jsonBody);

    return currentWeather.copyWith(dateTime: currentWeather.dateTime);
  }

  @override
  Future<List<HourlyForecast>> getHourlyForecast({
    required Coordinates coordinates,
  }) async {
    if (_apiKey == null || _apiKey.isEmpty) throw MissingApiKeyException();

    final uri = _getCoordinatesURI(
      path: '$_baseUrl/forecast',
      coordinates: coordinates,
    );

    final response = await _client.get(uri);

    if (response.statusCode == _HttpStatusCode.unauthorized.code) {
      throw InvalidApiKeyException();
    }

    if (response.statusCode != _HttpStatusCode.successful.code) {
      throw Exception(
        'Failed to load hourly forecast. Status code: ${response.statusCode}\nResponse: ${response.body}',
      );
    }

    final jsonBody = json.decode(response.body) as Map<String, dynamic>;
    final List<dynamic> forecastList = jsonBody['list'] ?? [];

    return forecastList
        .map((data) => HourlyForecast.fromJson(data as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<DailyForecast>> getDailyForecast({
    required Coordinates coordinates,
  }) async {
    if (_apiKey == null || _apiKey.isEmpty) throw MissingApiKeyException();

    final uri = _getCoordinatesURI(
      path: '$_baseUrl/forecast',
      coordinates: coordinates,
    );
    final response = await _client.get(uri);

    if (response.statusCode == _HttpStatusCode.unauthorized.code) {
      throw InvalidApiKeyException();
    }
    if (response.statusCode != _HttpStatusCode.successful.code) {
      throw Exception(
        'Failed to load daily forecast. '
        'Status code: ${response.statusCode}\nResponse: ${response.body}',
      );
    }

    final jsonBody = json.decode(response.body) as Map<String, dynamic>;
    final List<dynamic> forecastList = jsonBody['list'] ?? [];

    final groupedByDay = <int, List<HourlyForecast>>{};

    // Get today's UTC date (to skip current day's forecasts)
    final nowUtc = clock.now().toUtc();
    final todayUtc = DateTime.utc(nowUtc.year, nowUtc.month, nowUtc.day);

    for (final data in forecastList) {
      final hourlyData = HourlyForecast.fromJson(data as Map<String, dynamic>);

      // Convert dt (provided in seconds) into UTC DateTime.
      final utcDateTime = DateTime.fromMillisecondsSinceEpoch(
        hourlyData.timestamp * 1000,
        isUtc: true,
      );

      // If the forecast falls in the first hour (e.g. 00:xx), adjust it to the previous day.
      final adjustedUtcDateTime =
          utcDateTime.hour < 1
              ? utcDateTime.subtract(const Duration(hours: 1))
              : utcDateTime;

      final forecastDate = DateTime.utc(
        adjustedUtcDateTime.year,
        adjustedUtcDateTime.month,
        adjustedUtcDateTime.day,
      );

      // Skip if the forecast is for today.
      if (forecastDate.isAtSameMomentAs(todayUtc)) continue;

      final dayKey = forecastDate.millisecondsSinceEpoch;
      groupedByDay.putIfAbsent(dayKey, () => []).add(hourlyData);
    }

    // Convert each group into a DailyForecast.
    final dailyForecasts =
        groupedByDay.values.map((forecasts) {
          // Sort forecasts chronologically.
          forecasts.sort((a, b) => a.dateTime.compareTo(b.dateTime));
          final firstEntry = forecasts.first;

          final minTemp = forecasts
              .map((f) => f.temperature)
              .reduce((a, b) => a < b ? a : b);
          final maxTemp = forecasts
              .map((f) => f.temperature)
              .reduce((a, b) => a > b ? a : b);

          return DailyForecast(
            timestamp: firstEntry.timestamp,
            dateTime: DateTime.fromMillisecondsSinceEpoch(
              firstEntry.timestamp * 1000,
              isUtc: true,
            ),
            minTemperature: minTemp,
            maxTemperature: maxTemp,
            iconCode: firstEntry.iconCode ?? '01d',
          );
        }).toList();

    // Sort the final list by date.
    dailyForecasts.sort((a, b) => a.dateTime.compareTo(b.dateTime));

    return dailyForecasts;
  }

  /// Returns the Uri for the [path] with the given [coordinates].
  Uri _getCoordinatesURI({
    required String path,
    required Coordinates coordinates,
    String units = 'metric',
  }) {
    return Uri.parse(path).replace(
      queryParameters: {
        _QueryParameter.latitude: coordinates.latitude.toString(),
        _QueryParameter.longitude: coordinates.longitude.toString(),
        _QueryParameter.appId: _apiKey,
        _QueryParameter.units: units,
      },
    );
  }
}

/// An exception thrown when an invalid API key is detected.
@visibleForTesting
class InvalidApiKeyException implements Exception {
  /// Creates a new [InvalidApiKeyException].
  InvalidApiKeyException()
    : message =
          'Invalid API Key. Get a free one at https://openweathermap.org/api.';

  final String message;
}

/// An exception thrown when an API key is missing or invalid.
@visibleForTesting
class MissingApiKeyException implements Exception {
  /// Creates a new [MissingApiKeyException].
  MissingApiKeyException() : message = 'API key is missing or invalid.';

  final String message;
}

/// Contains the query parameters used in the OpenWeather API.
@immutable
abstract class _QueryParameter {
  const _QueryParameter._();

  /// The latitude of the location.
  static const latitude = 'lat';

  /// The longitude of the location.
  static const longitude = 'lon';

  /// The app ID for the OpenWeather API.
  static const appId = 'appid';

  /// The units of measurement for the weather data.
  static const units = 'units';
}

/// The status code for a http response.
enum _HttpStatusCode {
  /// The status code for a successful request.
  successful(code: 200),

  /// The status code for an unauthorized request.
  unauthorized(code: 401);

  const _HttpStatusCode({required this.code});

  /// The status code for the current http response.
  final int code;
}
