import 'package:flutter/material.dart';

import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:watermeter2/utils/pok.dart';

import '../constants/theme2.dart';

class CustomStrikethrough extends StatelessWidget {
  const CustomStrikethrough({
    super.key,
    required this.oldValue,
    required this.newValue,
    this.isPreviousChange,
  });

  final String oldValue;
  final String newValue;
  final bool? isPreviousChange;

  @override
  Widget build(BuildContext context) {

    // Measure the width of the oldValue text
    final textPainter = TextPainter(
      text: TextSpan(
        text: oldValue.toString(),
        style: GoogleFonts.robotoMono(
          fontSize: ThemeNotifier.medium.minSp,
          color: CommonColors.red,
        ),
      ),
      maxLines: 1,
      textDirection: TextDirection.ltr,
    )..layout(minWidth: 0, maxWidth: double.infinity);

    final textWidth = textPainter.size.width;

    return Stack(
      children: [
        RichText(
          text: TextSpan(
            text: oldValue.toString(),
            style: GoogleFonts.robotoMono(
              fontSize: ThemeNotifier.medium.minSp,
              color: CommonColors.red,
            ),
            children: <TextSpan>[
              const TextSpan(text: ' '),
              TextSpan(
                  text: newValue.toString(),
                  style: GoogleFonts.robotoMono(
                    fontSize: ThemeNotifier.medium.minSp,
                    color:
                        (isPreviousChange != null && isPreviousChange == true)
                            ? const Color(0xff00bc8a)
                            : const Color(0xffe3b039),
                  )),
            ],
          ),
        ),
        Positioned(
          top: 13.minSp, // Adjust the position as needed
          left: 0,
          child: Container(
            height: 2, // Thickness of the strikethrough line
            width: textWidth, // Set the width to the measured text width
            color: Provider.of<ThemeNotifier>(context).currentTheme.gridLineColor,
          ),
        ),
      ],
    );
  }
}
