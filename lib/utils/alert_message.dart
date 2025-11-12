import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:watermeter2/main.dart';
import '../constants/ui_config.dart';

enum AlertType { success, error, warning, info }

class CustomAlert {
  static showCustomScaffoldMessenger(
      BuildContext context, String message, AlertType alertType,
      {Duration duration = const Duration(seconds: 2)}) {
    Color color = _alertColors[alertType]![0];
    Color colorAccent = _alertColors[alertType]![1];
    String alertName = _capitalize(alertType.toString().split('.').last);
    final messenger = scaffoldMessengerKey.currentState;
    if(messenger == null) return;
    
    // Hide any existing SnackBar to prevent Hero tag conflicts
    messenger.hideCurrentSnackBar();
    
    // Generate a unique key based on timestamp and message to ensure unique Hero tags
    final uniqueKey = ValueKey('${DateTime.now().millisecondsSinceEpoch}_$message');
    
    messenger.showSnackBar(
      SnackBar(
          key: uniqueKey,
          duration: duration,
          content: RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: '$alertName! ',
                  style: GoogleFonts.roboto(
                      fontSize: UIConfig.fontSizeMediumResponsive,
                      fontWeight: UIConfig.fontWeightBold,
                      color: color),
                ),
                TextSpan(
                  text: message,
                  style: GoogleFonts.roboto(fontSize: UIConfig.fontSizeMediumResponsive, color: color),
                ),
              ],
            ),
          ),
          backgroundColor: colorAccent,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: UIConfig.borderRadiusCircularLarge,
          )),
    );
  }

  static Widget customAlertWidget(String message, AlertType alertType,
      {required BuildContext context}) {
    Color color = _alertColors[alertType]![0];
    Color colorAccent = _alertColors[alertType]![1];
    String alertName = _capitalize(alertType.toString().split('.').last);

    return Container(
      width: double.infinity,
      margin: UIConfig.paddingSmall,
      padding: UIConfig.paddingChartHorizontal,
      decoration: BoxDecoration(
        color: colorAccent,
        borderRadius: UIConfig.borderRadiusCircularLarge,
      ),
      child: RichText(
        text: TextSpan(
          children: [
            TextSpan(
              text: '$alertName! ',
              style: GoogleFonts.roboto(
                  fontSize: UIConfig.fontSizeMediumResponsive,
                  fontWeight: UIConfig.fontWeightBold,
                  color: color),
            ),
            TextSpan(
              text: message,
              style: GoogleFonts.roboto(fontSize: UIConfig.fontSizeMediumResponsive, color: color),
            ),
          ],
        ),
      ),
    );
  }

  static String _capitalize(String text) {
    if (text.isEmpty) {
      return text;
    } else {
      return text[0].toUpperCase() + text.substring(1);
    }
  }

  static final Map<AlertType, List<Color>> _alertColors = {
    AlertType.success: [const Color(0xFF0b5b6a), const Color(0xFFd1e7dd)],
    AlertType.error: [const Color(0xFF992837), const Color(0xFFf8d7da)],
    AlertType.warning: [const Color(0xFF694d03), const Color(0xFFfff3cd)],
    AlertType.info: [const Color(0xFF075165), const Color(0xFFcff4fc)],
  };
}
