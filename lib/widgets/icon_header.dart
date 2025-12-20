import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../utils/pok.dart';
import '../../api/data_service.dart';

import '../../constants/theme2.dart';
import '../../constants/ui_config.dart';

class HeaderWidget extends StatelessWidget {
  final String title;
  final EdgeInsetsGeometry? padding;

  const HeaderWidget({
    super.key,
    required this.title,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding ?? EdgeInsets.symmetric(horizontal: 0),
      child: title[0] != '!'
          ? Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.robotoMono(
                // Use table header font size to match DataGridWidget calculations
                fontSize: UIConfig.fontSizeTableHeaderMobile,
                fontWeight: FontWeight.bold,
                color: Provider.of<ThemeNotifier>(context)
                    .currentTheme
                    .gridHeadingColor,
                height: UIConfig.lineHeight * 1.25,
                
                letterSpacing:
                    0.5, 
              ),
            )
          : CustomIconButton(
              tooltipMessage: title[1] == 'A'
                  ? DataPostRequests.getIconNamesForAlerts(int.parse(title[3]))
                  : DataPostRequests.getIconNamesForStatus(int.parse(title[3])),
              iconAsset:
                  'assets/icons/${title[1].toLowerCase()}${title[3]}.svg',
              onTap: () {
                
              },
            ),
    );
  }
}

class CustomIconButton extends StatelessWidget {
  final String tooltipMessage;
  final String iconAsset;
  final VoidCallback onTap;

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
          padding: EdgeInsets.symmetric(horizontal: 0.w, vertical: 0.h),
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(UIConfig.spacingXSmall),
          ),
          
          alignment: Alignment.center,
          child: SvgPicture.asset(
            iconAsset,
            width: UIConfig.iconSizeMedium,
            height: UIConfig.iconSizeMedium,
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
    
    _removeExistingTooltip();

    final renderBox = context.findRenderObject() as RenderBox;
    final position = renderBox.localToGlobal(Offset.zero);

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

    double halfTooltipWidth = tooltipWidth / 2;
    double fullTooltipWidth = tooltipWidth;

    double leftOffset = position.dx - halfTooltipWidth;
    leftOffset = leftOffset < 0
        ? UIConfig.spacingSmall
        : leftOffset; 
    
    if (leftOffset + fullTooltipWidth + UIConfig.iconSizeMedium > screenWidth) {
      leftOffset = screenWidth - fullTooltipWidth - UIConfig.iconSizeMedium;
    }

    final overlay = Overlay.of(context);
    _currentOverlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: position.dy + UIConfig.spacingXXXLarge, 
        left: leftOffset,
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: UIConfig.paddingSmall,
            decoration: BoxDecoration(
              color: Provider.of<ThemeNotifier>(context).currentTheme.dialogBG,
              borderRadius: BorderRadius.circular(UIConfig.spacingXSmall),
            ),
            child: Text(
              tooltipMessage,
              style: GoogleFonts.robotoMono(
                fontSize: UIConfig.fontSizeMediumResponsive,
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
    
    if (_currentOverlayEntry != null) {
      _currentOverlayEntry!.remove();
      _currentOverlayEntry = null;
    }
  }
}
