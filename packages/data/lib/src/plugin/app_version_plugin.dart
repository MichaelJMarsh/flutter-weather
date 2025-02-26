import 'package:domain/domain.dart';
import 'package:package_info_plus/package_info_plus.dart';

/// An implementation of [AppVersionService] that uses [AppVersionDelegate].
class AppVersionPlugin implements AppVersion {
  /// Creates a new [AppVersionPlugin].
  AppVersionPlugin({required AppVersionDelegate delegate})
      : _delegate = delegate;

  final AppVersionDelegate _delegate;

  @override
  String get currentVersion => _currentVersion;
  String _currentVersion = '';

  @override
  Future<void> getAppVersion() async {
    final packageInfo = await _delegate.getPackageInfo();

    _currentVersion = '${packageInfo.version} (${packageInfo.buildNumber})';
  }
}

/// A delegate that wraps package_info_plus for retrieving package info.
class AppVersionDelegate {
  /// Retrieves the package information using package_info_plus.
  Future<PackageInfo> getPackageInfo() {
    return PackageInfo.fromPlatform();
  }
}
