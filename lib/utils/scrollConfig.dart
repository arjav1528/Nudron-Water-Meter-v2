import 'package:flutter/material.dart';

class NoBounceScrollBehavior extends ScrollBehavior {
  @override
  Widget buildViewportChrome(
      BuildContext context, Widget child, AxisDirection axisDirection) {
    return child; // Removes the overscroll effect (e.g., glow or bounce)
  }

  @override
  ScrollPhysics getScrollPhysics(BuildContext context) {
    return const ClampingScrollPhysics(); // Prevents the bounce effect on iOS
  }
}


class BouncingScrollBehavior extends ScrollBehavior {
  @override
  ScrollPhysics getScrollPhysics(BuildContext context) {
    return BouncingScrollPhysics(); // Enable bouncing physics
  }
}
