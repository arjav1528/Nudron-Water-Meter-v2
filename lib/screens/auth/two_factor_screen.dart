import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:provider/provider.dart';
import 'package:sms_autofill/sms_autofill.dart';
import 'package:watermeter2/utils/pok.dart';

import '../../bloc/auth_bloc.dart';
import '../../bloc/auth_event.dart';
import '../../bloc/auth_state.dart';
import '../../constants/theme2.dart';
import '../../constants/ui_config.dart';
import '../../utils/alert_message.dart';
import '../../utils/new_loader.dart';
import '../../widgets/customButton.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/custom_safe_area.dart';
import '../../main.dart';

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
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated) {
          // Navigate to home route so the route builder can show the dashboard/project selection
          // Success message is shown in main.dart after navigation completes
          WidgetsBinding.instance.addPostFrameCallback((_) {
            final navigator = mainNavigatorKey.currentState;
            if (navigator != null) {
              // Navigate to home route - this will trigger the route builder to show dashboard/project selection
              navigator.pushNamedAndRemoveUntil('/', (route) => false);
            }
          });
        } else if (state is AuthError) {
          CustomAlert.showCustomScaffoldMessenger(
              context, state.message, AlertType.error);
        }
      },
      child: GestureDetector(
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
                              icon: SvgPicture.asset(
                              'assets/icons/back_arrow.svg',
                              height: UIConfig.backButtonIconSize,
                              width: UIConfig.backButtonIconSize,
                              colorFilter: ColorFilter.mode(
                                Provider.of<ThemeNotifier>(context).currentTheme.basicAdvanceTextColor,
                                BlendMode.srcIn,
                              ),
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
                                dynamicWidth: true,
                                text: "VERIFY",
                                onPressed: () async {
                                  if (otpFieldController.text.length == 6) {
                                    final authBloc = BlocProvider.of<AuthBloc>(context, listen: false);
                                    
                                    // Create a completer to wait for the auth result
                                    final completer = Completer<void>();
                                    StreamSubscription? subscription;
                                    
                                    // Listen to auth state changes
                                    subscription = authBloc.stream.listen((state) {
                                      if (state is AuthAuthenticated || state is AuthError) {
                                        subscription?.cancel();
                                        if (!completer.isCompleted) {
                                          if (state is AuthError) {
                                            completer.completeError(state.message);
                                          } else {
                                            completer.complete();
                                          }
                                        }
                                      }
                                    });
                                    
                                    try {
                                      // Show loader and wait for verification
                                      await LoaderUtility.showLoader(
                                        context,
                                        Future(() async {
                                          // Trigger the verification
                                          authBloc.add(AuthVerifyTwoFactor(
                                            refCode: widget.referenceCode,
                                            code: otpFieldController.text,
                                          ));
                                          // Wait for the result
                                          await completer.future;
                                        }),
                                      );
                                      
                                      // If we get here, authentication was successful
                                      // Navigation is handled by the BlocListener
                                    } catch (e) {
                                      // Error is already handled by the BlocListener
                                      // But we can show an error message if needed
                                      if (mounted && e.toString().isNotEmpty) {
                                        CustomAlert.showCustomScaffoldMessenger(
                                            context, e.toString(), AlertType.error);
                                      }
                                    } finally {
                                      subscription.cancel();
                                    }
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