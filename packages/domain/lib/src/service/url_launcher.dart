/// The interface for launching URLs via the system's native URL launcher.
abstract class UrlLauncher {
  const UrlLauncher._();

  /// Checks if the URL can be launched.
  Future<bool> canLaunch(String url);

  /// Launches the given [url].
  Future<bool> launch(String url);
}
