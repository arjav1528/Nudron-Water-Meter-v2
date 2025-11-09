import 'package:flutter/material.dart';
import '../constants/ui_config.dart';

class WifiAnimation extends StatelessWidget {
  const WifiAnimation({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
        child: Image.asset('assets/images/1fqC.gif',
            color: UIConfig.accentColorBlue, width: UIConfig.wifiAnimationSize, height: UIConfig.wifiAnimationSize));
  }
}
