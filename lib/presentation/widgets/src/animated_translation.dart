import 'package:flutter/widgets.dart';

/// A widget that animates its child by moving it vertically or horizontally
/// as it fades in or out.
class AnimatedTranslation extends StatelessWidget {
  const AnimatedTranslation._({
    super.key,
    required this.animation,
    this.pixels = 0,
    required this.axis,
    required this.child,
  });

  /// Create a [AnimatedTranslation] that moves the child vertically.
  factory AnimatedTranslation.vertical({
    final Key? key,
    required Animation<double> animation,
    required double pixels,
    required Widget child,
  }) {
    return AnimatedTranslation._(
      key: key,
      animation: animation,
      pixels: pixels,
      axis: Axis.vertical,
      child: child,
    );
  }

  /// Create a [AnimatedTranslation] that moves the child horizontally.
  factory AnimatedTranslation.horizontal({
    final Key? key,
    required Animation<double> animation,
    required double pixels,
    required Widget child,
  }) {
    return AnimatedTranslation._(
      key: key,
      animation: animation,
      pixels: pixels,
      axis: Axis.horizontal,
      child: child,
    );
  }

  /// The animation that controls the transition of the child.
  final Animation<double> animation;

  /// The number of pixels to move the child.
  final double pixels;

  /// The axis along which the child will be moved.
  final Axis axis;

  /// The widget that [AnimatedTranslation] animates.
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (_, animatedChild) {
        final animatedValue = pixels * (1 - animation.value);
        final translation =
            axis == Axis.vertical
                ? Offset(0, animatedValue)
                : Offset(animatedValue, 0);

        return Transform.translate(
          offset: translation,
          child: Opacity(opacity: animation.value, child: animatedChild),
        );
      },
      child: child,
    );
  }
}
