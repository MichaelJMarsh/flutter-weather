import 'package:domain/domain.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('HourlyForecast', () {
    final testJson = {
      'dt': 1638303600,
      'main': {'temp': 19.0},
      'weather': [
        {'icon': '01d'},
      ],
    };

    final forecast = HourlyForecast.fromJson(testJson);

    test('parses timestamp and dateTime correctly', () {
      expect(forecast.timestamp, equals(1638303600));
      final expectedDateTime = DateTime.fromMillisecondsSinceEpoch(
        1638303600 * 1000,
        isUtc: true,
      );
      expect(forecast.dateTime, equals(expectedDateTime));
    });

    test('parses temperature and iconCode correctly', () {
      expect(forecast.temperature, equals(19.0));
      expect(forecast.iconCode, equals('01d'));
    });

    test('equality and hashCode work correctly', () {
      final forecastCopy = HourlyForecast.fromJson(testJson);
      expect(forecast, equals(forecastCopy));
      expect(forecast.hashCode, equals(forecastCopy.hashCode));
    });

    test('toString returns a non-empty string', () {
      expect(forecast.toString().isNotEmpty, isTrue);
    });
  });
}
