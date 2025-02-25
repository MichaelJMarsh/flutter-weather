import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

import 'package:domain/domain.dart';
import 'package:flutter_weather/presentation/pages/settings/settings_page.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import 'package:flutter_weather/presentation/animations/entrance_animations.dart';
import 'package:flutter_weather/presentation/widgets/widgets.dart';

import 'dashboard_page_scope.dart';
import 'widgets/weekday_weather_card.dart';

/// A page displaying the current weather, a horizontal hourly forecast, and
/// a vertical list for daily forecasts.
class DashboardPage extends StatefulWidget {
  /// Creates a new [DashboardPage].
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage>
    with SingleTickerProviderStateMixin {
  /// The controller which manages the entrance animations.
  late final AnimationController _entranceAnimationsController;

  /// The entrance animations for the [DashboardPage].
  late final _EntranceAnimations _entranceAnimations;

  /// Timer to start the entrance animation.
  late final Timer _entranceAnimationsStartTimer;

  @override
  void initState() {
    super.initState();

    _entranceAnimationsController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    const sevenDayForecastLength = 7;
    _entranceAnimations = _EntranceAnimations(
      controller: _entranceAnimationsController,
      forecastCount: sevenDayForecastLength,
    );

    _entranceAnimationsStartTimer = Timer(
      const Duration(milliseconds: 200),
      _entranceAnimationsController.forward,
    );
  }

  @override
  void dispose() {
    _entranceAnimationsStartTimer.cancel();
    _entranceAnimationsController.dispose();

    super.dispose();
  }

  /// Navigates to the settings page.
  Future<void> _openSettingsPage() async {
    await Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const SettingsPage()));
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => DashboardPageScope.of(context)..initialize(),
      builder: (context, child) {
        final colorScheme = Theme.of(context).colorScheme;

        final mediaPadding = MediaQuery.paddingOf(context);
        final bottomPadding = 32 + mediaPadding.bottom;

        final dashboardScope = context.watch<DashboardPageScope>();
        final currentWeather = dashboardScope.currentWeather;
        final hourlyForecast = dashboardScope.hourlyForecast;
        final dailyForecast = dashboardScope.dailyForecast;

        Widget body = CustomScrollView(
          key: const Key('dashboard_layout'),
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverToBoxAdapter(
                child: _CurrentWeatherSection(
                  entranceAnimations: _entranceAnimations,
                  current: currentWeather,
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: AnimatedTranslation.vertical(
                animation: _entranceAnimations.hourlyForecast,
                pixels: 40,
                child: _HourlyForecastSection(hourly: hourlyForecast),
              ),
            ),
            SliverToBoxAdapter(
              child: AnimatedTranslation.vertical(
                animation: _entranceAnimations.divider,
                pixels: 40,
                child: Divider(
                  color: colorScheme.primary.withValues(alpha: 0.48),
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.only(top: 8, left: 32, right: 32),
              sliver: SliverToBoxAdapter(
                child: AnimatedTranslation.vertical(
                  animation: _entranceAnimations.dailyForecastHeader,
                  pixels: 40,
                  child: Text(
                    '5-DAY FORECAST',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      height: 24 / 14,
                      color: colorScheme.onSurface.withValues(alpha: 0.64),
                    ),
                  ),
                ),
              ),
            ),
            SliverPadding(
              padding: EdgeInsets.only(
                top: 16,
                left: 24,
                right: 24,
                bottom: bottomPadding,
              ),
              sliver: SliverList.separated(
                itemCount: dailyForecast.length,
                separatorBuilder: (context, index) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  return AnimatedTranslation.vertical(
                    animation: _entranceAnimations.dailyForecastCards[index],
                    pixels: 40,
                    child: WeekdayWeatherCard(forecast: dailyForecast[index]),
                  );
                },
              ),
            ),
          ],
        );

        final isLoading = dashboardScope.isLoading;
        if (isLoading) {
          body = AnimatedTranslation.vertical(
            key: Key(
              'dashboard_loading_layout.${isLoading ? 'visible' : 'hidden'}',
            ),
            animation: _entranceAnimations.loadingIndicator,
            pixels: 40,
            child: const Padding(
              padding: EdgeInsets.only(bottom: kToolbarHeight),
              child: LoadingLayout(message: Text('Loading weather data...')),
            ),
          );
        }

        final displayFailedToLoadState =
            currentWeather == null &&
            hourlyForecast.isEmpty &&
            dailyForecast.isEmpty;
        if (displayFailedToLoadState) {
          body = Padding(
            key: Key(
              'dashboard_error_layout.${displayFailedToLoadState ? 'visible' : 'hidden'}',
            ),
            padding: const EdgeInsets.only(bottom: kToolbarHeight),
            child: const Center(child: Text('Failed to load weather data.')),
          );
        }

        return Scaffold(
          appBar: AppBar(
            clipBehavior: Clip.none,
            title: Column(
              spacing: 8,
              children: [
                AnimatedTranslation.vertical(
                  animation: _entranceAnimations.appBarKicker,
                  pixels: 40,
                  child: Text(
                    'MY LOCATION',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurface.withValues(alpha: 0.64),
                    ),
                  ),
                ),
                AnimatedTranslation.vertical(
                  animation: _entranceAnimations.appBarTitle,
                  pixels: 40,
                  child: Text(
                    'Austin',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurface.withValues(alpha: 0.8),
                    ),
                  ),
                ),
              ],
            ),
            actions: [
              AnimatedTranslation.horizontal(
                animation: _entranceAnimations.appBarButton,
                pixels: 32,
                child: IconButton(
                  icon: const Icon(Icons.settings),
                  onPressed: _openSettingsPage,
                ),
              ),
            ],
          ),
          body: AnimatedSwitcher(
            switchInCurve: Curves.easeIn,
            switchOutCurve: Curves.easeOut,
            duration: const Duration(milliseconds: 350),
            layoutBuilder: (currentChild, previousChildren) {
              return Stack(
                alignment: Alignment.topCenter,
                children: [
                  ...previousChildren,
                  if (currentChild != null) currentChild,
                ],
              );
            },
            child: body,
          ),
        );
      },
    );
  }
}

/// Widget for displaying current weather information.
class _CurrentWeatherSection extends StatelessWidget {
  /// Creates a new [_CurrentWeatherSection].
  const _CurrentWeatherSection({
    required this.entranceAnimations,
    required this.current,
  });

  /// The entrance animations for the current weather section.
  final _EntranceAnimations entranceAnimations;

  /// The current weather data.
  final CurrentWeather? current;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final dashboardScope = context.watch<DashboardPageScope>();

    // Get today's forecast from dailyForecast
    final todayForecast =
        dashboardScope.dailyForecast.isNotEmpty
            ? dashboardScope.dailyForecast.first
            : null;

    final minTemp = todayForecast?.minTemperature.round() ?? '--';
    final maxTemp = todayForecast?.maxTemperature.round() ?? '--';

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        AnimatedTranslation.vertical(
          animation: entranceAnimations.currentTemperature,
          pixels: 40,
          child: Text(
            '${current?.temperature.toStringAsFixed(1) ?? 0}°',
            style: TextStyle(
              fontSize: 64,
              fontWeight: FontWeight.w200,
              color: colorScheme.onSurface,
            ),
          ),
        ),
        const SizedBox(height: 8),
        AnimatedTranslation.vertical(
          animation: entranceAnimations.currentWeatherDescription,
          pixels: 40,
          child: Text(
            current?.description.toUpperCase() ?? '',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface.withValues(alpha: 0.64),
            ),
          ),
        ),
        const SizedBox(height: 8),
        AnimatedTranslation.vertical(
          animation: entranceAnimations.currentTemperatureExtremes,
          pixels: 40,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'L: $minTemp°',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: colorScheme.onSurface.withValues(alpha: 0.64),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'H: $maxTemp°',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: colorScheme.onSurface.withValues(alpha: 0.64),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Widget for displaying a horizontal list of hourly forecasts.
class _HourlyForecastSection extends StatelessWidget {
  /// Creates a new [_HourlyForecastSection].
  const _HourlyForecastSection({required this.hourly});

  /// List of hourly forecasts.
  final List<HourlyForecast> hourly;

  @override
  Widget build(BuildContext context) {
    final hoursToShow = hourly.take(12).toList();

    return SizedBox(
      height: 140,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: hoursToShow.length,
        separatorBuilder: (_, __) => const SizedBox(width: 16),
        itemBuilder: (context, index) {
          final hourData = hoursToShow[index];
          final formattedHour = DateFormat.H().format(
            hourData.dateTime,
          ); // 'Mon 3 PM'

          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                formattedHour,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              WeatherIcon(iconCode: hourData.iconCode, size: 36),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${hourData.temperature.toStringAsFixed(0)}°',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

/// The entrance animations for each item on the [DashboardPage].
class _EntranceAnimations extends EntranceAnimations {
  /// Creates a new [_EntranceAnimations].
  const _EntranceAnimations({
    required super.controller,
    required int forecastCount,
  }) : _forecastCount = forecastCount;

  /// The number of daily forecasts to animate.
  final int _forecastCount;

  Animation<double> get appBarButton => curvedAnimation(0.000, 0.250);
  Animation<double> get appBarKicker => curvedAnimation(0.025, 0.275);
  Animation<double> get appBarTitle => curvedAnimation(0.0375, 0.2875);

  Animation<double> get currentTemperature => curvedAnimation(0.100, 0.350);

  Animation<double> get currentWeatherDescription =>
      curvedAnimation(0.125, 0.375);
  Animation<double> get currentTemperatureExtremes =>
      curvedAnimation(0.1375, 0.3875);

  Animation<double> get loadingIndicator => curvedAnimation(0.150, 0.400);

  Animation<double> get hourlyForecast => curvedAnimation(0.1875, 0.4375);

  Animation<double> get divider => curvedAnimation(0.2125, 0.4625);

  Animation<double> get dailyForecastHeader => curvedAnimation(0.250, 0.500);

  List<Animation<double>> get dailyForecastCards {
    return List.generate(_forecastCount, (index) {
      final end = min(0.525 + (0.025 * index), 0.500);

      return curvedAnimation(end - 0.250, end);
    });
  }
}
