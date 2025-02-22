import 'dart:ui';

import 'package:domain/domain.dart';
import 'package:share_plus/share_plus.dart' as package;

/// An implementation of [Share] that uses the `share_plus` package.
class SharePlugin implements Share {
  /// Creates a new [SharePlugin].
  const SharePlugin({required ShareDelegate delegate}) : _delegate = delegate;

  final ShareDelegate _delegate;

  @override
  Future<bool> send({
    final String? subject,
    final String? message,
    required Rect? sharePositionOrigin,
    required String content,
  }) async {
    var defaultContentFormat = content;

    if (message != null) {
      defaultContentFormat = '$message\n\n$content';
    }

    final result = await _delegate.share(
      defaultContentFormat,
      subject: subject,
      sharePositionOrigin: sharePositionOrigin,
    );

    if (result.status != package.ShareResultStatus.unavailable) {
      return true;
    }

    return false;
  }
}

/// A delegate that wraps `share_plus` for ease of testing.
class ShareDelegate {
  /// Shares content using the platform's share sheet.
  Future<package.ShareResult> share(
    String text, {
    String? subject,
    Rect? sharePositionOrigin,
  }) {
    return package.Share.share(
      text,
      subject: subject,
      sharePositionOrigin: sharePositionOrigin,
    );
  }
}
