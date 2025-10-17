import 'package:flutter_screenutil/flutter_screenutil.dart';

extension CustomScreenUtil on num {
  double get minSp {
    return (this * (ScreenUtil().scaleWidth < ScreenUtil().scaleHeight
        ? ScreenUtil().scaleWidth
        : ScreenUtil().scaleHeight)).toDouble();
  }
}
