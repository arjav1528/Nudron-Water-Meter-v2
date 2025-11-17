import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:watermeter2/utils/pok.dart';

import '../constants/theme2.dart';
import '../constants/ui_config.dart';
import '../services/platform_utils.dart';

/// A custom toggle button widget with animated selection indicator.
/// 
/// Features:
/// - Custom painted frame and indicator with unique shapes
/// - Animated position transitions
/// - Support for multiple tabs
/// - Customizable colors, sizes, and fonts
/// - Platform-aware sizing (mobile/desktop)
class ToggleButtonCustom extends StatefulWidget {
  /// List of tab labels to display
  final List<String> tabs;
  
  /// Callback function called when a tab is tapped
  /// Receives the index of the tapped tab
  final Function(int) onTap;
  
  /// Background color of the outer frame
  final Color? backgroundColor;
  
  /// Text color for the selected tab
  final Color selectedTextColor;
  
  /// Text color for unselected tabs
  final Color unselectedTextColor;
  
  /// Total width of the toggle button
  final double width;
  
  /// Total height of the toggle button
  final double height;
  
  /// Width of each individual tab/indicator
  final double smallerWidth;
  
  /// Height of the selection indicator
  final double smallerHeight;
  
  /// Vertical gap (padding) from top/bottom edges
  final double verticalGap;
  
  /// Horizontal gap (padding) from left edge
  final double leftGap;
  
  /// Font size for tab text. If null, uses default from UIConfig
  final double? fontSize;
  
  /// Color for the selection indicator when first tab is selected
  final Color tabColor;
  
  /// Color for the selection indicator when second tab is selected
  final Color tabColor2;
  
  /// Initial selected tab index
  final int index;
  
  /// If true, the visual selection won't update immediately on tap
  /// Useful when you want to control the selection externally
  final bool dontChangeImmediately;
  
  /// If true, fills the background with the backgroundColor.
  /// If false, only draws a border outline (transparent background).
  final bool fillBackground;

  /// If true, applies platform-aware position adjustments for profile drawer.
  /// When NO (index 0): extends indicator downward slightly.
  /// When YES (index 1): moves indicator upward slightly.
  /// Adjustments are applied on both mobile and desktop platforms.
  final bool adjustDesktopPosition;

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

  /// Returns the appropriate color for the selection indicator based on tab index
  Color _getIndicatorColor(int index) {
    return index == 0 ? widget.tabColor : widget.tabColor2;
  }

  /// Handles tab tap and updates selection
  void _handleTabTap(int index) {
    widget.onTap(index);
    
    if (!widget.dontChangeImmediately) {
      setState(() {
        selectedIndex = index;
      });
    }
  }

  /// Calculates responsive dimensions based on platform
  _ResponsiveDimensions _calculateDimensions() {
    final isMobile = PlatformUtils.isMobile;
    final leftGap = isMobile ? widget.leftGap.w : widget.leftGap;
    // Make vertical gap equal to left gap for symmetry
    final verticalGap = leftGap;
    
    return _ResponsiveDimensions(
      containerWidth: isMobile ? widget.width.w : widget.width,
      containerHeight: isMobile ? widget.height.h : widget.height,
      tabWidth: isMobile ? widget.smallerWidth.w : widget.smallerWidth,
      tabHeight: isMobile ? widget.smallerHeight.h : widget.smallerHeight,
      leftGap: leftGap,
      rightGap: leftGap, // Right gap equals left gap
      verticalGap: verticalGap,
    );
  }

  /// Calculates the font size based on platform and widget settings
  double _calculateFontSize() {
    final defaultSize = widget.fontSize ?? UIConfig.fontSizeSmall;
    
    if (PlatformUtils.isMobile) {
      return defaultSize.responsiveSp;
    } else {
      // For desktop, use fontSize if provided and > 10, otherwise use responsive size
      return (widget.fontSize != null && widget.fontSize! > 10)
          ? widget.fontSize!
          : defaultSize.responsiveSp;
    }
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
          // Outer frame background
          _buildOuterFrame(dimensions),
          
          // Animated selection indicator
          _buildSelectionIndicator(dimensions, indicatorColor),
          
          // Tab text labels
          _buildTabLabels(dimensions, fontSize),
        ],
      ),
    );
  }

  /// Builds the outer frame using CustomPaint
  Widget _buildOuterFrame(_ResponsiveDimensions dimensions) {
    return CustomPaint(
      size: Size(dimensions.containerWidth, dimensions.containerHeight),
      painter: ToggleFramePainter(
        color: widget.backgroundColor,
        fillBackground: widget.fillBackground,
      ),
    );
  }

  /// Builds the animated selection indicator
  Widget _buildSelectionIndicator(
    _ResponsiveDimensions dimensions,
    Color indicatorColor,
  ) {
    double indicatorLeft = selectedIndex * dimensions.tabWidth + dimensions.leftGap;
    
    // Platform-aware adjustments for profile drawer
    double adjustedTop = dimensions.verticalGap;
    double adjustedHeight = dimensions.tabHeight;
    
    if (widget.adjustDesktopPosition) {
      final isMobile = PlatformUtils.isMobile;
      
      if (isMobile) {
        // Mobile-specific adjustments
        adjustedHeight = dimensions.tabHeight + 1;
        
        if (selectedIndex == 0) {
          // NO: move up by 1.h pixels to center it better, and move left to extreme
          adjustedTop = dimensions.verticalGap - 0.75 - 1.h;
          indicatorLeft = indicatorLeft - 1.h;
        } else if (selectedIndex == 1) {
          // YES: move upward slightly (reduced offset for mobile)
          adjustedTop = dimensions.verticalGap - 1.0;
        }
      } else {
        // Desktop-specific adjustments
        adjustedHeight = dimensions.tabHeight + 1;
        
        if (selectedIndex == 0) {
          // NO: extend downward slightly
          adjustedTop = dimensions.verticalGap - 0.75;
        } else if (selectedIndex == 1) {
          // YES: move upward slightly
          adjustedTop = dimensions.verticalGap - 1.5;
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

  /// Builds the indicator content (either image or custom paint)
  Widget _buildIndicatorContent(
    _ResponsiveDimensions dimensions,
    Color indicatorColor,
    double height,
  ) {
    // Use CustomPaint for all colors to ensure consistent appearance
    return CustomPaint(
      size: Size(dimensions.tabWidth, height),
      painter: ToggleIndicatorPainter(color: indicatorColor),
    );
  }

  /// Builds the tab text labels
  Widget _buildTabLabels(_ResponsiveDimensions dimensions, double fontSize) {
    return SizedBox(
      width: dimensions.containerWidth,
      height: dimensions.containerHeight,
      child: Center(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: List.generate(
            widget.tabs.length,
            (index) => _buildTabLabel(index, dimensions.tabWidth, fontSize),
          ),
        ),
      ),
    );
  }

  /// Builds a single tab label
  Widget _buildTabLabel(int index, double tabWidth, double fontSize) {
    final isSelected = selectedIndex == index;
    final textColor = isSelected
        ? widget.selectedTextColor
        : widget.unselectedTextColor;

    return GestureDetector(
      onTap: () => _handleTabTap(index),
      child: Container(
        color: Colors.transparent,
        width: tabWidth,
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

/// Helper class to hold responsive dimensions
class _ResponsiveDimensions {
  final double containerWidth;
  final double containerHeight;
  final double tabWidth;
  final double tabHeight;
  final double leftGap;
  final double rightGap;
  final double verticalGap;

  _ResponsiveDimensions({
    required this.containerWidth,
    required this.containerHeight,
    required this.tabWidth,
    required this.tabHeight,
    required this.leftGap,
    required this.rightGap,
    required this.verticalGap,
  });
}

/// Custom painter for the outer toggle frame
/// 
/// Creates a frame with wavy/scalloped edges on the left and right sides.
/// Can render as either a filled background or just a border outline.
class ToggleFramePainter extends CustomPainter {
  /// Color of the frame. If null, uses default dark teal color
  final Color? color;
  
  /// If true, fills the background. If false, only draws a border.
  final bool fillBackground;

  const ToggleFramePainter({
    this.color,
    this.fillBackground = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final frameColor = color ?? const Color(0xff434343);
    
    if (fillBackground) {
      // Draw filled background
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
      // Draw border only (transparent background)
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

/// Custom painter for the selection indicator
/// 
/// Creates a diamond/hexagon-shaped indicator that slides between tabs.
/// The shape has pointed edges on the left and right sides.
class ToggleIndicatorPainter extends CustomPainter {
  /// Color of the indicator
  final Color color;

  const ToggleIndicatorPainter({
    this.color = const Color(0xff145166),
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Extend bottom edge more (about 5% of height)
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
