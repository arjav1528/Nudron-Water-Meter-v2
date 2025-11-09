import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:provider/provider.dart';
import '../constants/theme2.dart';
import '../constants/ui_config.dart';

class CustomLoader extends StatefulWidget {
  const CustomLoader({super.key});

  @override
  State<CustomLoader> createState() => _CustomLoaderState();
}

class _CustomLoaderState extends State<CustomLoader> {
  
  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      backgroundColor: Provider.of<ThemeNotifier>(context).currentTheme.bgColor,
      body: Center(
        child: SizedBox(
          height: UIConfig.loaderSize,
          width: UIConfig.loaderSize,
          child:LoadingAnimationWidget.hexagonDots(
            size: UIConfig.loaderSize,
            color: CommonColors.blue,
          ),
          
        ),
      ),
    );
  }
}
