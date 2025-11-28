import 'package:flutter/material.dart';

import 'package:google_fonts/google_fonts.dart';
import 'package:watermeter2/utils/pok.dart';

import 'package:watermeter2/constants/ui_config.dart';

class ChamferedTextWidgetInverted extends StatelessWidget {
  final String text;
  final Color borderColor;
  final Color fillColor;
  final Color bgColor;
  final double? fontSize;

  const ChamferedTextWidgetInverted({super.key, 
    required this.text,
    required this.borderColor,
    this.bgColor = Colors.transparent,
    this.fillColor = Colors.transparent,
    this.fontSize,
  });

  @override
  Widget build(BuildContext context) {
    return ChamferedTextWidget(
      text: text,
      borderColor: borderColor,
      isInverted: true,
      bgColor: bgColor,
      fillColor: fillColor,
      fontSize: fontSize,
    );

  }
}

class InvertedChamferedLinePainter extends CustomPainter {
  final Color borderColor;
  final Color fillColor;

  InvertedChamferedLinePainter(
      {required this.borderColor, required this.fillColor});

  @override
  void paint(Canvas canvas, Size size) {
    
    final fillPaint = Paint()
      ..color = fillColor
      ..style = PaintingStyle.fill;

    final borderPaint = Paint()
      ..color = borderColor
      ..strokeWidth = UIConfig.dialogBorderWidth
      ..style = PaintingStyle.stroke;

    final fillPath = Path();
    fillPath.moveTo(0, 0);
    fillPath.lineTo(0, size.height);
    fillPath.lineTo(size.width-size.height, size.height);
    fillPath.lineTo(size.width, 0);

    final borderPath = Path();
    borderPath.moveTo(0, size.height);
    borderPath.lineTo(size.width-size.height, size.height);
    borderPath.lineTo(size.width, 0);

    canvas.drawPath(fillPath, fillPaint);

    canvas.drawPath(borderPath, borderPaint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}

class ChamferedTextWidget extends StatelessWidget {
  final String text;
  final Color borderColor;
  final Color fillColor;
  final Color bgColor;
  final Color? textColor;
  final bool isInverted;
  final double? fontSize;

  const ChamferedTextWidget(
      {super.key, required this.text,
      required this.borderColor,
      required this.bgColor,
        this.isInverted = false,
      this.fillColor = Colors.transparent,
      this.textColor,
      this.fontSize});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double height =
            UIConfig.getResponsiveWidth(context, scaleFactor: 0.095);
        final double triangleSize = height;
        final double leftPadding = UIConfig.tableTextWidthPaddingSmall + 8.responsiveSp;
        
        final textStyle = GoogleFonts.roboto(
          textStyle: TextStyle(
            fontSize: fontSize ?? UIConfig.fontSizeMediumResponsive,
            fontWeight: FontWeight.bold,
            color: textColor ?? borderColor,
          ),
        );
        
        final textPainter = TextPainter(
          text: TextSpan(text: text, style: textStyle),
          textDirection: TextDirection.ltr,
          maxLines: 1,
        );
        textPainter.layout(maxWidth: double.infinity);
        final textWidth = textPainter.size.width;
        
        final double buffer = 8.0;
        final double totalWidth = textWidth + leftPadding + triangleSize + buffer;

        return Transform(
          alignment: Alignment.center,
          transform:isInverted? (Matrix4.identity()..scale(-1.0, 1.0, 1.0)):Matrix4.identity(),
          child: RotatedBox(
            quarterTurns: isInverted ? 2 : 0,
            child: SizedBox(
              width: totalWidth,
              height: height,
              child: CustomPaint(
                size: Size(totalWidth, height),
                painter: ChamferedLinePainter(
                  isInverted: isInverted,
                    borderColor: borderColor, fillColor: bgColor),
                child: Container(
                  width: double.infinity,
                  height: height,
                  padding: EdgeInsets.only(
                      right: triangleSize),
                  child: Transform(
                    alignment: Alignment.center,
                    transform:isInverted? (Matrix4.identity()..scale(-1.0, 1.0, 1.0)):Matrix4.identity(),
                    child: RotatedBox(
                      quarterTurns: isInverted ? 2 : 0,
                      child: Center(
                        child: Text(
                          text,
                          style: textStyle,
                          overflow: TextOverflow.visible,
                          softWrap: false,
                          maxLines: 1,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class ChamferedLinePainter extends CustomPainter {
  final Color borderColor;
  final Color fillColor;
  final bool isInverted;

  ChamferedLinePainter({required this.borderColor, required this.fillColor,
  this.isInverted = false
  });

  @override
  void paint(Canvas canvas, Size size) {
    
    final fillPaint = Paint()
      ..color = fillColor
      ..style = PaintingStyle.fill;

    final borderPaint = Paint()
      ..color = borderColor
      ..strokeWidth = UIConfig.dialogBorderWidth
      ..style = PaintingStyle.stroke;

    final fillPath = Path();

    fillPath.moveTo(UIConfig.dialogBorderWidth * 0.5, size.height);
    fillPath.lineTo(UIConfig.dialogBorderWidth * 0.5, 0);
    fillPath.lineTo(size.width - size.height, 0);
    fillPath.lineTo(size.width, size.height);
    fillPath.close();

    final borderPath = Path();
    if(!isInverted) {
      borderPath.moveTo(UIConfig.dialogBorderWidth * 0.5, size.height);
      borderPath.lineTo(UIConfig.dialogBorderWidth * 0.5, 0);
    }
    borderPath.lineTo(size.width - size.height, 0);
    borderPath.lineTo(size.width, size.height+UIConfig.dialogBorderWidth * 0.5);

    canvas.drawPath(fillPath, fillPaint);

    canvas.drawPath(borderPath, borderPaint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}