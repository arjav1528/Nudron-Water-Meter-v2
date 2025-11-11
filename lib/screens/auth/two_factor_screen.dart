import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:provider/provider.dart';
import 'package:sms_autofill/sms_autofill.dart';
import 'package:watermeter2/utils/pok.dart';

import '../../api/auth_service.dart';
import '../../constants/theme2.dart';
import '../../constants/ui_config.dart';
import '../../utils/alert_message.dart';
import '../../utils/new_loader.dart';
import '../../widgets/customButton.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/custom_safe_area.dart';

class EnterTwoFacCode extends StatefulWidget {
  EnterTwoFacCode({super.key, required this.referenceCode});

  String referenceCode;

  @override
  State<EnterTwoFacCode> createState() => _EnterTwoFacCodeState();
}

class _EnterTwoFacCodeState extends State<EnterTwoFacCode> with CodeAutoFill {
  TextEditingController otpFieldController = TextEditingController();

  printdevicehash() async {
    await SmsAutoFill().getAppSignature;
  }

  @override
  void initState() {
    printdevicehash();
    listenForCode();

    SystemChrome.setPreferredOrientations(
        [DeviceOrientation.portraitDown, DeviceOrientation.portraitUp]);
    
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        backgroundColor:
            Provider.of<ThemeNotifier>(context).currentTheme.bgColor,
        appBar: CustomAppBar(choiceAction: null),
        body: CustomSafeArea(
          child: Column(
            children: [
              Container(
                height: 3.h,
                color: CommonColors.blue,
              ),
              Expanded(
                child: SingleChildScrollView(
                child: Center(
                  child: Column(
                    children: [
                      Align(
                        alignment: Alignment.topLeft,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            IconButton(
                              icon: Transform.scale(
                                scaleX: -1,
                                child: Icon(
                                  Icons.arrow_right_alt,
                                  color: Provider.of<ThemeNotifier>(context)
                                      .currentTheme
                                      .basicAdvanceTextColor),
                                ),
                              
                              onPressed: () => Navigator.of(context).pop(),
                            ),
                            SizedBox(width: 10.w),
                            Text(
                              "TWO-FACTOR AUTHENTICATION",
                              style: GoogleFonts.robotoMono(
                                color: Provider.of<ThemeNotifier>(context)
                                    .currentTheme
                                    .basicAdvanceTextColor,
                                fontSize: UIConfig.fontSizeLargeResponsive + 4.responsiveSp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 24.w),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            SizedBox(height: 40.h),
                            SvgPicture.asset(
                              'assets/images/2falogo.svg',
                              width: min(width / 2.5, height / 2.5),
                              color: CommonColors.blue,
                            ),
                            SizedBox(height: 40.h),
                            Text(
                              "PLEASE ENTER THE CODE SENT TO YOUR\nAUTHENTICATOR APP/SMS",
                              textAlign: TextAlign.center,
                              style: GoogleFonts.robotoMono(
                                color: Provider.of<ThemeNotifier>(context)
                                    .currentTheme
                                    .basicAdvanceTextColor,
                                fontSize: UIConfig.fontSizeSmallResponsive,
                              ),
                            ),
                            SizedBox(height: 25.h),
                            PinCodeTextField(
                              
                              length: 6,
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                              ],
                              keyboardType: const TextInputType.numberWithOptions(
                                  decimal: true),
                              cursorColor: Provider.of<ThemeNotifier>(context)
                                  .currentTheme
                                  .basicAdvanceTextColor,
                              obscureText: false,
                              animationType: AnimationType.fade,
                              textStyle: GoogleFonts.roboto(
                                color: Provider.of<ThemeNotifier>(context)
                                    .currentTheme
                                    .basicAdvanceTextColor,
                                fontSize: UIConfig.fontSizeMediumResponsive,
                                fontWeight: FontWeight.w400,
                              ),
                              pinTheme: PinTheme(
                                shape: PinCodeFieldShape.underline,
                                borderRadius: BorderRadius.circular(5.r),
                                fieldHeight: 50.h,
                                fieldWidth: 40.w,

                                activeFillColor: Provider.of<ThemeNotifier>(context)
                                    .currentTheme
                                    .basicAdvanceTextColor,
                                activeColor: CommonColors.blue,
                                selectedColor: CommonColors.blue,
                                inactiveColor: Provider.of<ThemeNotifier>(context)
                                    .currentTheme
                                    .basicAdvanceTextColor,
                                
                                selectedFillColor:
                                    Provider.of<ThemeNotifier>(context)
                                        .currentTheme
                                        .bgColor,
                              ),
                              animationDuration: const Duration(milliseconds: 300),
                              backgroundColor: Provider.of<ThemeNotifier>(context)
                                  .currentTheme
                                  .bgColor,
                              controller: otpFieldController,
                              enablePinAutofill: true,
                              onCompleted: (v) {
                                if (kDebugMode) {
                                }
                              },
                              beforeTextPaste: (text) {
                                
                                return true;
                              },
                              appContext: context,
                              onChanged: (String value) {},
                            ),
                            SizedBox(height: 40.h),
                            SizedBox(
                              
                              child: CustomButton(
                                text: "VERIFY",
                                onPressed: () async {
                                  if (otpFieldController.text.length == 6) {
                                    LoaderUtility.showLoader(
                                            context,
                                            LoginPostRequests.sendTwoFactorCode(
                                                widget.referenceCode,
                                                otpFieldController.text))
                                        .then((a) {
                                      CustomAlert.showCustomScaffoldMessenger(
                                          context,
                                          "Successfully logged in! Redirecting to home page...",
                                          AlertType.success);
                                      LoginPostRequests.isLoggedIn = true;
                                      Navigator.of(context).pushNamedAndRemoveUntil(
                                          "/", (route) => false);
                                    }).catchError((e) {
                                      CustomAlert.showCustomScaffoldMessenger(
                                          context, e.toString(), AlertType.error);
                                    });
                                  } else {
                                    CustomAlert.showCustomScaffoldMessenger(
                                        context,
                                        "Please enter a valid code",
                                        AlertType.error);
                                  }
                                },
                              ),
                            ),
                            SizedBox(height: 100.h),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
              Container(
                height: 3.h,
                color: CommonColors.blue,
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void codeUpdated() {
    setState(() {
      if (code != null) {
        otpFieldController.text = code!;
      }
    });
  }

  @override
  void dispose() {
    cancel(); 
    super.dispose();
  }
}