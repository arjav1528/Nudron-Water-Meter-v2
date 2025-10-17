import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:watermeter2/main.dart';
import 'package:watermeter2/utils/pok.dart';

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
    messenger.showSnackBar(
      SnackBar(
          duration: duration,
          content: RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: '$alertName! ',
                  style: GoogleFonts.roboto(
                      fontSize: 18.minSp,
                      fontWeight: FontWeight.bold,
                      color: color),
                ),
                TextSpan(
                  text: message,
                  style: GoogleFonts.roboto(fontSize: 18.minSp, color: color),
                ),
              ],
            ),
          ),
          backgroundColor: colorAccent,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
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
      margin: const EdgeInsets.all(8.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: colorAccent,
        borderRadius: BorderRadius.circular(10),
      ),
      child: RichText(
        text: TextSpan(
          children: [
            TextSpan(
              text: '$alertName! ',
              style: GoogleFonts.roboto(
                  fontSize: 18.minSp,
                  fontWeight: FontWeight.bold,
                  color: color),
            ),
            TextSpan(
              text: message,
              style: GoogleFonts.roboto(fontSize: 18.minSp, color: color),
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
