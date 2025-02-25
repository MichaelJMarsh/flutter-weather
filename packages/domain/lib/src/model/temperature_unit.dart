/// The unit for the temperature display.
enum TemperatureUnit {
  celsius(displayText: 'Celcius (C°)'),
  fahrenheit(displayText: 'Farhenheit (F°)');

  const TemperatureUnit({required this.displayText});

  /// The display text for the [TemperatureUnit].
  final String displayText;

  /// Returns the [TemperatureUnit] for the given [name].
  static TemperatureUnit fromName(String? name) {
    return values.firstWhere(
      (unit) => unit.name == name,
      orElse: () => TemperatureUnit.celsius,
    );
  }
}
