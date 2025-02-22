import 'dart:ui';

/// The interface for sharing content via the system's native share dialog.
abstract class Share {
  const Share._();

  /// Attempts to share the given [content] with the system's native share dialog.
  ///
  /// Wraps the platform's native share dialog. Can send a text and/or a URL.
  /// It uses the `ACTION_SEND` Intent on Android and `UIActivityViewController`
  /// on iOS.
  ///
  /// The optional [subject] parameter can be used to populate a subject if the
  /// user chooses to send an email.
  ///
  /// The optional [message] parameter can be used to populate text in the body of the
  /// shared [content]. This is displayed one line above the [content].
  Future<bool> send({
    final String? subject,
    final String? message,
    required String content,
    required Rect? sharePositionOrigin,
  });
}
