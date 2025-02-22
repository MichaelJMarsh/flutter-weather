import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import 'package:data/data.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';

import 'package:flutter_weather/config/firebase_options.dart';

import 'app.dart';

/// The entry point for the Flutter Weather application.
///
/// Initializes the database and other services, then launches the [FlutterWeatherApp].
class Bootstrap {
  const Bootstrap._();

  /// Initializes the database and other services, then returns the
  /// created [FlutterWeatherApp].
  static Future<FlutterWeatherApp> initializeApp() async {
    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

    final remoteConfig = RemoteConfigurationPlugin(
      remoteConfig: FirebaseRemoteConfig.instance,
    );

    await remoteConfig.initialize();

    return FlutterWeatherApp(
      share: SharePlugin(delegate: ShareDelegate()),
      urlLauncher: UrlLauncherPlugin(delegate: UrlLauncherDelegate()),
      weatherService: WeatherClient(apiKey: remoteConfig.weatherApiKey),
    );
  }
}
