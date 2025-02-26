import 'temperature_unit.dart';
import 'theme_mode.dart';
import 'time_format.dart';

/// The user settings for the app.
class UserSettings {
  /// Creates a new [UserSettings].
  const UserSettings({
    this.themeMode = ThemeMode.system,
    this.timeFormat = TimeFormat.twentyFourHour,
    this.temperatureUnit = TemperatureUnit.celsius,
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

  @override
  String toString() {
    return '''UserSettings{
    themeMode: $themeMode, 
    timeFormat: $timeFormat, 
    temperatureUnit: $temperatureUnit
    }''';
  }

  /// Creates a copy of this [UserSettings] but with the given fields replaced
  /// with the new values.
  UserSettings copyWith({
    ThemeMode? themeMode,
    TimeFormat? timeFormat,
    TemperatureUnit? temperatureUnit,
  }) {
    return UserSettings(
      themeMode: themeMode ?? this.themeMode,
      timeFormat: timeFormat ?? this.timeFormat,
      temperatureUnit: temperatureUnit ?? this.temperatureUnit,
    );
  }
}
