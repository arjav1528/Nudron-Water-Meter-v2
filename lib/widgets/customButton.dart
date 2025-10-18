import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../utils/pok.dart';

import '../../constants/theme2.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final double? fontSize;
  final bool isRed;
  final double? width;
  final bool dynamicWidth;
  final bool isEnabled;
  bool arrowWidget = false;

  // final double horizontalPadding;

  CustomButton({
    super.key,
    required this.text,
    this.width,
    // this.horizontalPadding=35,
    this.fontSize,
    this.dynamicWidth = false,
    required this.onPressed,
    this.isRed = false,
    this.isEnabled = true,
    this.arrowWidget = false,
  });

  @override
  Widget build(BuildContext context) {
    final buttonColor = isEnabled 
        ? (isRed ? CommonColors.red : CommonColors.blue)
        : Colors.grey;
    final chamferHeight = (44.h) / 3;

    return ClipPath(
      clipper: ChamferClipper(chamferHeight: chamferHeight),
      child: Material(
        color: buttonColor,
        child: InkWell(
          onTap: isEnabled ? onPressed : null,
          splashColor: isEnabled ? Colors.white.withOpacity(0.2) : Colors.transparent,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                // color: Colors.green,
                height: 44.h,

                width: dynamicWidth ? null : (width ?? 112.w),
                child: Center(
                  child: Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: dynamicWidth ? 20.w : 0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          text,
                          maxLines: 1,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.robotoMono(
                            fontSize: (fontSize ?? ThemeNotifier.medium).responsiveSp,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        if (arrowWidget) ...[
                          SizedBox(width: 8.w),
                          Icon(
                            Icons.arrow_forward,
                            color: Colors.white,
                            size: (fontSize ?? ThemeNotifier.small).responsiveSp + 4,
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ChamferClipper extends CustomClipper<Path> {
  final double chamferHeight;

  ChamferClipper({required this.chamferHeight});

  @override
  Path getClip(Size size) {
    return Path()
      ..moveTo(0, 0)
      ..lineTo(size.width - chamferHeight, 0)
      ..lineTo(size.width, chamferHeight)
      ..lineTo(size.width, size.height)
      ..lineTo(chamferHeight, size.height)
      ..lineTo(0, size.height - chamferHeight)
      ..close();
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

class ChamferPainter extends CustomPainter {
  final Color buttonColor;
  final double chamferHeight;

  ChamferPainter({required this.buttonColor, required this.chamferHeight});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = buttonColor;

    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width - chamferHeight, 0)
      ..lineTo(size.width, chamferHeight)
      ..lineTo(size.width, size.height)
      ..lineTo(chamferHeight, size.height)
      ..lineTo(0, size.height - chamferHeight)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
