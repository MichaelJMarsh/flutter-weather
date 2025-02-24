import 'package:domain/domain.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DailyForecast', () {
    final testJson = {
      'dt': 1638320000,
      'temp': {'min': 10.0, 'max': 22.0},
      'weather': [
        {'icon': '03d'},
      ],
    };

    final forecast = DailyForecast.fromJson(testJson);

    test('parses timestamp and dateTime correctly', () {
      expect(forecast.timestamp, equals(1638320000));
      final expectedDateTime = DateTime.fromMillisecondsSinceEpoch(
        1638320000 * 1000,
        isUtc: true,
      );
      expect(forecast.dateTime, equals(expectedDateTime));
    });

    test('parses minTemperature, maxTemperature, and iconCode correctly', () {
      expect(forecast.minTemperature, equals(10.0));
      expect(forecast.maxTemperature, equals(22.0));
      expect(forecast.iconCode, equals('03d'));
    });

    test('equality and hashCode work correctly', () {
      final forecastCopy = DailyForecast.fromJson(testJson);
      expect(forecast, equals(forecastCopy));
      expect(forecast.hashCode, equals(forecastCopy.hashCode));
    });

    test('toString returns a non-empty string', () {
      expect(forecast.toString().isNotEmpty, isTrue);
    });
  });
}
