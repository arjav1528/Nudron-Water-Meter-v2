import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/theme2.dart';

class ToggleButtonCustom extends StatefulWidget {
  final double width;
  final double height;
  final List<String> tabs;
  final Function(int) onTap;
  final int index;
  final Color? backgroundColor;
  final Color selectedTextColor;
  final Color unselectedTextColor;
  final Color tabColor;
  final Color tabColor2;
  final bool fillBackground;
  final bool dontChangeImmediately;
  final double? fontSize;
  final FontWeight? fontWeight;
  final String? fontFamily;

  const ToggleButtonCustom({
    super.key,
    required this.width,
    required this.height,
    required this.tabs,
    required this.onTap,
    this.index = 0,
    this.backgroundColor,
    required this.selectedTextColor,
    required this.unselectedTextColor,
    this.tabColor = CommonColors.blue,
    this.tabColor2 = CommonColors.blue,
    this.fillBackground = false,
    this.dontChangeImmediately = false,
    this.fontSize,
    this.fontWeight,
    this.fontFamily,
  });

  @override
  State<ToggleButtonCustom> createState() => _ToggleButtonCustomState();
}

class _ToggleButtonCustomState extends State<ToggleButtonCustom> {
  late int _selectedIndex;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.index;
  }

  @override
  void didUpdateWidget(covariant ToggleButtonCustom oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.index != oldWidget.index) {
      _selectedIndex = widget.index;
    }
  }

  void _handleTap(int index) {
    widget.onTap(index);
    if (!widget.dontChangeImmediately) {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Slant should be barely visible. A very small factor will achieve this.
    // Previous was 0.12. Reducing significantly to make it "barely appear" but still exist.
    final double arrowWidth = widget.height * 0.07; 
    final double fontSize = widget.fontSize ?? widget.height * 0.45; // Font size relative to height or custom
    final FontWeight fontWeight = widget.fontWeight ?? FontWeight.w500;
    final String fontFamily = widget.fontFamily ?? GoogleFonts.robotoMono().fontFamily ?? 'Roboto Mono';

    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: Stack(
        children: [
          // Background Frame
          CustomPaint(
            size: Size(widget.width, widget.height),
            painter: _ToggleShapePainter(
              color: widget.backgroundColor ?? const Color(0xff434343),
              isFilled: widget.fillBackground,
              arrowWidth: arrowWidth,
            ),
          ),

          // Animated Indicator - perfectly centered vertically using top and bottom constraints
          AnimatedPositioned(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            left: _selectedIndex == 0 
                ? widget.height * 0.1  // Left side: padding from left edge
                : widget.width / 2, // Right side: start at midpoint
            top: widget.height * 0.1, // Top padding
            bottom: widget.height * 0.1, // Bottom padding - ensures perfect vertical centering
            child: LayoutBuilder(
              builder: (context, constraints) {
                // Use the constrained height from top/bottom for perfect centering
                return CustomPaint(
                  size: Size(
                    (widget.width / 2) - (widget.height * 0.1), 
                    constraints.maxHeight // Use the height from constraints (top/bottom)
                  ),
                  painter: _ToggleShapePainter(
                    color: _selectedIndex == 0 ? widget.tabColor : widget.tabColor2,
                    isFilled: true,
                    arrowWidth: arrowWidth,
                  ),
                );
              },
            ),
          ),

          // Text Labels
          Row(
            children: List.generate(widget.tabs.length, (index) {
              return Expanded(
                child: GestureDetector(
                  onTap: () => _handleTap(index),
                  behavior: HitTestBehavior.translucent,
                  child: Center(
                    child: Text(
                      widget.tabs[index],
                      style: TextStyle(
                        fontSize: fontSize,
                        fontWeight: fontWeight,
                        fontFamily: fontFamily,
                        color: _selectedIndex == index
                            ? widget.selectedTextColor
                            : widget.unselectedTextColor,
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

class _ToggleShapePainter extends CustomPainter {
  final Color color;
  final bool isFilled;
  final double arrowWidth;

  _ToggleShapePainter({
    required this.color,
    required this.isFilled,
    required this.arrowWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = isFilled ? PaintingStyle.fill : PaintingStyle.stroke
      ..strokeWidth = isFilled ? 0 : 2.0;

    final path = Path();
    
    // Pointed ends shape (< >)
    path.moveTo(arrowWidth, 0);
    path.lineTo(size.width - arrowWidth, 0);
    path.lineTo(size.width, size.height / 2);
    path.lineTo(size.width - arrowWidth, size.height);
    path.lineTo(arrowWidth, size.height);
    path.lineTo(0, size.height / 2);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _ToggleShapePainter oldDelegate) {
    return color != oldDelegate.color ||
        isFilled != oldDelegate.isFilled ||
        arrowWidth != oldDelegate.arrowWidth;
  }
}
