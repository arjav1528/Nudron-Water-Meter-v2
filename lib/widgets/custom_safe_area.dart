import 'package:flutter/material.dart';

/// Custom safe area widget that hides content:
/// - Above the camera (top safe area - notch/dynamic island)
/// - Below where the rounded border starts (bottom safe area - home indicator)
class CustomSafeArea extends StatelessWidget {
  final Widget child;
  final bool top;
  final bool bottom;
  final bool left;
  final bool right;
  final EdgeInsets minimum;

  const CustomSafeArea({
    super.key,
    required this.child,
    this.top = true,
    this.bottom = true,
    this.left = true,
    this.right = true,
    this.minimum = EdgeInsets.zero,
  });

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final padding = mediaQuery.padding;

    return child;

  }
}

