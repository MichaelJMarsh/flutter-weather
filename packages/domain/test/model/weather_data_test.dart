import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:domain/domain.dart';

void main() {
  group('WeatherData', () {
    const testWeather = WeatherData(
      temperature: 25.5,
      humidity: 65,
      description: 'Clear sky',
      icon: '01d',
    );

    test('correctly stores and retrieves values', () {
      const weather = WeatherData(
        temperature: 30.0,
        humidity: 50,
        description: 'Sunny',
        icon: '02d',
      );

      expect(weather.temperature, 30.0);
      expect(weather.humidity, 50);
      expect(weather.description, 'Sunny');
      expect(weather.icon, '02d');

      final jsonMap = weather.toJson();
      expect(jsonMap, {
        'temperature': 30.0,
        'humidity': 50,
        'description': 'Sunny',
        'icon': '02d',
      });

      final reconstructedWeather = WeatherData.fromJson(jsonMap);
      expect(reconstructedWeather, equals(weather));
    });

    test('toJson returns correct map representation', () {
      final jsonMap = testWeather.toJson();

      expect(jsonMap['temperature'], testWeather.temperature);
      expect(jsonMap['humidity'], testWeather.humidity);
      expect(jsonMap['description'], testWeather.description);
      expect(jsonMap['icon'], testWeather.icon);
    });

    test('fromJson reconstructs WeatherData', () {
      final jsonString = jsonEncode(testWeather.toJson());
      final jsonMap = jsonDecode(jsonString) as Map<String, dynamic>;

      final weatherFromJson = WeatherData.fromJson(jsonMap);

      expect(weatherFromJson, equals(testWeather));
      expect(weatherFromJson.temperature, testWeather.temperature);
      expect(weatherFromJson.humidity, testWeather.humidity);
      expect(weatherFromJson.description, testWeather.description);
      expect(weatherFromJson.icon, testWeather.icon);
    });

    test('equality and hashCode', () {
      const sameWeather = WeatherData(
        temperature: 25.5,
        humidity: 65,
        description: 'Clear sky',
        icon: '01d',
      );

      // Different temperature
      const differentWeather = WeatherData(
        temperature: 22.0,
        humidity: 65,
        description: 'Clear sky',
        icon: '01d',
      );

      expect(testWeather, equals(sameWeather));
      expect(testWeather.hashCode, equals(sameWeather.hashCode));
      expect(testWeather, isNot(equals(differentWeather)));
    });
  });
}
