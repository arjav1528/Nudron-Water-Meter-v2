import 'dart:convert';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:watermeter2/utils/pok.dart';

import '../../constants/theme2.dart';
import '../../utils/alert_message.dart';

class AuthenticatorPage extends StatefulWidget {
  AuthenticatorPage({super.key, required this.image, required this.url});
  String image;
  String url;

  @override
  State<AuthenticatorPage> createState() => _AuthenticatorPageState();
}

class _AuthenticatorPageState extends State<AuthenticatorPage> {
  void launchAuthenticatorApp() async {
    Uri uri = Uri.parse(utf8.decode(base64Decode(widget.url)));
    
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.platformDefault);
    } else {
      throw 'Could not launch $uri';
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      double width = constraints.maxWidth;
      return Column(
        children: [
           SizedBox(height: 10.h),
          
          Align(
            alignment: Alignment.center,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Image.memory(
                base64Decode(widget.image),
                width: width * 0.6,
                fit: BoxFit.cover,
              ),
            ),
          ),
          Align(
            alignment: Alignment.center,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'Scan the QR code with your Authenticator app',
                style: GoogleFonts.roboto(
                  fontSize: ThemeNotifier.small.responsiveSp,
                  color: Provider.of<ThemeNotifier>(context)
                      .currentTheme
                      .basicAdvanceTextColor,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          
           SizedBox(
            height: 10.h,
          ),
          RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              children: <TextSpan>[
                TextSpan(
                  text: 'Click here ',
                  style: GoogleFonts.roboto(
                    fontSize: ThemeNotifier.small.responsiveSp,
                    color: CommonColors.blue,
                    decoration: TextDecoration.underline,
                  ),
                  recognizer: TapGestureRecognizer()
                    ..onTap = () {
                      try {
                        launchAuthenticatorApp();
                      } catch (e) {

                        CustomAlert.showCustomScaffoldMessenger(
                   context,"Could not launch the default Authenticator app : $e", AlertType.error);

                      }
                    },
                ),
                TextSpan(
                  text: 'to open the default Authenticator app',
                  style: GoogleFonts.roboto(
                    fontSize: ThemeNotifier.medium.responsiveSp,
                    color: Provider.of<ThemeNotifier>(context)
                        .currentTheme
                        .basicAdvanceTextColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    });
  }
}
