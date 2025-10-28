import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../utils/pok.dart';
import '../../api/data_service.dart';

import '../../constants/theme2.dart';

class HeaderWidget extends StatelessWidget {
  final String title;

  const HeaderWidget({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 4.w),
      child: title[0] != '!'
          ? Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.robotoMono(
                fontSize: ThemeNotifier.medium.responsiveSp,
                fontWeight: FontWeight.bold,
                color: Provider.of<ThemeNotifier>(context)
                    .currentTheme
                    .gridHeadingColor,
                height: 1.5,
                // Adjusting line height for consistency
                letterSpacing:
                    0.5, // Ensure this matches any spacing used in your Text widget
              ),
            )
          : CustomIconButton(
              tooltipMessage: title[1] == 'A'
                  ? DataPostRequests.getIconNamesForAlerts(int.parse(title[3]))
                  : DataPostRequests.getIconNamesForStatus(int.parse(title[3])),
              iconAsset:
                  'assets/icons/${title[1].toLowerCase()}${title[3]}.svg',
              onTap: () {
                // Do something
              },
            ),
    );
  }
}

class CustomIconButton extends StatelessWidget {
  final String tooltipMessage;
  final String iconAsset;
  final VoidCallback onTap;

  // Static variable to keep track of the active overlay across instances
  static OverlayEntry? _currentOverlayEntry;

  const CustomIconButton({
    super.key,
    required this.tooltipMessage,
    required this.iconAsset,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          _showCustomTooltip(context);
          onTap();
        },
        splashColor: Provider.of<ThemeNotifier>(context, listen: false)
            .currentTheme
            .splashColor,
        highlightColor: Provider.of<ThemeNotifier>(context, listen: false)
            .currentTheme
            .splashColor,
        child: Container(
          // Remove fixed height to allow it to expand to fill the parent container
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(2.responsiveSp),
          ),
          // Center the icon within the full cell area
          alignment: Alignment.center,
          child: SvgPicture.asset(
            iconAsset,
            width: 25.responsiveSp,
            height: 25.responsiveSp,
            color: Provider.of<ThemeNotifier>(context, listen: false)
                .currentTheme
                .gridHeadingColor,
            semanticsLabel: 'Icon',
          ),
        ),
      ),
    );
  }

  void _showCustomTooltip(BuildContext context) {
    // Remove any existing tooltip before showing the new one
    _removeExistingTooltip();

    // Find the position of the icon on the screen
    final renderBox = context.findRenderObject() as RenderBox;
    final position = renderBox.localToGlobal(Offset.zero);

    // Calculate the width of the tooltip text
    final textPainter = TextPainter(
      text: TextSpan(
        text: tooltipMessage,
        style: GoogleFonts.robotoMono(
          fontSize: ThemeNotifier.medium.responsiveSp,
          color: Provider.of<ThemeNotifier>(context, listen: false)
              .currentTheme
              .gridHeadingColor,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    final tooltipWidth = textPainter.width;
    final screenWidth = MediaQuery.of(context).size.width;

    // Calculate the horizontal offset for the tooltip
    double halfTooltipWidth = tooltipWidth / 2;
    double fullTooltipWidth = tooltipWidth;

    // Calculate the start point for the tooltip
    double leftOffset = position.dx - halfTooltipWidth;
    leftOffset = leftOffset < 0
        ? 8.0
        : leftOffset; // Ensure it doesn't go off the left edge

    // Adjust if it goes beyond the screen width
    if (leftOffset + fullTooltipWidth + 25.responsiveSp > screenWidth) {
      leftOffset = screenWidth - fullTooltipWidth - 25.responsiveSp;
    }

    // Create and insert the new overlay
    final overlay = Overlay.of(context);
    _currentOverlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: position.dy + 40.h, // Adjust this value as needed
        left: leftOffset,
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: Provider.of<ThemeNotifier>(context).currentTheme.dialogBG,
              borderRadius: BorderRadius.circular(4.0),
            ),
            child: Text(
              tooltipMessage,
              style: GoogleFonts.robotoMono(
                fontSize: ThemeNotifier.medium.responsiveSp,
                color: Provider.of<ThemeNotifier>(context)
                    .currentTheme
                    .gridHeadingColor,
              ),
            ),
          ),
        ),
      ),
    );

    overlay.insert(_currentOverlayEntry!);

    Future.delayed(const Duration(seconds: 2), () {
      _removeExistingTooltip();
    });
  }

  static void _removeExistingTooltip() {
    // If there is a current overlay, remove it
    if (_currentOverlayEntry != null) {
      _currentOverlayEntry!.remove();
      _currentOverlayEntry = null;
    }
  }
}