import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:watermeter2/utils/pok.dart';

import '../constants/theme2.dart';
class ToggleButtonCustom extends StatefulWidget {
  final List<String> tabs;
  final Function onTap;
  final Color? backgroundColor;
  final Color selectedTextColor;
  final Color unselectedTextColor;
  final double width;
  final double height;
  final double smallerWidth;
  final double smallerHeight;
  final double verticalGap;
  final double leftGap;
  final double? fontSize;
  final Color tabColor;
  final int index;
  final Color tabColor2;
  final bool dontChangeImmediately;

  const ToggleButtonCustom({
    super.key,
    required this.tabs,
    required this.onTap,
    required this.backgroundColor,
    required this.selectedTextColor,
    required this.unselectedTextColor,
    this.width = 244,
    this.height = 50.91,
    this.smallerWidth = 116,
    this.smallerHeight = 35,
    this.verticalGap = 8,
    this.leftGap = 6,
    this.fontSize,
    this.tabColor = CommonColors.blue,
    this.index = 0,
    this.tabColor2 = CommonColors.blue,
    this.dontChangeImmediately = false,
  });

  @override
  State<ToggleButtonCustom> createState() => _ToggleButtonCustomState();
}

class _ToggleButtonCustomState extends State<ToggleButtonCustom> {
  int selectedIndex = 0;

  @override
  void initState() {
    selectedIndex = widget.index;
    super.initState();
  }

  Color getColor(int index) {
    if (0 == index) {
      return widget.tabColor;
    } else {
      return widget.tabColor2;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.width.w,
      height: widget.height.h,
      
      child: Stack(
        children: [
          widget.backgroundColor == null
              ? CustomPaint(
                  size: Size(widget.width.w, widget.height.h),
                  painter: RPSCustomPainter(),
                )
              : SizedBox(
                  width: widget.width.w,
                  height: widget.height.h,
                  child: Image.asset(
                    "assets/icons/togglebg.png",
                    fit: BoxFit.fill,
                    color: widget.backgroundColor,
                  ),
                ),
          AnimatedPositioned(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            left: selectedIndex * (widget.smallerWidth.w) + widget.leftGap.w,
            
            top: widget.verticalGap.h,
            
            child: getColor(selectedIndex) == CommonColors.red
                ? SizedBox(
                    width: widget.smallerWidth.w,
                    height: widget.smallerHeight.h,
                    child: Image.asset(
                      "assets/images/red_calibrate.png",
                      fit: BoxFit.fill,
                      width: widget.smallerWidth.w,
                      height: widget.smallerHeight.h,
                    ),
                  )
                : CustomPaint(
                    size: Size(widget.smallerWidth.w, widget.smallerHeight.h),
                    painter: RPSCustomPainter2(
                      color: getColor(selectedIndex),
                    ),
                  ),
          ),
          SizedBox(
            width: widget.width.w,
            height: widget.height.h,
            child: Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: List.generate(
                  widget.tabs.length,
                      (index) => GestureDetector(
                    onTap: () {
                      widget.onTap(index);
                      if (widget.dontChangeImmediately == false) {
                        setState(() {
                          selectedIndex = index;
                        });
                      }
                    },
                    child: Container(
                      color: Colors.transparent,
                      width: widget.smallerWidth.w,
                      child: Center(
                        child: Text(
                          widget.tabs[index],
                          style: GoogleFonts.robotoMono(
                            color: selectedIndex == index
                                ? widget.selectedTextColor
                                : widget.unselectedTextColor,
                            fontSize:
                            (widget.fontSize ?? ThemeNotifier.small).responsiveSp,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class RPSCustomPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    Path path_0 = Path();
    path_0.moveTo(size.width * 0.9797295, 0);
    path_0.lineTo(size.width * 0.02027029, 0);
    path_0.lineTo(0, size.height * 0.4991373);
    path_0.lineTo(size.width * 0.02027029, size.height * 0.9982745);
    path_0.lineTo(size.width * 0.9797295, size.height * 0.9982745);
    path_0.lineTo(size.width, size.height * 0.4991373);
    path_0.lineTo(size.width * 0.9797295, 0);
    path_0.close();
    path_0.moveTo(size.width * 0.9767254, size.height * 0.9223196);
    path_0.lineTo(size.width * 0.02327328, size.height * 0.9223196);
    path_0.lineTo(size.width * 0.006756762, size.height * 0.4991373);
    path_0.lineTo(size.width * 0.02327328, size.height * 0.07595529);
    path_0.lineTo(size.width * 0.9767254, size.height * 0.07595529);
    path_0.lineTo(size.width * 0.9932418, size.height * 0.4991373);
    path_0.lineTo(size.width * 0.9767254, size.height * 0.9223196);
    path_0.close();

    Paint paint_0_fill = Paint()..style = PaintingStyle.fill;
    paint_0_fill.color = Color(0xff145166).withOpacity(1.0);
    canvas.drawPath(path_0, paint_0_fill);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

class RPSCustomPainter2 extends CustomPainter {
  final Color color;

  RPSCustomPainter2({this.color = const Color(0xff145166)});

  @override
  void paint(Canvas canvas, Size size) {
    Path path_0 = Path();
    path_0.moveTo(size.width * 0.9754789, size.height);
    path_0.lineTo(size.width, size.height * 0.5000000);
    path_0.lineTo(size.width * 0.9754789, 0);
    path_0.lineTo(size.width * 0.02452317, 0);
    path_0.lineTo(0, size.height * 0.5000000);
    path_0.lineTo(size.width * 0.02452317, size.height);
    path_0.lineTo(size.width * 0.9754789, size.height);
    path_0.close();

    Paint paint_0_fill = Paint()..style = PaintingStyle.fill;
    paint_0_fill.color = color.withOpacity(1.0);
    canvas.drawPath(path_0, paint_0_fill);
  }

  @override
  bool shouldRepaint(covariant RPSCustomPainter2 oldDelegate) {
    return color != oldDelegate.color;
  }
}
