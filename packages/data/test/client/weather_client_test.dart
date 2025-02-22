import 'dart:convert';

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

  setUp(() {
    mockHttpClient = MockClient();
    client = WeatherClient(apiKey: apiKey, client: mockHttpClient);
  });

  group('WeatherClient', () {
    group('getWeather', () {
      test(
        'returns a list of WeatherData when status code is 200 with valid JSON',
        () async {
          final mockResponse = jsonEncode({
            'main': {'temp': 22.5, 'humidity': 55},
            'weather': [
              {'description': 'light rain', 'icon': '10d'},
            ],
          });

          when(mockHttpClient.get(any)).thenAnswer(
            (_) async => http.Response(
              mockResponse,
              200,
              headers: {'Content-Type': 'application/json'},
            ),
          );

          final result = await client.getWeather(
            startDate: DateTime(2023, 5, 1),
            endDate: DateTime(2023, 5, 7),
          );

          expect(result.length, 1);
          expect(result[0].temperature, 22.5);
          expect(result[0].humidity, 55);
          expect(result[0].description, 'light rain');
          expect(result[0].icon, '10d');
        },
      );

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

          final result = await client.getWeather(
            startDate: DateTime(2023, 5, 1),
            endDate: DateTime(2023, 5, 7),
          );

          expect(result, isEmpty);
        },
      );

      test('throws an exception if status code is not 200', () async {
        when(
          mockHttpClient.get(any),
        ).thenAnswer((_) async => http.Response('Unauthorized', 401));

        expect(
          () => client.getWeather(
            startDate: DateTime(2023, 5, 1),
            endDate: DateTime(2023, 5, 7),
          ),
          throwsA(isA<Exception>()),
        );
      });
    });
  });
}
