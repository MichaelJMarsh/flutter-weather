import 'package:flutter/material.dart';

import 'package:cached_network_image/cached_network_image.dart';

/// A widget that displays a weather icon.
class WeatherIcon extends StatelessWidget {
  /// Creates a new [WeatherIcon].
  const WeatherIcon({super.key, required this.iconCode, required this.size});

  /// The data for the current weather icon.
  final String? iconCode;

  /// The size of the weather icon.
  final double size;

  @override
  Widget build(BuildContext context) {
    final imageUrl = 'https://openweathermap.org/img/wn/$iconCode@2x.png';

    return CachedNetworkImage(
      imageUrl: imageUrl,
      width: size,
      height: size,
      placeholder: (_, __) {
        return SizedBox.square(
          dimension: size,
          child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
        );
      },
      errorWidget: (_, __, ___) => Icon(Icons.cloud, size: size),
    );
  }
}
