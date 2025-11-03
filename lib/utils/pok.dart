import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/foundation.dart';

extension CustomScreenUtil on num {
  double get minSp {
    return (this * (ScreenUtil().scaleWidth < ScreenUtil().scaleHeight
        ? ScreenUtil().scaleWidth
        : ScreenUtil().scaleHeight)).toDouble();
  }
  
  /// Responsive font size that increases for desktop while keeping mobile unchanged
  double get responsiveSp {
    double baseSize = (this * (ScreenUtil().scaleWidth < ScreenUtil().scaleHeight
        ? ScreenUtil().scaleWidth
        : ScreenUtil().scaleHeight)).toDouble();
    
    // Check if running on desktop/web platform
    if (kIsWeb || defaultTargetPlatform == TargetPlatform.windows || 
        defaultTargetPlatform == TargetPlatform.macOS || 
        defaultTargetPlatform == TargetPlatform.linux) {
      // Increase font size by 20% for desktop
      return (baseSize * 1.2).toDouble();
    }
    
    return baseSize;
  }
}
