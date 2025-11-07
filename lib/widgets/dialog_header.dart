import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../utils/pok.dart';
import '../../constants/theme2.dart';

class PolygonContainer extends StatelessWidget {
  final String text;

  const PolygonContainer({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeNotifier>(context).currentTheme;
    
    final TextPainter textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: GoogleFonts.robotoMono(
          fontSize: ThemeNotifier.small.responsiveSp,
        ),
      ),
      maxLines: 1,
      textDirection: TextDirection.ltr,
    )..layout();

    final double textWidth = textPainter.width;
    final double horizontalPadding = 12.w;  
    final double height = 40.h;
    final double slope = height; 
    
    final double totalWidth = textWidth + (horizontalPadding * 2) + slope;

    return CustomPaint(
      painter: PolygonPainter(
        fillColor: Colors.transparent,
        borderColor: Color(0xFF676c6f),
        borderWidth: 1.5,
        slope: slope,
      ),
      child: Container(
        width: totalWidth,
        height: height,
        alignment: Alignment.centerLeft,
        padding: EdgeInsets.only(left: horizontalPadding, right: horizontalPadding),
        child: Text(
          text,
          style: GoogleFonts.robotoMono(
            fontSize: ThemeNotifier.small.responsiveSp,
            color: theme.basicAdvanceTextColor,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}

class PolygonPainter extends CustomPainter {
  final Color fillColor;
  final Color borderColor;
  final double borderWidth;
  final double slope;
  
  PolygonPainter({
    required this.fillColor,
    required this.borderColor,
    required this.borderWidth,
    required this.slope,
  });
  
  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(size.width, 0) 
      ..lineTo(size.width - slope, size.height) 
      ..lineTo(0, size.height);

    final fillPaint = Paint()
      ..color = fillColor
      ..style = PaintingStyle.fill;
    canvas.drawPath(path, fillPaint);
    
    final borderPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidth;
    canvas.drawPath(path, borderPaint);
  }
  
  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
