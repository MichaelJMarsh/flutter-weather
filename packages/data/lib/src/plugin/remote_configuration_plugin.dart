import 'package:domain/domain.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';

class RemoteConfigurationPlugin implements RemoteConfigurationService {
  /// Creates a new [RemoteConfigurationPlugin].
  const RemoteConfigurationPlugin({required FirebaseRemoteConfig remoteConfig})
    : _remoteConfig = remoteConfig;

  final FirebaseRemoteConfig _remoteConfig;

  @override
  String get weatherApiKey {
    return _remoteConfig.getString('open_weather_map_api_key');
  }

  @override
  Future<void> initialize() async {
    await _remoteConfig.setConfigSettings(
      RemoteConfigSettings(
        fetchTimeout: const Duration(seconds: 10),
        // Fetch once per hour.
        minimumFetchInterval: const Duration(hours: 1),
      ),
    );

    await _remoteConfig.fetchAndActivate();
  }
}
