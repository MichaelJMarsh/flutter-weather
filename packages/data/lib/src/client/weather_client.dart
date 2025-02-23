import 'dart:convert';

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
      throw Exception(
        'Invalid API Key. Get a free one at https://openweathermap.org/api.',
      );
    }

    if (response.statusCode != _HttpStatusCode.successful.code) {
      throw Exception(
        'Failed to load current weather. Status code: ${response.statusCode}\nResponse: ${response.body}',
      );
    }

    final jsonBody = json.decode(response.body) as Map<String, dynamic>;
    return CurrentWeather.fromJson(jsonBody);
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
        'Failed to load daily forecast. Status code: ${response.statusCode}\nResponse: ${response.body}',
      );
    }

    final jsonBody = json.decode(response.body) as Map<String, dynamic>;
    final List<dynamic> forecastList = jsonBody['list'] ?? [];

    // Extract daily summaries from 3-hour forecast data.
    final groupedByDay = <int, List<HourlyForecast>>{};

    for (final data in forecastList) {
      final hourlyData = HourlyForecast.fromJson(data as Map<String, dynamic>);
      final dayKey =
          DateTime(
            hourlyData.dateTime.year,
            hourlyData.dateTime.month,
            hourlyData.dateTime.day,
          ).millisecondsSinceEpoch;

      groupedByDay.putIfAbsent(dayKey, () => []).add(hourlyData);
    }

    return groupedByDay.values.map((forecasts) {
      final firstEntry = forecasts.first;
      final hourlyTempertures = forecasts.map(
        (hourlyForecast) => hourlyForecast.temperature,
      );

      final minTemp = hourlyTempertures.reduce((a, b) => a < b ? a : b);
      final maxTemp = hourlyTempertures.reduce((a, b) => a > b ? a : b);

      return DailyForecast(
        timestamp: firstEntry.timestamp,
        dateTime: firstEntry.dateTime,
        minTemperature: minTemp,
        maxTemperature: maxTemp,
        iconCode: firstEntry.iconCode ?? '01d',
      );
    }).toList();
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
