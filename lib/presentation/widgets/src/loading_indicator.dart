import 'package:flutter/material.dart';

/// A widget that displays a circular loading indicator.
class LoadingIndicator extends StatelessWidget {
  /// Creates a new [LoadingIndicator].
  const LoadingIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return const CircularProgressIndicator(
      strokeCap: StrokeCap.round,
      strokeWidth: 8,
    );
  }
}
