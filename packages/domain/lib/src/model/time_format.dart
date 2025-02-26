/// The format for the time display.
enum TimeFormat {
  twelveHour(displayText: '12-hour'),
  twentyFourHour(displayText: '24-hour');

  const TimeFormat({required this.displayText});

  /// The display text for the [TimeFormat].
  final String displayText;

  /// Returns the [TimeFormat] for the given [name].
  static TimeFormat fromName(String? name) {
    return values.firstWhere(
      (format) => format.name == name,
      orElse: () => TimeFormat.twentyFourHour,
    );
  }
}
