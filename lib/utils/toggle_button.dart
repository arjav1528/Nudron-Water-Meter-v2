import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:watermeter2/utils/pok.dart';

import '../constants/theme2.dart';
import '../constants/ui_config.dart';
import '../services/platform_utils.dart';









class ToggleButtonCustom extends StatefulWidget {
  
  final List<String> tabs;
  
  
  
  final Function(int) onTap;
  
  
  final Color? backgroundColor;
  
  
  final Color selectedTextColor;
  
  
  final Color unselectedTextColor;
  
  
  final double width;
  
  
  final double height;
  
  
  final double? fontSize;
  
  
  final Color tabColor;
  
  
  final Color tabColor2;
  
  
  final int index;
  
  
  
  final bool dontChangeImmediately;
  
  
  
  final bool fillBackground;

  
  
  
  
  final bool adjustDesktopPosition;

  const ToggleButtonCustom({
    super.key,
    required this.tabs,
    required this.onTap,
    required this.backgroundColor,
    required this.selectedTextColor,
    required this.unselectedTextColor,
    required this.width,
    required this.height,
    this.fontSize,
    this.tabColor = CommonColors.blue,
    this.tabColor2 = CommonColors.blue,
    this.index = 0,
    this.dontChangeImmediately = false,
    this.fillBackground = false,
    this.adjustDesktopPosition = false,
  });

  @override
  State<ToggleButtonCustom> createState() => _ToggleButtonCustomState();
}

class _ToggleButtonCustomState extends State<ToggleButtonCustom> {
  late int selectedIndex;

  @override
  void initState() {
    super.initState();
    selectedIndex = widget.index;
  }

  @override
  void didUpdateWidget(ToggleButtonCustom oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.index != oldWidget.index) {
      selectedIndex = widget.index;
    }
  }

  
  Color _getIndicatorColor(int index) {
    return index == 0 ? widget.tabColor : widget.tabColor2;
  }

  
  void _handleTabTap(int index) {
    widget.onTap(index);
    
    if (!widget.dontChangeImmediately) {
      setState(() {
        selectedIndex = index;
      });
    }
  }

  
  
  _ResponsiveDimensions _calculateDimensions() {
    final isMobile = PlatformUtils.isMobile;
    
    
    final baseVerticalGap = widget.height * 0.17;
    final baseHorizontalGap = widget.width * 0.025;
    
    
    
    final baseTabWidth = (widget.width / widget.tabs.length) - (baseHorizontalGap * 2);
    
    final baseTabHeight = widget.height - (baseVerticalGap * 2);
    
    
    final baseTabSectionWidth = widget.width / widget.tabs.length;
    
    
    final containerWidth = isMobile ? widget.width.w : widget.width;
    final containerHeight = isMobile ? widget.height.h : widget.height;
    final tabWidth = isMobile ? baseTabWidth.w : baseTabWidth;
    final tabHeight = isMobile ? baseTabHeight.h : baseTabHeight;
    final tabSectionWidth = isMobile ? baseTabSectionWidth.w : baseTabSectionWidth;
    final leftGap = isMobile ? baseHorizontalGap.w : baseHorizontalGap;
    final verticalGap = isMobile ? baseVerticalGap.h : baseVerticalGap;
    
    return _ResponsiveDimensions(
      containerWidth: containerWidth,
      containerHeight: containerHeight,
      tabWidth: tabWidth,
      tabHeight: tabHeight,
      tabSectionWidth: tabSectionWidth,
      leftGap: leftGap,
      rightGap: leftGap, 
      verticalGap: verticalGap,
    );
  }

  
  double _calculateFontSize() {
    final defaultSize = widget.fontSize ?? UIConfig.fontSizeSmall;
    
    
    return defaultSize.responsiveSp;
  }

  @override
  Widget build(BuildContext context) {
    final dimensions = _calculateDimensions();
    final fontSize = _calculateFontSize();
    final indicatorColor = _getIndicatorColor(selectedIndex);

    return SizedBox(
      width: dimensions.containerWidth,
      height: dimensions.containerHeight,
      child: Stack(
        children: [
          
          _buildOuterFrame(dimensions),
          
          
          _buildSelectionIndicator(dimensions, indicatorColor),
          
          
          _buildTabLabels(dimensions, fontSize),
        ],
      ),
    );
  }

  
  Widget _buildOuterFrame(_ResponsiveDimensions dimensions) {
    return CustomPaint(
      size: Size(dimensions.containerWidth, dimensions.containerHeight),
      painter: ToggleFramePainter(
        color: widget.backgroundColor,
        fillBackground: widget.fillBackground,
      ),
    );
  }

  
  Widget _buildSelectionIndicator(
    _ResponsiveDimensions dimensions,
    Color indicatorColor,
  ) {
    
    
    double indicatorLeft = selectedIndex * dimensions.tabSectionWidth + 
                          (dimensions.tabSectionWidth - dimensions.tabWidth) / 2;
    
    
    
    double adjustedTop = dimensions.verticalGap * 0.75;
    double adjustedHeight = dimensions.tabHeight;
    
    if (widget.adjustDesktopPosition) {
      final isMobile = PlatformUtils.isMobile;
      
      if (isMobile) {
        
        adjustedHeight = dimensions.tabHeight + 1;
        
        if (selectedIndex == 0) {
          
          adjustedTop = dimensions.verticalGap - 1.5;
          indicatorLeft = indicatorLeft;
        } else if (selectedIndex == 1) {
          
          adjustedTop = dimensions.verticalGap - 1.5;
          
        }
      } else {
        
        adjustedHeight = dimensions.tabHeight + 2;
        
        if (selectedIndex == 0) {
          
          adjustedTop = dimensions.verticalGap - 1.5;
          indicatorLeft = indicatorLeft;
        } else if (selectedIndex == 1) {
          
          adjustedTop = dimensions.verticalGap - 2;
          
        }
      }
    }

    return AnimatedPositioned(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      left: indicatorLeft,
      top: adjustedTop,
      child: _buildIndicatorContent(dimensions, indicatorColor, adjustedHeight),
    );
  }

  
  Widget _buildIndicatorContent(
    _ResponsiveDimensions dimensions,
    Color indicatorColor,
    double height,
  ) {
    
    return CustomPaint(
      size: Size(dimensions.tabWidth, height),
      painter: ToggleIndicatorPainter(color: indicatorColor),
    );
  }

  
  Widget _buildTabLabels(_ResponsiveDimensions dimensions, double fontSize) {
    return SizedBox(
      width: dimensions.containerWidth,
      height: dimensions.containerHeight,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(
          widget.tabs.length,
          (index) => _buildTabLabel(index, dimensions.tabSectionWidth, fontSize),
        ),
      ),
    );
  }

  
  Widget _buildTabLabel(int index, double tabSectionWidth, double fontSize) {
    final isSelected = selectedIndex == index;
    final textColor = isSelected
        ? widget.selectedTextColor
        : widget.unselectedTextColor;

    return GestureDetector(
      onTap: () => _handleTabTap(index),
      child: Container(
        color: Colors.transparent,
        width: tabSectionWidth,
        child: Center(
          child: Text(
            widget.tabs[index],
            style: GoogleFonts.robotoMono(
              color: textColor,
              fontSize: fontSize,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}


class _ResponsiveDimensions {
  final double containerWidth;
  final double containerHeight;
  final double tabWidth;
  final double tabHeight;
  final double tabSectionWidth;
  final double leftGap;
  final double rightGap;
  final double verticalGap;

  _ResponsiveDimensions({
    required this.containerWidth,
    required this.containerHeight,
    required this.tabWidth,
    required this.tabHeight,
    required this.tabSectionWidth,
    required this.leftGap,
    required this.rightGap,
    required this.verticalGap,
  });
}





class ToggleFramePainter extends CustomPainter {
  
  final Color? color;
  
  
  final bool fillBackground;

  const ToggleFramePainter({
    this.color,
    this.fillBackground = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final frameColor = color ?? const Color(0xff434343);
    
    if (fillBackground) {
      
      final outerPath = Path()
        ..moveTo(size.width * 0.9797321, 0)
        ..lineTo(size.width * 0.02027027, 0)
        ..lineTo(0, size.height * 0.4906263)
        ..lineTo(size.width * 0.02027027, size.height * 0.9812553)
        ..lineTo(size.width * 0.9797321, size.height * 0.9812553)
        ..lineTo(size.width, size.height * 0.4906263)
        ..lineTo(size.width * 0.9797321, 0)
        ..close();

      final fillPaint = Paint()
        ..style = PaintingStyle.fill
        ..color = frameColor.withOpacity(UIConfig.opacityFull);

      canvas.drawPath(outerPath, fillPaint);
    } else {
      
      final borderPath = Path()
        ..moveTo(size.width * 0.9797321, 0)
        ..lineTo(size.width * 0.02027027, 0)
        ..lineTo(0, size.height * 0.4906263)
        ..lineTo(size.width * 0.02027027, size.height * 0.9812553)
        ..lineTo(size.width * 0.9797321, size.height * 0.9812553)
        ..lineTo(size.width, size.height * 0.4906263)
        ..lineTo(size.width * 0.9797321, 0)
        ..close();

      final borderPaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = UIConfig.borderWidthThick
        ..color = frameColor.withOpacity(UIConfig.opacityFull);

      canvas.drawPath(borderPath, borderPaint);
    }
  }

  @override
  bool shouldRepaint(covariant ToggleFramePainter oldDelegate) {
    return color != oldDelegate.color || fillBackground != oldDelegate.fillBackground;
  }
}





class ToggleIndicatorPainter extends CustomPainter {
  
  final Color color;

  const ToggleIndicatorPainter({
    this.color = const Color(0xff145166),
  });

  @override
  void paint(Canvas canvas, Size size) {
    
    final bottomExtension = size.height * 0.1;
    final indicatorPath = Path()
      ..moveTo(size.width * 0.9754789, size.height + bottomExtension)
      ..lineTo(size.width, size.height * 0.5000000)
      ..lineTo(size.width * 0.9754789, 0)
      ..lineTo(size.width * 0.02452317, 0)
      ..lineTo(0, size.height * 0.5000000)
      ..lineTo(size.width * 0.02452317, size.height + bottomExtension)
      ..lineTo(size.width * 0.9754789, size.height + bottomExtension)
      ..close();

    final paint = Paint()
      ..style = PaintingStyle.fill
      ..color = color.withOpacity(1.0);

    canvas.drawPath(indicatorPath, paint);
  }

  @override
  bool shouldRepaint(covariant ToggleIndicatorPainter oldDelegate) {
    return color != oldDelegate.color;
  }
}
