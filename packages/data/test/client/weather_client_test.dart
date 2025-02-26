import 'dart:convert';

import 'package:domain/domain.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:clock/clock.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'package:data/src/client/weather_client.dart';

import 'weather_client_test.mocks.dart';

@GenerateNiceMocks([MockSpec<http.Client>()])
void main() {
  late MockClient mockHttpClient;
  late WeatherClient client;

  const apiKey = 'test-api-key';
  const coordinates = Coordinates(
    latitude: 30.2672,
    longitude: -97.7431,
  ); // Austin, TX

  setUp(() {
    mockHttpClient = MockClient();
    client = WeatherClient(apiKey: apiKey, client: mockHttpClient);
  });

  group('WeatherClient', () {
    group('getCurrentWeather', () {
      test(
        'returns CurrentWeather when status code is 200 with valid JSON',
        () async {
          final mockResponse = jsonEncode({
            'main': {'temp': 25.5, 'feels_like': 23.0, 'humidity': 60},
            'weather': [
              {'description': 'clear sky', 'icon': '01d'},
            ],
            'dt': 1638300000,
          });

          final expectedUri = Uri.parse(
            'https://api.openweathermap.org/data/2.5/weather?lat=${coordinates.latitude}&lon=${coordinates.longitude}&appid=$apiKey&units=metric',
          );

          when(mockHttpClient.get(expectedUri)).thenAnswer(
            (_) async => http.Response(
              mockResponse,
              200,
              headers: {'Content-Type': 'application/json'},
            ),
          );

          final result = await client.getCurrentWeather(
            coordinates: coordinates,
          );

          expect(result.temperature, 25.5);
          expect(result.feelsLikeTemperature, 23.0);
          expect(result.humidity, 60);
          expect(result.description, 'clear sky');
          expect(result.iconCode, '01d');

          verify(mockHttpClient.get(expectedUri)).called(1);
        },
      );

      test('throws an InvalidApiKeyException if status code is 401', () async {
        final expectedUri = Uri.parse(
          'https://api.openweathermap.org/data/2.5/weather?lat=${coordinates.latitude}&lon=${coordinates.longitude}&appid=$apiKey&units=metric',
        );

        when(
          mockHttpClient.get(expectedUri),
        ).thenAnswer((_) async => http.Response('Unauthorized', 401));

        expect(
          () => client.getCurrentWeather(coordinates: coordinates),
          throwsA(isA<InvalidApiKeyException>()),
        );
      });

      test('throws an exception if the response body is empty', () async {
        final expectedUri = Uri.parse(
          'https://api.openweathermap.org/data/2.5/weather?lat=${coordinates.latitude}&lon=${coordinates.longitude}&appid=$apiKey&units=metric',
        );

        when(
          mockHttpClient.get(expectedUri),
        ).thenAnswer((_) async => http.Response('', 200));

        expect(
          () => client.getCurrentWeather(coordinates: coordinates),
          throwsA(isA<Exception>()),
        );
      });
    });

    group('getHourlyForecast', () {
      test('returns a list of HourlyForecast when status code is 200', () async {
        final mockResponse = jsonEncode({
          'list': [
            {
              'dt': 1638303600,
              'main': {'temp': 26.0},
              'weather': [
                {'icon': '02d'},
              ],
            },
            {
              'dt': 1638310800,
              'main': {'temp': 27.5},
              'weather': [
                {'icon': '03d'},
              ],
            },
          ],
        });

        final expectedUri = Uri.parse(
          'https://api.openweathermap.org/data/2.5/forecast?lat=${coordinates.latitude}&lon=${coordinates.longitude}&appid=$apiKey&units=metric',
        );

        when(mockHttpClient.get(expectedUri)).thenAnswer(
          (_) async => http.Response(
            mockResponse,
            200,
            headers: {'Content-Type': 'application/json'},
          ),
        );

        final result = await client.getHourlyForecast(coordinates: coordinates);

        expect(result.length, 2);
        expect(result[0].temperature, 26.0);
        expect(result[0].iconCode, '02d');
        expect(result[1].temperature, 27.5);
        expect(result[1].iconCode, '03d');

        verify(mockHttpClient.get(expectedUri)).called(1);
      });

      test('throws an exception if status code is not 200', () async {
        final expectedUri = Uri.parse(
          'https://api.openweathermap.org/data/2.5/forecast?lat=${coordinates.latitude}&lon=${coordinates.longitude}&appid=$apiKey&units=metric',
        );

        when(
          mockHttpClient.get(expectedUri),
        ).thenAnswer((_) async => http.Response('Not Found', 404));

        expect(
          () => client.getHourlyForecast(coordinates: coordinates),
          throwsA(isA<Exception>()),
        );
      });
    });

    group('getDailyForecast', () {
      test('returns a list of DailyForecast when status code is 200', () async {
        final fixedTime = DateTime.utc(2021, 11, 29, 0, 0, 0); // Simulate "now"
        await withClock(Clock.fixed(fixedTime), () async {
          final mockResponse = jsonEncode({
            'list': [
              {
                'dt': 1638303600, // November 30, 2021 in UTC (tomorrow)
                'main': {'temp': 20.0},
                'weather': [
                  {'icon': '02d'},
                ],
              },
              {
                'dt': 1638317200, // Later on November 30.
                'main': {'temp': 28.0},
                'weather': [
                  {'icon': '02d'},
                ],
              },
              {
                'dt': 1638389999, // December 1, 2021 in UTC.
                'main': {'temp': 18.5},
                'weather': [
                  {'icon': '03d'},
                ],
              },
              {
                'dt': 1638400000, // Later on December 1.
                'main': {'temp': 25.5},
                'weather': [
                  {'icon': '03d'},
                ],
              },
            ],
          });

          final expectedUri = Uri.parse(
            'https://api.openweathermap.org/data/2.5/forecast?lat=${coordinates.latitude}&lon=${coordinates.longitude}&appid=$apiKey&units=metric',
          );

          when(mockHttpClient.get(expectedUri)).thenAnswer(
            (_) async => http.Response(
              mockResponse,
              200,
              headers: {'Content-Type': 'application/json'},
            ),
          );

          final result = await client.getDailyForecast(
            coordinates: coordinates,
          );

          // ✅ Fixing Expectations: Test should expect only the next 5 days (skipping today)
          expect(result.length, 2);
          expect(result[0].minTemperature, 20.0); // First day (Nov 30)
          expect(result[0].maxTemperature, 28.0);
          expect(result[0].iconCode, '02d');

          expect(result[1].minTemperature, 18.5); // Second day (Dec 1)
          expect(result[1].maxTemperature, 25.5);
          expect(result[1].iconCode, '03d');

          verify(mockHttpClient.get(expectedUri)).called(1);
        });
      });
      test('throws an exception if status code is not 200', () async {
        final expectedUri = Uri.parse(
          'https://api.openweathermap.org/data/2.5/forecast?lat=${coordinates.latitude}&lon=${coordinates.longitude}&appid=$apiKey&units=metric',
        );

        when(
          mockHttpClient.get(expectedUri),
        ).thenAnswer((_) async => http.Response('Internal Server Error', 500));

        expect(
          () => client.getDailyForecast(coordinates: coordinates),
          throwsA(isA<Exception>()),
        );
      });
    });
  });
}
