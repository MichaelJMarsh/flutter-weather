import 'package:flutter/animation.dart';

/// A class that provides entrance animations for widgets.
abstract class EntranceAnimations {
  /// Creates a new [EntranceAnimations].
  const EntranceAnimations({required AnimationController controller})
    : _controller = controller;

  /// The controller which manages the entrance animations.
  final AnimationController _controller;

  /// Returns a [CurvedAnimation] with an [Interval] between [begin] and [end],
  /// using the [curve] (defaults to [Curves.fastOutSlowIn]).
  Animation<double> curvedAnimation(
    double begin,
    double end, {
    Curve curve = Curves.fastOutSlowIn,
  }) {
    return CurvedAnimation(
      parent: _controller,
      curve: Interval(begin, end, curve: curve),
    );
  }
}
