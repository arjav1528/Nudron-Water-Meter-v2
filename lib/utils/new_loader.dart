import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import '../constants/theme2.dart';
import '../constants/ui_config.dart';
class LoaderUtility {
  static Future<dynamic> showLoader(BuildContext context, Future futureFunction,
      {Color? color}) async {
    
    showDialog(
      context: context,
      barrierDismissible: false,
      
      builder: (BuildContext context) {
        return PopScope(
            canPop: false, 
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: UIConfig.blurSigmaX, sigmaY: UIConfig.blurSigmaY),
              child: Container(
                alignment: FractionalOffset.center,
                decoration: BoxDecoration(color: Colors.black.withOpacity(UIConfig.opacityBackdrop)),
                
                child: SizedBox(
                  width: UIConfig.loaderSize,
                  height: UIConfig.loaderSize,
                  child:LoadingAnimationWidget.hexagonDots(
                    size: UIConfig.loaderSize,
                    color: CommonColors.blue,
                  ),
                  
                ),
              ),
            ));
      },
    );
    
    dynamic a;
    try {
      a = await futureFunction;
    } catch (e) {
      
      Navigator.of(context, rootNavigator: true).pop('dialog');
      rethrow;
    }
    
    Navigator.of(context, rootNavigator: true).pop('dialog');
    return a;
  }
}
