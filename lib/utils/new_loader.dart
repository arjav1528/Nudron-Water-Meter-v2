import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:watermeter2/utils/pok.dart';

import '../constants/theme2.dart';
class LoaderUtility {
  static Future<dynamic> showLoader(BuildContext context, Future futureFunction,
      {Color? color}) async {
    // Show the loader
    showDialog(
      context: context,
      barrierDismissible: false,
      // Prevents closing the dialog by tapping outside it
      builder: (BuildContext context) {
        return PopScope(
            canPop: false, // Prevents closing the dialog by back button
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
              child: Container(
                alignment: FractionalOffset.center,
                decoration: BoxDecoration(color: Colors.black.withOpacity(0.5)),
                // Semi-transparent background
                child: SizedBox(
                  width: 75.responsiveSp,
                  height: 75.responsiveSp,
                  child:LoadingAnimationWidget.hexagonDots(
                    size: 75.responsiveSp,
                    color: CommonColors.blue,
                  ),
                  // child: CircularProgressIndicator(
                  //   strokeWidth: 5,
                  //   valueColor:
                  //       AlwaysStoppedAnimation<Color>(color ?? Colors.blue),
                  // ),
                ),
              ),
            ));
      },
    );
    // Wait for the future to complete
    dynamic a;
    try {
      a = await futureFunction;
    } catch (e) {
      // Hide the loader
      Navigator.of(context, rootNavigator: true).pop('dialog');
      rethrow;
    }
    // Hide the loader
    Navigator.of(context, rootNavigator: true).pop('dialog');
    return a;
  }
}

