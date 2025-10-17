import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:watermeter2/utils/pok.dart';

import '../constants/theme2.dart';
class ToggleButtonCustom extends StatefulWidget {
  List<String> tabs;
  Function onTap;
  Color? backgroundColor;
  Color selectedTextColor;
  Color unselectedTextColor;
  double width;
  double height;
  double smallerWidth;
  double smallerHeight;
  double verticalGap;
  double leftGap;
  double? fontSize;
  Color tabColor;
  int index;
  Color tabColor2;
  bool dontChangeImmediately;

  ToggleButtonCustom({
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
      // width: 244.w,
      // height: 50.91.h,
      child: Stack(
        children: [
          SizedBox(
            width: widget.width.w,
            height: widget.height.h,
            child: Image.asset(
              widget.backgroundColor == null
                  ? "assets/images/basic_advance.png"
                  : "assets/icons/togglebg.png",
              fit: BoxFit.fill,
              color: widget.backgroundColor,
            ),
          ),
          AnimatedPositioned(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            left: selectedIndex * (widget.smallerWidth.w) + widget.leftGap.w,
            // Adjust for gap
            top: widget.verticalGap.h,
            // Adjust for vertical gap
            child: SizedBox(
              width: widget.smallerWidth.w,
              height: widget.smallerHeight.h,
              child: Image.asset(
                getColor(selectedIndex) == CommonColors.red
                    ? "assets/images/red_calibrate.png"
                    : "assets/images/basic_advance2.png",
                fit: BoxFit.fill,
                width: widget.smallerWidth.w,
                height: widget.smallerHeight.h,
                color: getColor(selectedIndex) == CommonColors.red
                    ? null
                    : getColor(selectedIndex),
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
                            (widget.fontSize ?? ThemeNotifier.small).minSp,
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
