import 'dart:convert';

import 'package:domain/domain.dart';
import 'package:http/http.dart' as http;

/// A client for fetching weather data from OpenWeather's Free APIs.
class WeatherClient implements WeatherService {
  WeatherClient({required String? apiKey, http.Client? client})
    : _apiKey = apiKey,
      _client = client ?? http.Client();

  final String? _apiKey;
  final http.Client _client;

  static const String _baseUrl = 'https://api.openweathermap.org';

  @override
  Future<CurrentWeather> getCurrentWeather({
    required double lat,
    required double lon,
  }) async {
    if (_apiKey == null || _apiKey.isEmpty) {
      throw Exception('API key is missing or invalid.');
    }

    final uri = Uri.parse('$_baseUrl/data/2.5/weather').replace(
      queryParameters: {
        'lat': lat.toString(),
        'lon': lon.toString(),
        'appid': _apiKey,
        'units': 'metric',
      },
    );

    final response = await _client.get(uri);

    if (response.statusCode == 401) {
      throw Exception(
        'Invalid API Key. Get a free one at https://openweathermap.org/api.',
      );
    }

    if (response.statusCode != 200) {
      throw Exception(
        'Failed to load current weather. Status code: ${response.statusCode}\nResponse: ${response.body}',
      );
    }

    final jsonBody = json.decode(response.body) as Map<String, dynamic>;
    return CurrentWeather.fromJson(jsonBody);
  }

  @override
  Future<List<HourlyForecast>> getHourlyForecast({
    required double lat,
    required double lon,
  }) async {
    if (_apiKey == null || _apiKey.isEmpty) {
      throw Exception('API key is missing or invalid.');
    }

    final uri = Uri.parse('$_baseUrl/data/2.5/forecast').replace(
      queryParameters: {
        'lat': lat.toString(),
        'lon': lon.toString(),
        'appid': _apiKey,
        'units': 'metric',
      },
    );

    final response = await _client.get(uri);

    if (response.statusCode == 401) {
      throw Exception(
        'Invalid API Key. Get a free one at https://openweathermap.org/api.',
      );
    }

    if (response.statusCode != 200) {
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
    required double lat,
    required double lon,
  }) async {
    if (_apiKey == null || _apiKey.isEmpty) {
      throw Exception('API key is missing or invalid.');
    }

    final uri = Uri.parse('$_baseUrl/data/2.5/forecast').replace(
      queryParameters: {
        'lat': lat.toString(),
        'lon': lon.toString(),
        'appid': _apiKey,
        'units': 'metric',
      },
    );

    final response = await _client.get(uri);

    if (response.statusCode == 401) {
      throw Exception(
        'Invalid API Key. Get a free one at https://openweathermap.org/api.',
      );
    }

    if (response.statusCode != 200) {
      throw Exception(
        'Failed to load daily forecast. Status code: ${response.statusCode}\nResponse: ${response.body}',
      );
    }

    final jsonBody = json.decode(response.body) as Map<String, dynamic>;
    final List<dynamic> forecastList = jsonBody['list'] ?? [];

    // Extract daily summaries from 3-hour forecast data
    final Map<int, List<HourlyForecast>> groupedByDay = {};

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
      final minTemp = forecasts
          .map((e) => e.temperature)
          .reduce((a, b) => a < b ? a : b);
      final maxTemp = forecasts
          .map((e) => e.temperature)
          .reduce((a, b) => a > b ? a : b);

      return DailyForecast(
        timestamp: firstEntry.timestamp,
        dateTime: firstEntry.dateTime,
        minTemperature: minTemp,
        maxTemperature: maxTemp,
        iconCode: firstEntry.iconCode ?? '01d',
      );
    }).toList();
  }
}
