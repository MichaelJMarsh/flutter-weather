import 'package:flutter/foundation.dart';

/// Represents geographical coordinates with latitude and longitude.
@immutable
class Coordinates {
  /// Creates a new [Coordinates] instance.
  const Coordinates({required this.latitude, required this.longitude});

  /// The latitude value.
  final double latitude;

  /// The longitude value.
  final double longitude;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Coordinates &&
        runtimeType == other.runtimeType &&
        latitude == other.latitude &&
        longitude == other.longitude;
  }

  @override
  int get hashCode {
    return runtimeType.hashCode ^ latitude.hashCode ^ longitude.hashCode;
  }

  @override
  String toString() {
    return 'Coordinates(latitude: $latitude, longitude: $longitude)';
  }
}
