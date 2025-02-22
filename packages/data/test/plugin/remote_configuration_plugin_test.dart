import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'package:data/src/plugin/remote_configuration_plugin.dart';

import 'remote_configuration_plugin_test.mocks.dart';

@GenerateNiceMocks([MockSpec<FirebaseRemoteConfig>()])
void main() {
  late MockFirebaseRemoteConfig mockRemoteConfig;
  late RemoteConfigurationPlugin plugin;

  setUp(() {
    mockRemoteConfig = MockFirebaseRemoteConfig();
    // Stub getString to return a dummy API key.
    when(mockRemoteConfig.getString(any)).thenReturn('dummy_api_key');
    plugin = RemoteConfigurationPlugin(remoteConfig: mockRemoteConfig);
  });

  group('RemoteConfigurationPlugin', () {
    test('weatherApiKey returns value from remote config', () {
      final apiKey = plugin.weatherApiKey;

      verify(mockRemoteConfig.getString('open_weather_map_api_key')).called(1);
      expect(apiKey, equals('dummy_api_key'));
    });

    test('initialize() calls setConfigSettings and fetchAndActivate', () async {
      when(mockRemoteConfig.setConfigSettings(any)).thenAnswer((_) async {});
      when(mockRemoteConfig.fetchAndActivate()).thenAnswer((_) async => true);

      await plugin.initialize();

      final captured =
          verify(mockRemoteConfig.setConfigSettings(captureAny)).captured.single
              as RemoteConfigSettings;

      // Verify that the settings were set correctly.
      expect(captured.fetchTimeout, equals(const Duration(seconds: 10)));
      expect(captured.minimumFetchInterval, equals(const Duration(hours: 1)));

      verify(mockRemoteConfig.fetchAndActivate()).called(1);
    });
  });
}
