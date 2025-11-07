import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/foundation.dart';

extension CustomScreenUtil on num {
  double get minSp {
    return (this * (ScreenUtil().scaleWidth < ScreenUtil().scaleHeight
        ? ScreenUtil().scaleWidth
        : ScreenUtil().scaleHeight)).toDouble();
  }
  
  double get responsiveSp {
    double baseSize = (this * (ScreenUtil().scaleWidth < ScreenUtil().scaleHeight
        ? ScreenUtil().scaleWidth
        : ScreenUtil().scaleHeight)).toDouble();
    
    if (kIsWeb || defaultTargetPlatform == TargetPlatform.windows || 
        defaultTargetPlatform == TargetPlatform.macOS || 
        defaultTargetPlatform == TargetPlatform.linux) {
      
      return (baseSize * 1.2).toDouble();
    }
    
    return baseSize;
  }
}
