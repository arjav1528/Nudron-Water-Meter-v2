import 'package:flutter/material.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/ui_config.dart';

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
          height: UIConfig.iconContainerHeight + 18.h,
          decoration: BoxDecoration(
            color: widget.bgColor,
            borderRadius: UIConfig.borderRadiusCircularLarge,
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
                  margin: EdgeInsets.all(UIConfig.spacingXSmall),
                  
                  width: (MediaQuery.of(context).size.width - UIConfig.spacingLarge * 2) /
                          widget.tabTitles.length -
                      UIConfig.spacingSmall,
                  height: UIConfig.iconContainerHeight + 8.h,
                  decoration: BoxDecoration(
                    color: widget.tabBgColor, 
                    borderRadius: BorderRadius.circular(UIConfig.spacingXSmall * 1.5),
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
                            fontSize: UIConfig.fontSizeSmallResponsive,
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
