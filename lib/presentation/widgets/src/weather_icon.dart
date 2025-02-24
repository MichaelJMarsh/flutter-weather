import 'package:flutter/widgets.dart';

/// A widget that displays a weather icon.
class WeatherIcon extends StatelessWidget {
  /// Creates a new [WeatherIcon].
  const WeatherIcon({super.key, required this.iconCode, required this.size});

  /// The data for the current weather icon.
  final String? iconCode;

  /// The size of the weather icon.
  final double size;

  /// A map of OpenWeather icon codes to corresponding weather emojis.
  static const _weatherEmojis = <String, String>{
    '01d': '☀️', // Clear sky (day)
    '01n': '🌙', // Clear sky (night)
    '02d': '🌤️', // Few clouds (day)
    '02n': '☁️', // Few clouds (night)
    '03d': '☁️', // Scattered clouds
    '03n': '☁️', // Scattered clouds
    '04d': '☁️', // Broken clouds
    '04n': '☁️', // Broken clouds
    '09d': '🌧️', // Shower rain
    '09n': '🌧️', // Shower rain
    '10d': '🌦️', // Rain (day)
    '10n': '🌧️', // Rain (night)
    '11d': '⛈️', // Thunderstorm
    '11n': '⛈️', // Thunderstorm
    '13d': '❄️', // Snow
    '13n': '❄️', // Snow
    '50d': '🌫️', // Mist
    '50n': '🌫️', // Mist
  };

  @override
  Widget build(BuildContext context) {
    final emoji = _weatherEmojis[iconCode] ?? '❓';

    return Text(emoji, style: TextStyle(fontSize: size));
  }
}
