/// The interface for fetching the current app version.
abstract class AppVersion {
  const AppVersion._();

  /// Returns the current app version as a formatted string.
  String get currentVersion;

  /// Fetches the current app version and stores it in [currentVersion].
  Future<void> getAppVersion();
}
