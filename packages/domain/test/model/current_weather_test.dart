import 'package:domain/domain.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CurrentWeather', () {
    final testJson = {
      'dt': 1638300000,
      'main': {'temp': 18.5, 'feels_like': 17.0, 'humidity': 80},
      'weather': [
        {'description': 'clear sky', 'icon': '01d'},
      ],
    };

    final weather = CurrentWeather.fromJson(testJson);

    test('parses timestamp and dateTime correctly', () {
      expect(weather.timestamp, 1638300000);
      expect(
        weather.dateTime,
        DateTime.fromMillisecondsSinceEpoch(1638300000 * 1000, isUtc: true),
      );
    });

    test(
      'parses temperature, feelsLikeTemperature, and humidity correctly',
      () {
        expect(weather.temperature, equals(18.5));
        expect(weather.feelsLikeTemperature, equals(17.0));
        expect(weather.humidity, equals(80));
      },
    );

    test('parses description and iconCode correctly', () {
      expect(weather.description, equals('clear sky'));
      expect(weather.iconCode, equals('01d'));
    });

    test('equality and hashCode work correctly', () {
      final weatherCopy = CurrentWeather.fromJson(testJson);
      expect(weather, equals(weatherCopy));
      expect(weather.hashCode, equals(weatherCopy.hashCode));
    });

    test('toString returns a non-empty string', () {
      expect(weather.toString().isNotEmpty, true);
    });
  });
}
