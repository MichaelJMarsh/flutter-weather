import 'package:flutter/material.dart';

import 'package:domain/domain.dart';
import 'package:intl/intl.dart';

import 'package:flutter_weather/presentation/widgets/widgets.dart';

/// The card containing the weather forecast for a specific day.
class WeekdayWeatherCard extends StatelessWidget {
  /// Creates a new [WeekdayWeatherCard].
  const WeekdayWeatherCard({super.key, required this.forecast});

  /// The forecast for the current day.
  final DailyForecast forecast;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final localDate = forecast.dateTime.toLocal();
    final dayLabel = DateFormat.E().format(localDate);

    final minTemp = forecast.minTemperature;
    final maxTemp = forecast.maxTemperature;
    final minTempString = minTemp.toStringAsFixed(0);
    final maxTempString = maxTemp.toStringAsFixed(0);

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      color: colorScheme.surface,
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: DefaultTextStyle.merge(
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                width: 48,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    dayLabel,
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: Center(
                  child: WeatherIcon(iconCode: forecast.iconCode, size: 40),
                ),
              ),
              SizedBox(
                width: 32,
                child: Center(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      '$minTempString°',
                      style: TextStyle(
                        color: colorScheme.onSurface.withValues(alpha: 0.48),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                flex: 2,
                child: _TemperatureProgressBar(
                  minimumTemperature: minTemp,
                  maximumTemperature: maxTemp,
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                width: 32,
                child: Center(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text('$maxTempString°'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A progress bar that represents the temperature range for a day.
///
/// The gradient colors are chosen based on the minimum and maximum temperatures,
/// using a private getter that maps temperature ranges (in Celsius) to colors.
class _TemperatureProgressBar extends StatefulWidget {
  /// Creates a new [_TemperatureProgressBar].
  const _TemperatureProgressBar({
    required this.minimumTemperature,
    required this.maximumTemperature,
  });

  /// The minimum temperature for the day.
  final double minimumTemperature;

  /// The maximum temperature for the day.
  final double maximumTemperature;

  @override
  State<_TemperatureProgressBar> createState() =>
      _TemperatureProgressBarState();
}

class _TemperatureProgressBarState extends State<_TemperatureProgressBar> {
  /// The starting color for the progress bar.
  late Color _startColor;

  /// The ending color for the progress bar.
  late Color _endColor;

  // Computes the progress of the bar relative to a 40° difference.
  double get _progress {
    final temperatureRange =
        widget.maximumTemperature - widget.minimumTemperature;

    return (temperatureRange / 40).clamp(0.0, 1.0) * 2;
  }

  @override
  void initState() {
    super.initState();

    _startColor = _getColorForTemperature(widget.minimumTemperature);
    _endColor = _getColorForTemperature(widget.maximumTemperature);
  }

  @override
  void didUpdateWidget(covariant _TemperatureProgressBar oldWidget) {
    super.didUpdateWidget(oldWidget);

    final didUpdateMinimumTemperature =
        oldWidget.minimumTemperature != widget.minimumTemperature;
    final didUpdateMaximumTemperature =
        oldWidget.maximumTemperature != widget.maximumTemperature;
    if (didUpdateMinimumTemperature || didUpdateMaximumTemperature) {
      _startColor = _getColorForTemperature(widget.minimumTemperature);
      _endColor = _getColorForTemperature(widget.maximumTemperature);
    }
  }

  /// Returns a color based on the temperature category.
  Color _getColorForTemperature(double temperature) {
    final temperatureValue = _getNormalizedTemperatureValue(temperature);

    return switch (temperatureValue) {
      // Cold
      0 => Colors.lightBlue,
      //Cool
      1 => Colors.lightGreen,
      // Neutral
      2 => Colors.yellowAccent,
      // Warm
      3 => Colors.orangeAccent,
      // Hot
      4 => Colors.redAccent,
      _ => Colors.grey,
    };
  }

  /// Returns the normalized progress of the temperature range.
  ///
  /// The temperature ranges are based on Celsius values.
  int _getNormalizedTemperatureValue(double temperature) {
    if (temperature < 5) {
      return 0;
    } else if (temperature < 15) {
      return 1;
    } else if (temperature < 22) {
      return 2;
    } else if (temperature < 30) {
      return 3;
    } else {
      return 4;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    const barHeight = 4.0;
    const borderRadius = BorderRadius.all(Radius.circular(8));

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final animatedWidth = width * _progress;

        return SizedBox(
          height: barHeight,
          width: width,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: colorScheme.onSurface.withValues(alpha: 0.08),
              borderRadius: borderRadius,
            ),

            child: Align(
              alignment: Alignment.centerLeft,
              child: ClipRRect(
                borderRadius: borderRadius,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.easeInOut,
                  height: barHeight,
                  width: animatedWidth,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [_startColor, _endColor],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
