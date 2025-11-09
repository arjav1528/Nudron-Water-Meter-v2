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
      ..strokeWidth = UIConfig.tableBorderWidth
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
        final double height = UIConfig.iconSizeLarge + 15.responsiveSp;
        final double triangleSize = height;

        return Transform(
          alignment: Alignment.center,
          transform:isInverted? (Matrix4.identity()..scale(-1.0, 1.0, 1.0)):Matrix4.identity(),
          child: RotatedBox(
            quarterTurns: isInverted ? 2 : 0,
            child: SizedBox(
              height: height,
              child: CustomPaint(
                size: Size(triangleSize, height),
                painter: ChamferedLinePainter(
                  isInverted: isInverted,
                    borderColor: borderColor, fillColor: bgColor),
                child: Container(
                  height: height,
                  padding: EdgeInsets.only(
                      right: triangleSize, top: isInverted?0:UIConfig.spacingXSmall * 1.25.responsiveSp,bottom: isInverted?UIConfig.spacingXSmall * 1.5.responsiveSp:0, left: UIConfig.tableTextWidthPaddingSmall + 8.responsiveSp),
                  child: Transform(
                    alignment: Alignment.center,
                    transform:isInverted? (Matrix4.identity()..scale(-1.0, 1.0, 1.0)):Matrix4.identity(),
                    child: RotatedBox(
                      quarterTurns: isInverted ? 2 : 0,
                      child: Padding(
                        padding: EdgeInsets.only(top: UIConfig.spacingXSmall),
                        child: Text(
                          text,
                          
                          style: GoogleFonts.roboto(
                            textStyle: TextStyle(
                              fontSize: fontSize ?? UIConfig.fontSizeMediumResponsive,
                              fontWeight: FontWeight.bold,
                              color: textColor ?? borderColor,
                            ),
                          ),
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
      ..strokeWidth = UIConfig.tableBorderWidth
      ..style = PaintingStyle.stroke;

    final fillPath = Path();

    fillPath.moveTo(UIConfig.tableBorderWidth * 0.5, size.height);
    fillPath.lineTo(UIConfig.tableBorderWidth * 0.5, 0);
    fillPath.lineTo(size.width - size.height, 0);
    fillPath.lineTo(size.width, size.height);
    fillPath.close();

    final borderPath = Path();
    if(!isInverted) {
      borderPath.moveTo(UIConfig.tableBorderWidth * 0.5, size.height);
      borderPath.lineTo(UIConfig.tableBorderWidth * 0.5, 0);
    }
    borderPath.lineTo(size.width - size.height, 0);
    borderPath.lineTo(size.width, size.height+UIConfig.tableBorderWidth * 0.5);

    canvas.drawPath(fillPath, fillPaint);

    canvas.drawPath(borderPath, borderPaint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}