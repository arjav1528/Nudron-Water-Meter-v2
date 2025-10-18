
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
import '../../constants/app_config.dart';
import '../../constants/theme2.dart';
import '../../utils/alert_message.dart';
import '../../utils/new_loader.dart';
import '../../widgets/customButton.dart';
import '../../widgets/password_controller.dart';


class EnterTwoFacCodeSignUp extends StatefulWidget {
  EnterTwoFacCodeSignUp(
      {required this.activationCode, required this.changePage, super.key});

  String activationCode;
  Function changePage;

  @override
  State<EnterTwoFacCodeSignUp> createState() => _EnterTwoFacCodeSignUpState();
}

class _EnterTwoFacCodeSignUpState extends State<EnterTwoFacCodeSignUp>
    with CodeAutoFill {
  bool isLargerTextField = ConfigurationCustom.isLargerTextField;
  TextEditingController phoneOTP = TextEditingController();
  TextEditingController emailOTP = TextEditingController();
  var passwordControllerObscure = ObscuringTextEditingController();
  var passwordControllerObscure2 = ObscuringTextEditingController();
  var passwordController = TextEditingController();
  var passwordController2 = TextEditingController();
  bool _obscureText = true;
  bool _obscureText2 = true;

  String getPassword1() {
    if (_obscureText) {
      return passwordControllerObscure.text;
    } else {
      return passwordController.text;
    }
  }

  String getPassword2() {
    if (_obscureText2) {
      return passwordControllerObscure2.text;
    } else {
      return passwordController2.text;
    }
  }

  bool checkAllTextFields() {
    String pwd1 = getPassword1();
    String pwd2 = getPassword2();

    if (emailOTP.text.isEmpty ||
        pwd1.isEmpty ||
        pwd2.isEmpty ||
        phoneOTP.text.isEmpty) {
      CustomAlert.showCustomScaffoldMessenger(
          context, "Please fill all the fields", AlertType.info);
      return false;
    }
    if (pwd1 != pwd2) {
      CustomAlert.showCustomScaffoldMessenger(
          context, "Passwords do not match", AlertType.info);
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Column(
            children: [
              Padding(
                padding: EdgeInsets.only(
                    left: 35.w, right: 35.w, bottom: 21.h, top: 41.h),
                child: Container(
                  height: isLargerTextField ? null : 51.h,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Provider.of<ThemeNotifier>(context)
                        .currentTheme
                        .textFieldFillColor,
                    borderRadius: const BorderRadius.all(Radius.circular(10)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.25),
                        spreadRadius: 0,
                        blurRadius: 4,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(0),
                    // Ensures no extra padding
                    child: TextField(
                      controller: _obscureText
                          ? passwordControllerObscure
                          : passwordController,
                      enableSuggestions: false,
                      autocorrect: false,
                      style: GoogleFonts.roboto(
                        fontSize: ThemeNotifier.medium.responsiveSp,
                        color: Provider.of<ThemeNotifier>(context)
                            .currentTheme
                            .textfieldTextColor,
                      ),
                      cursorColor: Provider.of<ThemeNotifier>(context)
                          .currentTheme
                          .textfieldCursorColor,
                      cursorHeight: 30.responsiveSp,
                      decoration: InputDecoration(
                        prefixIcon: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 22.w),
                          child: SvgPicture.asset(
                            'assets/icons/pwd.svg',
                            height: 16.69.h,
                            width: 21.w,
                            fit: BoxFit.scaleDown,
                          ),
                        ),
                        prefixIconConstraints: BoxConstraints(
                          minHeight: 16.69.h,
                          minWidth: 21.w,
                        ),
                        focusedBorder: const OutlineInputBorder(
                          borderSide: BorderSide(
                            color: CommonColors.blue,
                          ),
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                        ),
                        filled: true,
                        fillColor: Provider.of<ThemeNotifier>(context)
                            .currentTheme
                            .textFieldFillColor,
                        hintText: 'New password',
                        suffixIcon: IconButton(
                          icon: Icon(
                            // Choose the icon based on the visibility status
                            _obscureText
                                ? Icons.visibility
                                : Icons.visibility_off,
                            color: Provider.of<ThemeNotifier>(context)
                                .currentTheme
                                .textfieldHintColor,
                            size: 16,
                          ),
                          onPressed: () {
                            int cursorPos = _obscureText
                                ? passwordControllerObscure.selection.baseOffset
                                : passwordController.selection.baseOffset;
                            cursorPos = (cursorPos < 0) ? 0 : cursorPos;

                            if (_obscureText) {
                              passwordController.text =
                                  passwordControllerObscure.text;
                              if (cursorPos <= passwordController.text.length) {
                                passwordController.selection =
                                    TextSelection.fromPosition(
                                        TextPosition(offset: cursorPos));
                              }
                            } else {
                              passwordControllerObscure.text =
                                  passwordController.text;
                              if (cursorPos <=
                                  passwordControllerObscure.text.length) {
                                passwordControllerObscure.selection =
                                    TextSelection.fromPosition(
                                        TextPosition(offset: cursorPos));
                              }
                            }
                            setState(() {
                              _obscureText = !_obscureText;
                            });
                          },
                        ),
                        hintStyle: GoogleFonts.roboto(
                          fontSize: ThemeNotifier.medium.responsiveSp,
                          color: Provider.of<ThemeNotifier>(context)
                              .currentTheme
                              .textfieldHintColor,
                        ),
                        border: const OutlineInputBorder(
                          borderSide: BorderSide.none,
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                        ),
                        contentPadding: EdgeInsets.symmetric(
                            vertical: isLargerTextField ? 22.h : 0.h),
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(left: 35.w, right: 35.w, bottom: 21.h),
                child: Container(
                  height: isLargerTextField ? null : 51.h,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Provider.of<ThemeNotifier>(context)
                        .currentTheme
                        .textFieldFillColor,
                    borderRadius: const BorderRadius.all(Radius.circular(10)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.25),
                        spreadRadius: 0,
                        blurRadius: 4,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(0),
                    // Ensures no extra padding
                    child: TextField(
                      controller: _obscureText2
                          ? passwordControllerObscure2
                          : passwordController2,
                      enableSuggestions: false,
                      autocorrect: false,
                      style: GoogleFonts.roboto(
                        fontSize: ThemeNotifier.medium.responsiveSp,
                        color: Provider.of<ThemeNotifier>(context)
                            .currentTheme
                            .textfieldTextColor,
                      ),
                      cursorColor: Provider.of<ThemeNotifier>(context)
                          .currentTheme
                          .textfieldCursorColor,
                      cursorHeight: 30.responsiveSp,
                      decoration: InputDecoration(
                        prefixIcon: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 22.w),
                          child: SvgPicture.asset(
                            'assets/icons/pwd.svg',
                            height: 16.69.h,
                            width: 21.w,
                            fit: BoxFit.scaleDown,
                          ),
                        ),
                        prefixIconConstraints: BoxConstraints(
                          minHeight: 16.69.h,
                          minWidth: 21.w,
                        ),
                        focusedBorder: const OutlineInputBorder(
                          borderSide: BorderSide(
                            color: CommonColors.blue,
                          ),
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                        ),
                        filled: true,
                        fillColor: Provider.of<ThemeNotifier>(context)
                            .currentTheme
                            .textFieldFillColor,
                        hintText: 'Re-enter New password',
                        suffixIcon: IconButton(
                          icon: Icon(
                            // Choose the icon based on the visibility status
                            _obscureText2
                                ? Icons.visibility
                                : Icons.visibility_off,
                            color: Provider.of<ThemeNotifier>(context)
                                .currentTheme
                                .textfieldHintColor,
                            size: 16,
                          ),
                          onPressed: () {
                            int cursorPos = _obscureText2
                                ? passwordControllerObscure2
                                    .selection.baseOffset
                                : passwordController2.selection.baseOffset;
                            cursorPos = (cursorPos < 0) ? 0 : cursorPos;

                            if (_obscureText2) {
                              passwordController2.text =
                                  passwordControllerObscure2.text;
                              if (cursorPos <=
                                  passwordController2.text.length) {
                                passwordController2.selection =
                                    TextSelection.fromPosition(
                                        TextPosition(offset: cursorPos));
                              }
                            } else {
                              passwordControllerObscure2.text =
                                  passwordController2.text;
                              if (cursorPos <=
                                  passwordControllerObscure2.text.length) {
                                passwordControllerObscure2.selection =
                                    TextSelection.fromPosition(
                                        TextPosition(offset: cursorPos));
                              }
                            }
                            setState(() {
                              _obscureText2 = !_obscureText2;
                            });
                          },
                        ),
                        hintStyle: GoogleFonts.roboto(
                          fontSize: ThemeNotifier.medium.responsiveSp,
                          color: Provider.of<ThemeNotifier>(context)
                              .currentTheme
                              .textfieldHintColor,
                        ),
                        border: const OutlineInputBorder(
                          borderSide: BorderSide.none,
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                        ),
                        contentPadding: EdgeInsets.symmetric(
                            vertical: isLargerTextField ? 22.h : 0.h),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          CustomPincode(
            controller: emailOTP,
            name: "Email Verification Code",
          ),
          CustomPincode(
            controller: phoneOTP,
            name: "Phone Verification Code",
          ),
          SizedBox(height: 40.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              CustomButton(
                text: "CANCEL",
                isRed: true,
                onPressed: () {
                  passwordController.clear();
                  passwordController2.clear();
                  emailOTP.clear();
                  phoneOTP.clear();
                  widget.changePage();
                },
              ),
              CustomButton(
                text: "VERIFY",
                onPressed: () async {
                  if (checkAllTextFields()) {
                    LoaderUtility.showLoader(
                        context,
                        LoginPostRequests.contactVerification(
                          widget.activationCode,
                          getPassword1(),
                          emailOTP.text,
                          phoneOTP.text,
                        )).then((value) {
                      CustomAlert.showCustomScaffoldMessenger(
                          context,
                          "Verification Successful. Please login",
                          AlertType.success);
                      passwordController.clear();
                      passwordController2.clear();
                      passwordControllerObscure.clear();
                      passwordControllerObscure2.clear();
                      emailOTP.clear();
                      phoneOTP.clear();
                      widget.changePage();
                    }).catchError((e) {
                      CustomAlert.showCustomScaffoldMessenger(
                          context, e.toString(), AlertType.error);
                      return;
                    });
                  }
                },
              ),
            ],
          ),
          SizedBox(height: 40.h),
        ],
      ),
    );
  }

  @override
  void codeUpdated() {
    setState(() {
      if (code != null) {
        phoneOTP.text = code!;
      }
    });
  }

  @override
  void dispose() {
    cancel(); // Dispose the listener
    super.dispose();
  }
}

class CustomPincode extends StatefulWidget {
  CustomPincode({super.key, required this.controller, required this.name});
  TextEditingController controller;
  String name;

  @override
  State<CustomPincode> createState() => _CustomPincodeState();
}

class _CustomPincodeState extends State<CustomPincode> {
  bool isLargerTextField = ConfigurationCustom.isLargerTextField;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: 35.w, right: 35.w, bottom: 21.h),
      child: Column(
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                widget.name,
                textAlign: TextAlign.center,
                style: GoogleFonts.roboto(
                  color: Provider.of<ThemeNotifier>(context)
                      .currentTheme
                      .loginTitleColor,
                  fontSize: ThemeNotifier.medium.responsiveSp,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ),
          Container(
            height: isLargerTextField ? 68.h : 51.h,
            padding: EdgeInsets.symmetric(
                horizontal: 8.w, vertical: (isLargerTextField ? 8 : 0).h),
            width: double.infinity,
            decoration: BoxDecoration(
              // color: Provider.of<ThemeNotifier>(context)
              //     .currentTheme
              //     .textFieldFillColor,
              borderRadius: const BorderRadius.all(Radius.circular(10)),
              border: Border.all(
                color: Provider.of<ThemeNotifier>(context)
                    .currentTheme
                    .profileBorderColor,
              ),
              // boxShadow: [
              //   BoxShadow(
              //     color: Colors.black.withOpacity(0.25),
              //     spreadRadius: 0,
              //     blurRadius: 4,
              //     offset: const Offset(0, 4),
              //   ),
              // ],
            ),
            child: PinCodeTextField(
              length: 6,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
              ],
              keyboardType: TextInputType.number,
              textStyle: GoogleFonts.roboto(
                color: Provider.of<ThemeNotifier>(context)
                    .currentTheme
                    .basicAdvanceTextColor,
                fontSize: 16.responsiveSp,
                fontWeight: FontWeight.w400,
              ),
              cursorColor: Provider.of<ThemeNotifier>(context)
                  .currentTheme
                  .basicAdvanceTextColor,
              backgroundColor:
                  Provider.of<ThemeNotifier>(context).currentTheme.bgColor,
              obscureText: false,
              animationType: AnimationType.fade,
              pinTheme: PinTheme(
                shape: PinCodeFieldShape.underline,
                borderRadius: BorderRadius.circular(5),
                fieldHeight: (isLargerTextField ? 51 : 40).h,
                fieldWidth: 40.w,
                activeFillColor: Provider.of<ThemeNotifier>(context)
                    .currentTheme
                    .basicAdvanceTextColor,
                activeColor: CommonColors.blue,
                selectedColor: CommonColors.blue,
                inactiveColor: Provider.of<ThemeNotifier>(context)
                    .currentTheme
                    .basicAdvanceTextColor,
                // inactiveColor: Theme.of(context).drawerTheme.backgroundColor,
                selectedFillColor:
                    Provider.of<ThemeNotifier>(context).currentTheme.bgColor,
              ),
              animationDuration: const Duration(milliseconds: 300),
              // backgroundColor: Provider.of<ThemeNotifier>(context)
              //     .currentTheme
              //     .textFieldFillColor,
              controller: widget.controller,
              onCompleted: (v) {
                if (kDebugMode) {
                  print("Completed");
                }
              },
              beforeTextPaste: (text) {
                //if you return true then it will show the paste confirmation dialog. Otherwise if false, then nothing will happen.
                //but you can show anything you want here, like your pop up saying wrong paste format or etc
                return true;
              },
              appContext: context,
              onChanged: (String value) {},
            ),
          )
        ],
      ),
    );
  }
}
