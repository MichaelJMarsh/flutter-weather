import 'dart:convert';

import 'package:domain/domain.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
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

          when(mockHttpClient.get(any)).thenAnswer(
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

          verify(mockHttpClient.get(any)).called(1);
        },
      );

      test('throws an exception if status code is not 200', () async {
        when(
          mockHttpClient.get(any),
        ).thenAnswer((_) async => http.Response('Unauthorized', 401));

        expect(
          () => client.getCurrentWeather(coordinates: coordinates),
          throwsA(isA<InvalidApiKeyException>()),
        );
      });

      test('throws an exception if the response body is empty', () async {
        when(
          mockHttpClient.get(any),
        ).thenAnswer((_) async => http.Response('', 200));

        expect(
          () => client.getCurrentWeather(coordinates: coordinates),
          throwsA(isA<Exception>()),
        );
      });

      test('throws an exception if JSON is malformed', () async {
        when(mockHttpClient.get(any)).thenAnswer(
          (_) async => http.Response('{"invalid_key": "missing_data"}', 200),
        );

        expect(
          () => client.getCurrentWeather(coordinates: coordinates),
          throwsA(isA<Exception>()),
        );
      });
    });

    group('getHourlyForecast', () {
      test(
        'returns a list of HourlyForecast when status code is 200 with valid JSON',
        () async {
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

          when(mockHttpClient.get(any)).thenAnswer(
            (_) async => http.Response(
              mockResponse,
              200,
              headers: {'Content-Type': 'application/json'},
            ),
          );

          final result = await client.getHourlyForecast(
            coordinates: coordinates,
          );

          expect(result.length, 2);
          expect(result[0].temperature, 26.0);
          expect(result[0].iconCode, '02d');
          expect(result[1].temperature, 27.5);
          expect(result[1].iconCode, '03d');

          verify(mockHttpClient.get(any)).called(1);
        },
      );

      test(
        'returns an empty list if JSON response lacks necessary keys',
        () async {
          final mockResponse = jsonEncode({'status': 'ok'});

          when(mockHttpClient.get(any)).thenAnswer(
            (_) async => http.Response(
              mockResponse,
              200,
              headers: {'Content-Type': 'application/json'},
            ),
          );

          final result = await client.getHourlyForecast(
            coordinates: coordinates,
          );

          expect(result, isEmpty);
        },
      );

      test('throws an exception if status code is not 200', () async {
        when(
          mockHttpClient.get(any),
        ).thenAnswer((_) async => http.Response('Not Found', 404));

        expect(
          () => client.getHourlyForecast(coordinates: coordinates),
          throwsA(isA<Exception>()),
        );
      });

      test('throws an exception if API key is missing', () {
        final invalidClient = WeatherClient(apiKey: '', client: mockHttpClient);

        expect(
          () => invalidClient.getHourlyForecast(coordinates: coordinates),
          throwsA(isA<MissingApiKeyException>()),
        );
      });
    });

    group('getDailyForecast', () {
      test(
        'returns a list of DailyForecast when status code is 200 with valid JSON',
        () async {
          final mockResponse = jsonEncode({
            'list': [
              {
                'dt': 1638303600,
                'main': {'temp_min': 20.0, 'temp_max': 28.0},
                'weather': [
                  {'icon': '02d'},
                ],
              },
              {
                'dt': 1638389999,
                'main': {'temp_min': 18.5, 'temp_max': 25.5},
                'weather': [
                  {'icon': '03d'},
                ],
              },
            ],
          });

          when(mockHttpClient.get(any)).thenAnswer(
            (_) async => http.Response(
              mockResponse,
              200,
              headers: {'Content-Type': 'application/json'},
            ),
          );

          final result = await client.getDailyForecast(
            coordinates: coordinates,
          );

          expect(result.length, 2);
          expect(result[0].minTemperature, 20.0);
          expect(result[0].maxTemperature, 28.0);
          expect(result[0].iconCode, '02d');
          expect(result[1].minTemperature, 18.5);
          expect(result[1].maxTemperature, 25.5);
          expect(result[1].iconCode, '03d');

          verify(mockHttpClient.get(any)).called(1);
        },
      );

      test('throws an exception if status code is not 200', () async {
        when(
          mockHttpClient.get(any),
        ).thenAnswer((_) async => http.Response('Internal Server Error', 500));

        expect(
          () => client.getDailyForecast(coordinates: coordinates),
          throwsA(isA<Exception>()),
        );
      });

      test(
        'returns empty list if JSON response lacks necessary keys',
        () async {
          final mockResponse = jsonEncode({'status': 'ok'});

          when(mockHttpClient.get(any)).thenAnswer(
            (_) async => http.Response(
              mockResponse,
              200,
              headers: {'Content-Type': 'application/json'},
            ),
          );

          final result = await client.getDailyForecast(
            coordinates: coordinates,
          );

          expect(result, isEmpty);
        },
      );

      test('throws an exception if API key is missing', () {
        final invalidClient = WeatherClient(apiKey: '', client: mockHttpClient);

        expect(
          () => invalidClient.getDailyForecast(coordinates: coordinates),
          throwsA(isA<MissingApiKeyException>()),
        );
      });
    });
  });
}
