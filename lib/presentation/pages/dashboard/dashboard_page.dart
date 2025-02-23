import 'package:flutter/material.dart';

import 'package:domain/domain.dart';
import 'package:flutter_weather/presentation/pages/dashboard/widgets/weekday_weather_card.dart';
import 'package:flutter_weather/presentation/widgets/widgets.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import 'dashboard_page_scope.dart';

/// A dashboard page displaying the current weather, a horizontal hourly forecast,
/// and a vertical list for daily forecasts.
class DashboardPage extends StatelessWidget {
  /// Creates a new [DashboardPage].
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => DashboardPageScope.of(context)..initialize(),
      child: const _Layout(),
    );
  }
}

/// The layout for the [DashboardPage].
class _Layout extends StatelessWidget {
  /// Creates a new [_Layout].
  const _Layout();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final mediaPadding = MediaQuery.paddingOf(context);
    final bottomPadding = 32 + mediaPadding.bottom;

    final dashboardScope = context.watch<DashboardPageScope>();
    final currentWeather = dashboardScope.currentWeather;
    final hourlyForecast = dashboardScope.hourlyForecast;
    final dailyForecast = dashboardScope.dailyForecast;

    Widget body = CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.all(16),
          sliver: SliverToBoxAdapter(
            child: _CurrentWeatherSection(current: currentWeather),
          ),
        ),
        SliverToBoxAdapter(
          child: _HourlyForecastSection(hourly: hourlyForecast),
        ),
        SliverToBoxAdapter(
          child: Divider(color: colorScheme.primary.withValues(alpha: 0.48)),
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
              return WeekdayWeatherCard(forecast: dailyForecast[index]);
            },
          ),
        ),
      ],
    );

    final isLoading = dashboardScope.isLoading;
    if (isLoading) {
      body = LoadingLayout(
        key: Key(
          'dashboard_loading_layout.${isLoading ? 'visible' : 'hidden'}',
        ),
        message: Text('Loading weather data...'),
      );
    }

    if (currentWeather == null ||
        hourlyForecast.isEmpty ||
        dailyForecast.isEmpty) {
      body = Center(child: Text('Failed to load weather data.'));
    }

    return Scaffold(
      appBar: AppBar(
        title: Column(
          spacing: 8,
          children: [
            Text(
              'MY LOCATION',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface.withValues(alpha: 0.64),
              ),
            ),
            Text(
              'Austin',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface.withValues(alpha: 0.8),
              ),
            ),
          ],
        ),
      ),
      body: AnimatedSwitcher(
        switchInCurve: Curves.easeIn,
        switchOutCurve: Curves.easeOut,
        duration: const Duration(milliseconds: 350),
        child: body,
      ),
    );
  }
}

/// Widget for displaying current weather information.
class _CurrentWeatherSection extends StatelessWidget {
  /// Creates a new [_CurrentWeatherSection].
  const _CurrentWeatherSection({required this.current});

  /// The current weather data.
  final CurrentWeather? current;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          '${current?.temperature.toStringAsFixed(1) ?? 0}°',
          style: TextStyle(
            fontSize: 64,
            fontWeight: FontWeight.w200,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          current?.description.toUpperCase() ?? '',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface.withValues(alpha: 0.24),
          ),
        ),
        const SizedBox(height: 8),
        WeatherIcon(iconCode: current?.iconCode, size: 80),
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
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
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
