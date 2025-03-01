import 'package:flutter/material.dart' hide ThemeMode;
import 'package:flutter/services.dart';

import 'package:domain/domain.dart';
import 'package:provider/provider.dart';

import 'config/app_theme.dart';
import 'presentation/pages/dashboard/dashboard_page.dart';

/// Manages the core functionalities of Flutter Weather.
///
/// Leverages the injected dependencies to provide the necessary services.
class FlutterWeatherApp extends StatelessWidget {
  /// Creates a new [FlutterWeatherApp].
  const FlutterWeatherApp({
    super.key,
    required this.appVersion,
    required this.share,
    required this.urlLauncher,
    required this.remoteSettingsService,
    required this.weatherService,
  });

  final AppVersion appVersion;
  final Share share;
  final UrlLauncher urlLauncher;

  final RemoteSettingsService remoteSettingsService;
  final WeatherService weatherService;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider.value(value: appVersion),
        Provider.value(value: share),
        Provider.value(value: urlLauncher),
        Provider.value(value: remoteSettingsService),
        Provider.value(value: weatherService),
        StreamProvider<UserSettings>(
          create: (_) => remoteSettingsService.userSettingsStream,
          initialData: remoteSettingsService.userSettings,
        ),
      ],
      builder: (context, __) {
        final mediaQuery = MediaQuery.of(context);

        final themeMode = context.select(
          (UserSettings userSettings) => userSettings.themeMode,
        );
        final theme = AppTheme.getTheme(
          mode: themeMode,
          brightness: mediaQuery.platformBrightness,
        );

        return MediaQuery(
          data: mediaQuery.copyWith(textScaler: TextScaler.noScaling),
          child: AnnotatedRegion<SystemUiOverlayStyle>(
            value:
                theme.colorScheme.brightness == Brightness.dark
                    ? SystemUiOverlayStyle.light
                    : SystemUiOverlayStyle.dark,
            child: DefaultTextStyle(
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: theme.colorScheme.onSurface,
              ),
              child: MaterialApp(
                title: 'Flutter Weather',
                theme: theme,
                home: const DashboardPage(),
              ),
            ),
          ),
        );
      },
    );
  }
}
