import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:watermeter2/utils/pok.dart';

import '../constants/theme2.dart';

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
      padding: EdgeInsets.only(right: 8.w),
      
      child: Material(
        color: Colors.transparent,
        child: RawMaterialButton(
          onPressed: widget.onPressed,
          fillColor: widget.bgColor,
          splashColor: CommonColors.blue.withOpacity(0.25),
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          elevation: 0,
          padding: EdgeInsets.zero,
          constraints:
              BoxConstraints.tightFor(width: 30.responsiveSp, height: 30.responsiveSp),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(2.responsiveSp),
            side: BorderSide(
              color: Provider.of<ThemeNotifier>(context)
                  .currentTheme
                  .gridLineColor, 
              width: 1.responsiveSp, 
            ),
          ),
          child: Center(
            child: Icon(
              widget.iconData,
              size: 20.responsiveSp,
              color: Colors.white, 
            ),
          ),
        ),
      ),
    );
  }
}
