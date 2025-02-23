import 'package:flutter/material.dart';

import 'package:domain/domain.dart';
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
    final dashboardScope = context.watch<DashboardPageScope>();

    if (dashboardScope.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final currentWeather = dashboardScope.currentWeather;
    final hourlyForecast = dashboardScope.hourlyForecast;
    final dailyForecast = dashboardScope.dailyForecast;

    if (currentWeather == null ||
        hourlyForecast.isEmpty ||
        dailyForecast.isEmpty) {
      return const Scaffold(
        body: Center(child: Text('Failed to load weather data.')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Weather Forecast')),
      body: Column(
        children: [
          // Top section: current weather (occupies 1/3 of the screen)
          Expanded(
            flex: 1,
            child: _CurrentWeatherSection(current: currentWeather),
          ),
          // Horizontal list: hourly forecast for the current day (fixed height)
          SizedBox(
            height: 120,
            child: _HourlyForecastSection(hourly: hourlyForecast),
          ),
          // Remaining space: vertical list of daily forecasts (next 5 days)
          Expanded(flex: 2, child: _DailyForecastSection(daily: dailyForecast)),
        ],
      ),
    );
  }
}

/// Widget for displaying current weather information.
class _CurrentWeatherSection extends StatelessWidget {
  /// Creates a new [_CurrentWeatherSection].
  const _CurrentWeatherSection({required this.current});

  /// The current weather data.
  final CurrentWeather current;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '${current.temperature.toStringAsFixed(1)}°',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 8),
          Text(
            current.description,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Image.network(
            'https://openweathermap.org/img/wn/${current.iconCode}@2x.png',
            width: 80,
            height: 80,
            errorBuilder:
                (context, error, stackTrace) => const Icon(Icons.cloud),
          ),
        ],
      ),
    );
  }
}

/// Widget for displaying a horizontal list of hourly forecasts.
class _HourlyForecastSection extends StatelessWidget {
  const _HourlyForecastSection({required this.hourly});

  /// List of hourly forecasts.
  final List<HourlyForecast> hourly;

  @override
  Widget build(BuildContext context) {
    final hoursToShow = hourly.take(12).toList();
    return ListView.separated(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: hoursToShow.length,
      separatorBuilder: (context, index) => const SizedBox(width: 8),
      itemBuilder: (context, index) {
        final hourData = hoursToShow[index];
        final localHour = hourData.dateTime.toLocal().hour;
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('$localHour:00'),
            const SizedBox(height: 4),
            Image.network(
              'https://openweathermap.org/img/wn/${hourData.iconCode}@2x.png',
              width: 32,
              height: 32,
              errorBuilder:
                  (context, error, stackTrace) => const Icon(Icons.cloud),
            ),
            const SizedBox(height: 4),
            Text('${hourData.temperature.toStringAsFixed(0)}°'),
          ],
        );
      },
    );
  }
}

/// Widget for displaying a vertical list of daily forecasts.
class _DailyForecastSection extends StatelessWidget {
  /// Creates a new [_DailyForecastSection].
  const _DailyForecastSection({required this.daily});

  /// List of daily forecasts.
  final List<DailyForecast> daily;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: daily.length,
      itemBuilder: (context, index) {
        final day = daily[index];
        final localDate = day.dateTime.toLocal();
        final dateLabel = '${localDate.month}/${localDate.day}';
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: ListTile(
            leading: Image.network(
              'https://openweathermap.org/img/wn/${day.iconCode}@2x.png',
              width: 40,
              height: 40,
              errorBuilder:
                  (context, error, stackTrace) => const Icon(Icons.cloud),
            ),
            title: Text(dateLabel),
            subtitle: Text(
              'Min: ${day.minTemperature.toStringAsFixed(0)}°  Max: ${day.maxTemperature.toStringAsFixed(0)}°',
            ),
          ),
        );
      },
    );
  }
}
