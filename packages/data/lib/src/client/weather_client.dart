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
    final currentWeather = CurrentWeather.fromJson(jsonBody);

    return currentWeather.copyWith(dateTime: currentWeather.dateTime.toLocal());
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

    if (response.statusCode == 401) {
      throw InvalidApiKeyException();
    }
    if (response.statusCode != 200) {
      throw Exception(
        'Failed to load daily forecast. '
        'Status code: ${response.statusCode}\nResponse: ${response.body}',
      );
    }

    final jsonBody = json.decode(response.body) as Map<String, dynamic>;
    final List<dynamic> forecastList = jsonBody['list'] ?? [];

    // We'll group 3-hour forecasts by their *local* day.
    final groupedByDay = <int, List<HourlyForecast>>{};

    // Convert "today" to local time.
    final nowUtc = clock.now(); // This is UTC or system time
    final nowLocal = nowUtc.toLocal();
    final localToday = DateTime(nowLocal.year, nowLocal.month, nowLocal.day);
    final localTomorrow = localToday.add(const Duration(days: 1));

    for (final data in forecastList) {
      final hourlyData = HourlyForecast.fromJson(data as Map<String, dynamic>);

      // Convert forecast time to local.
      final localDateTime = hourlyData.dateTime.toLocal();
      // Group by "year/month/day" in local time.
      final forecastDate = DateTime(
        localDateTime.year,
        localDateTime.month,
        localDateTime.day,
      );

      // Skip today if you want to start from tomorrow:
      if (forecastDate.isBefore(localTomorrow)) {
        continue;
      }

      // Group by the day (in local time).
      final dayKey = forecastDate.millisecondsSinceEpoch;
      groupedByDay.putIfAbsent(dayKey, () => []).add(hourlyData);
    }

    // Build DailyForecast objects for each local day
    final dailyForecasts =
        groupedByDay.values.map((forecasts) {
          // Sort each day's 3-hour block by time, just in case
          forecasts.sort((a, b) => a.dateTime.compareTo(b.dateTime));
          final firstEntry = forecasts.first;

          final hourlyTemperatures = forecasts.map((f) => f.temperature);
          final minTemp = hourlyTemperatures.reduce((a, b) => a < b ? a : b);
          final maxTemp = hourlyTemperatures.reduce((a, b) => a > b ? a : b);

          return DailyForecast(
            timestamp: firstEntry.timestamp,
            // We want the local date/time for display
            dateTime: firstEntry.dateTime.toLocal(),
            minTemperature: minTemp,
            maxTemperature: maxTemp,
            iconCode: firstEntry.iconCode ?? '01d',
          );
        }).toList();

    // Sort final daily list by date, then take 7
    dailyForecasts.sort((a, b) => a.dateTime.compareTo(b.dateTime));
    return dailyForecasts.take(7).toList();
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
