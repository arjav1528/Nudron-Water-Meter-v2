import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:google_fonts/google_fonts.dart';
import 'package:watermeter2/utils/pok.dart';

import 'package:watermeter2/constants/theme2.dart';

class ChamferedTextWidgetInverted extends StatelessWidget {
  final String text;
  final Color borderColor;
  final Color fillColor;
  final Color bgColor;

  const ChamferedTextWidgetInverted({super.key, 
    required this.text,
    required this.borderColor,
    this.bgColor = Colors.transparent,
    this.fillColor = Colors.transparent,
  });

  @override
  Widget build(BuildContext context) {
    return ChamferedTextWidget(
      text: text,
      borderColor: borderColor,
      isInverted: true,
      bgColor: bgColor,
      fillColor: fillColor,
    );

    // return LayoutBuilder(
    //   builder: (context, constraints) {
    //     final double height = 45.minSp;
    //     final double triangleSize = height;
    //
    //     return Container(
    //       height: height,
    //       // color: Colors.green,
    //       child: CustomPaint(
    //         child: Container(
    //           height: height,
    //           padding: EdgeInsets.only(
    //               right: triangleSize,
    //               top: 8.h,
    //               bottom: 8.h,
    //               left: 14.minSp),
    //           child: Text(
    //             text,
    //             style: GoogleFonts.roboto(
    //               textStyle: TextStyle(
    //                 fontSize: ThemeNotifier.medium.minSp,
    //                 fontWeight: FontWeight.bold,
    //                 color: borderColor,
    //               ),
    //             ),
    //           ),
    //         ),
    //         size: Size(triangleSize, height),
    //         painter: InvertedChamferedLinePainter(
    //             borderColor: borderColor, fillColor: bgColor),
    //       ),
    //     );
    //   },
    // );
  }
}

class InvertedChamferedLinePainter extends CustomPainter {
  final Color borderColor;
  final Color fillColor;

  InvertedChamferedLinePainter(
      {required this.borderColor, required this.fillColor});

  @override
  void paint(Canvas canvas, Size size) {
    // Paint for the fill color
    final fillPaint = Paint()
      ..color = fillColor
      ..style = PaintingStyle.fill;

    // Paint for the border color
    final borderPaint = Paint()
      ..color = borderColor
      ..strokeWidth = 3.minSp
      ..style = PaintingStyle.stroke;

    // Path for the filled area
    final fillPath = Path();
    fillPath.moveTo(0, 0);
    fillPath.lineTo(0, size.height);
    fillPath.lineTo(size.width-size.height, size.height);
    fillPath.lineTo(size.width, 0);

    // Path for the border
    final borderPath = Path();
    borderPath.moveTo(0, size.height);
    borderPath.lineTo(size.width-size.height, size.height);
    borderPath.lineTo(size.width, 0);


    // Draw the filled area
    canvas.drawPath(fillPath, fillPaint);

    // Draw the border on top
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

  const ChamferedTextWidget(
      {super.key, required this.text,
      required this.borderColor,
      required this.bgColor,
        this.isInverted = false,
      this.fillColor = Colors.transparent,
      this.textColor});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double height = 45.minSp;
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
                      right: triangleSize, top: isInverted?0:10.minSp,bottom: isInverted?6.minSp:0, left: 14.minSp),
                  child: Transform(
                    alignment: Alignment.center,
                    transform:isInverted? (Matrix4.identity()..scale(-1.0, 1.0, 1.0)):Matrix4.identity(),
                    child: RotatedBox(
                      quarterTurns: isInverted ? 2 : 0,
                      child: Text(
                        text,
                        // textAlign: TextAlign.center,
                        style: GoogleFonts.roboto(
                          textStyle: TextStyle(
                            fontSize: ThemeNotifier.medium.minSp,
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
    // Paint for the fill color
    final fillPaint = Paint()
      ..color = fillColor
      ..style = PaintingStyle.fill;

    // Paint for the border color
    final borderPaint = Paint()
      ..color = borderColor
      ..strokeWidth = 3.minSp
      ..style = PaintingStyle.stroke;

    // Path for the filled area
    final fillPath = Path();

    fillPath.moveTo(1.5.minSp, size.height);
    fillPath.lineTo(1.5.minSp, 0);
    fillPath.lineTo(size.width - size.height, 0);
    fillPath.lineTo(size.width, size.height);
    fillPath.close();

    // Path for the border
    final borderPath = Path();
    if(!isInverted) {
      borderPath.moveTo(1.5.minSp, size.height);
      borderPath.lineTo(1.5.minSp, 0);
    }
    borderPath.lineTo(size.width - size.height, 0);
    borderPath.lineTo(size.width, size.height+1.5.minSp);

    // Draw the filled area
    canvas.drawPath(fillPath, fillPaint);

    // Draw the border on top
    canvas.drawPath(borderPath, borderPaint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}