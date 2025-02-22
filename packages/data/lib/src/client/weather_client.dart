import 'dart:convert';

import 'package:domain/domain.dart';
import 'package:http/http.dart' as http;

/// A client for fetching weather data from OpenWeatherMap.
class WeatherClient implements WeatherService {
  /// Creates a new instance of [WeatherClient].
  WeatherClient({required String? apiKey, http.Client? client})
    : _apiKey = apiKey,
      _client = client ?? http.Client();

  final String? _apiKey;
  final http.Client _client;

  // Free API Base URL
  static const String _baseUrl = 'api.openweathermap.org';

  @override
  Future<List<WeatherData>> getWeather({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    if (_apiKey == null || _apiKey.isEmpty) {
      throw Exception('API key is missing or invalid.');
    }

    // Example coordinates (New York). Update dynamically as needed.
    final double latitude = 40.7128;
    final double longitude = -74.0060;

    final queryParams = {
      'lat': latitude.toString(),
      'lon': longitude.toString(),
      'appid': _apiKey,
      'units': 'metric', // Use 'imperial' for Fahrenheit
    };

    final uri = Uri.https(_baseUrl, '/data/2.5/weather', queryParams);

    final response = await _client.get(uri);

    if (response.statusCode != 200) {
      throw Exception(
        'Failed to load weather data. Status code: ${response.statusCode}\nResponse: ${response.body}',
      );
    }

    final jsonBody = json.decode(response.body) as Map<String, dynamic>;

    return [WeatherData.fromJson(jsonBody)];
  }
}
