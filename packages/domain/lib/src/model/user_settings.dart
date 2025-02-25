import 'temperature_unit.dart';
import 'theme_mode.dart';
import 'time_format.dart';

/// The user settings for the app.
class UserSettings {
  /// Creates a new [UserSettings].
  const UserSettings({
    required this.themeMode,
    required this.timeFormat,
    required this.temperatureUnit,
  });

  /// The selected theme mode for the app.
  final ThemeMode themeMode;

  /// The selected time format for the app.
  final TimeFormat timeFormat;

  /// The selected temperature unit for the app.
  final TemperatureUnit temperatureUnit;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is UserSettings &&
        other.runtimeType == runtimeType &&
        other.themeMode == themeMode &&
        other.timeFormat == timeFormat &&
        other.temperatureUnit == temperatureUnit;
  }

  @override
  int get hashCode {
    return runtimeType.hashCode ^
        themeMode.hashCode ^
        timeFormat.hashCode ^
        temperatureUnit.hashCode;
  }
}
