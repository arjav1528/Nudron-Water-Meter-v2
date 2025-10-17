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
    return  Scaffold(
      backgroundColor: Provider.of<ThemeNotifier>(context).currentTheme.bgColor,
      body: Center(
        child: SizedBox(
          height: 75.minSp,
          width: 75.minSp,
          child:LoadingAnimationWidget.hexagonDots(
            size: 75.minSp,
            color: CommonColors.blue,
          ),
          // child: CircularProgressIndicator(
          //   strokeWidth: 5,
          //   valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
          // ),
        ),
      ),
    );
  }
}
