import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:provider/provider.dart';
import 'package:watermeter2/utils/pok.dart';

import '../constants/theme2.dart';

class CustomLoader extends StatefulWidget {
  const CustomLoader({super.key});

  @override
  State<CustomLoader> createState() => _CustomLoaderState();
}

class _CustomLoaderState extends State<CustomLoader> {
  // @override
  // void initState() {
  //   timer = Timer(const Duration(seconds: 30), () {
  //     setState(() {
  //       isError = true;
  //     });
  //   });
  //
  //   super.initState();
  // }
  //
  // @override
  // void dispose() {
  //   timer.cancel();
  //   super.dispose();
  // }

  @override
  Widget build(BuildContext context) {
    return  SafeArea(
      child: Scaffold(
        backgroundColor: Provider.of<ThemeNotifier>(context).currentTheme.bgColor,
        body: Center(
          child: SizedBox(
            height: 75.responsiveSp,
            width: 75.responsiveSp,
            child:LoadingAnimationWidget.hexagonDots(
              size: 75.responsiveSp,
              color: CommonColors.blue,
            ),
            // child: CircularProgressIndicator(
            //   strokeWidth: 5,
            //   valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
            // ),
          ),
        ),
      ),
    );
  }
}
