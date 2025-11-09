import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../constants/theme2.dart';
import '../constants/ui_config.dart';

class SmallButton extends StatefulWidget {
  const SmallButton({
    super.key,
    required this.onPressed,
    required this.iconData,
    required this.bgColor,
  });

  final Function() onPressed;
  final IconData iconData;
  final Color bgColor;

  @override
  State<SmallButton> createState() => _SmallButtonState();
}

class _SmallButtonState extends State<SmallButton> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(right: UIConfig.spacingSmall.w),
      
      child: Material(
        color: Colors.transparent,
        child: RawMaterialButton(
          onPressed: widget.onPressed,
          fillColor: widget.bgColor,
          splashColor: UIConfig.accentColorBlue.withOpacity(UIConfig.opacityMedium),
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          elevation: UIConfig.dialogElevation,
          padding: EdgeInsets.zero,
          constraints:
              BoxConstraints.tightFor(width: UIConfig.iconSizeLarge, height: UIConfig.iconSizeLarge),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(UIConfig.spacingXSmall * 0.5),
            side: BorderSide(
              color: Provider.of<ThemeNotifier>(context)
                  .currentTheme
                  .gridLineColor, 
              width: UIConfig.borderWidthThin, 
            ),
          ),
          child: Center(
            child: Icon(
              widget.iconData,
              size: UIConfig.fontSizeSmallResponsive + UIConfig.spacingXSmall,
              color: UIConfig.colorWhite, 
            ),
          ),
        ),
      ),
    );
  }
}
