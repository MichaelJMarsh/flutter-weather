import 'package:domain/domain.dart';
import 'package:url_launcher/url_launcher.dart';

/// An implementation of [UrlLauncher] that uses the `url_launcher` package.
class UrlLauncherPlugin implements UrlLauncher {
  /// Creates a new [UrlLauncherPlugin].
  const UrlLauncherPlugin({required UrlLauncherDelegate delegate})
    : _delegate = delegate;

  final UrlLauncherDelegate _delegate;

  @override
  Future<bool> launch(String urlString) {
    return _delegate.launch(Uri.parse(urlString));
  }

  @override
  Future<bool> canLaunch(String urlString) {
    return _delegate.canLaunch(Uri.parse(urlString));
  }
}

/// A delegate that wraps `url_launcher` for ease of testing.
class UrlLauncherDelegate {
  /// Launches a URL using `url_launcher`.
  Future<bool> launch(Uri uri) => launchUrl(uri);

  /// Checks if a URL can be launched.
  Future<bool> canLaunch(Uri uri) => canLaunchUrl(uri);
}
