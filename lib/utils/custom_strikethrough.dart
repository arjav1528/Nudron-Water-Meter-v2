import 'package:flutter/material.dart';

import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../constants/theme2.dart';
import '../constants/ui_config.dart';

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

    final textPainter = TextPainter(
      text: TextSpan(
        text: oldValue.toString(),
        style: GoogleFonts.robotoMono(
          fontSize: UIConfig.fontSizeMediumResponsive,
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
              fontSize: UIConfig.fontSizeMediumResponsive,
              color: CommonColors.red,
            ),
            children: <TextSpan>[
              const TextSpan(text: ' '),
              TextSpan(
                  text: newValue.toString(),
                  style: GoogleFonts.robotoMono(
                    fontSize: UIConfig.fontSizeMediumResponsive,
                    color:
                        (isPreviousChange != null && isPreviousChange == true)
                            ? const Color(0xff00bc8a)
                            : const Color(0xffe3b039),
                  )),
            ],
          ),
        ),
        Positioned(
          top: UIConfig.fontSizeMediumResponsive * 0.72, 
          left: UIConfig.scrollClampMin,
          child: Container(
            height: UIConfig.borderWidthMedium, 
            width: textWidth, 
            color: Provider.of<ThemeNotifier>(context).currentTheme.gridLineColor,
          ),
        ),
      ],
    );
  }
}
