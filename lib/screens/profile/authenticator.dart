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
    // Uri uri2= Uri.parse("otpauth://totp/Nudron:wefwfewfew@gmail.com?secret=sdvsdvsdvw&issuer=dvvv");
    // await launch(utf8.decode(base64Decode(widget.url)));
    //
    // Uri uri2= Uri.parse("https://www.google.com");
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
          // const Padding(
          //   padding: EdgeInsets.all(8.0),
          //   child: Text(
          //     'Set up Authenticator',
          //     style: TextStyle(fontSize: 25),
          //     textAlign: TextAlign.center,
          //   ),
          // ),
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
          // const Align(
          //   alignment: Alignment.center,
          //   child: Padding(
          //     padding: EdgeInsets.all(8.0),
          //     child: Text(
          //       'Press cancel to set up later',
          //       style: TextStyle(fontSize: 15, color: Colors.grey),
          //       textAlign: TextAlign.center,
          //     ),
          //   ),
          // ),
          //next and cancel buttons
          // Padding(
          //   padding: const EdgeInsets.all(8.0),
          //   child: Row(
          //     mainAxisAlignment: MainAxisAlignment.end,
          //     children: [
          //       SizedBox(
          //         width: 71.13,
          //         height: 30.78,
          //         child: ElevatedButton(
          //           style: ElevatedButton.styleFrom(
          //               elevation: 0,
          //               primary: const Color(0xff2186a9),
          //               padding: EdgeInsets.zero),
          //           onPressed: () async {
          //             widget.closeFunction(true);
          //           },
          //           child: const Text(
          //             "Proceed",
          //             style: TextStyle(
          //                 fontFamily: 'Roboto',
          //                 color: Color(0xffffffff),
          //                 fontSize: 12.8),
          //           ),
          //         ),
          //       ),
          //       const SizedBox(
          //         width: 10,
          //       ),
          //       SizedBox(
          //         width: 71.13,
          //         height: 30.78,
          //         child: ElevatedButton(
          //           style: ElevatedButton.styleFrom(
          //               elevation: 0,
          //               primary: const Color(0xffff5b5b),
          //               padding: EdgeInsets.zero),
          //           onPressed: () async {
          //             try {
          //               await LoginViewModel.disableTwoFactorAuth();
          //               widget.closeFunction(false);
          //             } catch (e) {
          //               ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          //                   content: Text("Could not disable 2FA : $e")));
          //               widget.closeFunction(true);
          //             }
          //           },
          //           child: const Text(
          //             "Cancel",
          //             style: TextStyle(
          //                 fontFamily: 'Roboto',
          //                 color: Color(0xffffffff),
          //                 fontSize: 12.8),
          //           ),
          //         ),
          //       ),
          //     ],
          //   ),
          // ),
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
