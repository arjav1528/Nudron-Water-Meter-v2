import 'package:flutter/material.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:watermeter2/utils/pok.dart';

import '../constants/theme2.dart';

class CustomTabBar extends StatefulWidget {
  final ValueNotifier<int> selectedIndex;
  final List<String> tabTitles;
  final Color selectedColor;
  final Color unselectedColor;
  final Color bgColor;
  final Color tabBgColor;

  const CustomTabBar(
      {super.key,
      required this.selectedIndex,
      required this.tabTitles,
      required this.selectedColor,
      required this.unselectedColor,
      required this.bgColor,
      required this.tabBgColor});

  @override
  _CustomTabBarState createState() => _CustomTabBarState();
}

class _CustomTabBarState extends State<CustomTabBar> {
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: widget.selectedIndex,
      builder: (context, selectedIndex, child) {
        return Container(
          height: 48.h,
          decoration: BoxDecoration(
            color: widget.bgColor,
            borderRadius: BorderRadius.circular(10.responsiveSp),
          ),
          child: Stack(
            children: [
              AnimatedAlign(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                alignment: Alignment(
                  (selectedIndex / (widget.tabTitles.length - 1)) * 2 - 1,
                  0,
                ),
                child: Container(
                  margin: const EdgeInsets.all(4),
                  // Adjust the padding between the red part and the indicator
                  width: (MediaQuery.of(context).size.width - 32) /
                          widget.tabTitles.length -
                      8,
                  height: 38.h,
                  decoration: BoxDecoration(
                    color: widget.tabBgColor, // Alternate shades of red
                    borderRadius: BorderRadius.circular(6.responsiveSp),
                  ),
                ),
              ),
              Row(
                children: List.generate(widget.tabTitles.length, (index) {
                  return Expanded(
                      child: InkWell(
                    onTap: () {
                      widget.selectedIndex.value = index;
                    },
                    child: Container(
                      alignment: Alignment.center,
                      child: Text(
                        widget.tabTitles[index],
                        style: GoogleFonts.robotoMono(
                          textStyle: TextStyle(
                            fontSize: ThemeNotifier.small.responsiveSp,
                            color: index == selectedIndex
                                ? widget.selectedColor
                                : widget.unselectedColor,
                          ),
                        ),
                      ),
                    ),
                  ));
                }),
              ),
            ],
          ),
        );
      },
    );
  }
}
