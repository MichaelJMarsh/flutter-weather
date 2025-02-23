import 'package:domain/domain.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('WeatherForecast', () {
    final testJson = {
      'lat': 40.7128,
      'lon': -74.0060,
      'timezone': 'America/New_York',
      'current': {
        'dt': 1638300000,
        'temp': 18.5,
        'feels_like': 17.0,
        'humidity': 80,
        'weather': [
          {'description': 'clear sky', 'icon': '01d'},
        ],
      },
      'hourly': [
        {
          'dt': 1638303600,
          'temp': 19.0,
          'weather': [
            {'icon': '01d'},
          ],
        },
        {
          'dt': 1638307200,
          'temp': 20.0,
          'weather': [
            {'icon': '02d'},
          ],
        },
      ],
      'daily': [
        {
          'dt': 1638320000,
          'temp': {'min': 10.0, 'max': 22.0},
          'weather': [
            {'icon': '03d'},
          ],
        },
        {
          'dt': 1638406400,
          'temp': {'min': 12.0, 'max': 24.0},
          'weather': [
            {'icon': '04d'},
          ],
        },
      ],
    };

    final forecast = WeatherForecast.fromJson(testJson);

    test('parses latitude, longitude, and timezone correctly', () {
      expect(forecast.latitude, 40.7128);
      expect(forecast.longitude, -74.0060);
      expect(forecast.timezone, 'America/New_York');
    });

    test('parses current weather correctly', () {
      final current = forecast.current;
      expect(current.temperature, 18.5);
      expect(current.feelsLikeTemperature, 17.0);
      expect(current.humidity, 80);
      expect(current.description, 'clear sky');
      expect(current.iconCode, '01d');
    });

    test('parses hourly forecast correctly', () {
      expect(forecast.hourly.length, 2);
      final firstHour = forecast.hourly.first;
      expect(firstHour.temperature, 19.0);
      expect(firstHour.iconCode, '01d');
    });

    test('parses daily forecast correctly', () {
      expect(forecast.daily.length, 2);
      final firstDay = forecast.daily.first;
      expect(firstDay.minTemperature, 10.0);
      expect(firstDay.maxTemperature, 22.0);
      expect(firstDay.iconCode, '03d');
    });

    test('equality and hashCode work correctly', () {
      final forecastCopy = WeatherForecast.fromJson(testJson);
      expect(forecast, equals(forecastCopy));
      expect(forecast.hashCode, equals(forecastCopy.hashCode));
    });

    test('toString returns a non-empty string', () {
      expect(forecast.toString().isNotEmpty, true);
    });
  });
}
