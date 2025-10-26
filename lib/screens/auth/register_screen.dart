import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../../api/auth_service.dart';
import '../../constants/app_config.dart';
import '../../constants/theme2.dart';
import '../../services/app_state_service.dart';
import '../../utils/alert_message.dart';
import '../../utils/new_loader.dart';
import '../../widgets/customButton.dart';
import '../../widgets/customTextField.dart';
import '../profile/country_code_picker.dart';
import 'two_factor_signup_screen.dart';


class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  TextEditingController activationCodeController = TextEditingController();
  CountryCode? selectedCountryCode = CountryCode(code: "IN");
  bool verifyPhoneAndEmail = false;
  bool isLargerTextField = ConfigurationCustom.isLargerTextField;

  void clearAllFields() {
    nameController.clear();
    emailController.clear();
    _phoneController.clear();
    activationCodeController.clear();
  }

  bool checkAllTextFields() {
    if (nameController.text.isEmpty ||
        emailController.text.isEmpty ||
        _phoneController.text.isEmpty ||
        activationCodeController.text.isEmpty) {
      CustomAlert.showCustomScaffoldMessenger(
          context, "Please fill all the fields", AlertType.warning);
      return false;
    }
    if (RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9-]+\.[a-zA-Z]+")
            .hasMatch(emailController.text) ==
        false) {
      CustomAlert.showCustomScaffoldMessenger(
          context, "Please enter a valid email", AlertType.warning);
      return false;
    }
    if (selectedCountryCode == null || selectedCountryCode!.code == null) {
      CustomAlert.showCustomScaffoldMessenger(
          context, "Please select a country code", AlertType.warning);
      return false;
    }
    return true;
  }

  getPhoneNumberFull() {
    return (selectedCountryCode?.dialCode ?? '') + (_phoneController.text);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Visibility(
          visible: !verifyPhoneAndEmail,
          child: Column(
            children: [
              Padding(
                  padding:
                      EdgeInsets.only(left: 35.w, right: 35.w, bottom: 22.h),
                  child: CustomTextField(
                    key: UniqueKey(),
                    controller: nameController,
                    iconPath: 'assets/icons/profile2.svg',
                    hintText: 'Enter Full Name',
                    keyboardType: TextInputType.name,
                  )),
              Padding(
                  padding:
                      EdgeInsets.only(left: 35.w, right: 35.w, bottom: 22.h),
                  child: CustomTextField(
                    controller: emailController,
                    key: UniqueKey(),
                    iconPath: 'assets/icons/mail.svg',
                    hintText: 'Enter Email',
                    keyboardType: TextInputType.emailAddress,
                  )),
              Padding(
                  padding:
                      EdgeInsets.only(left: 35.w, right: 35.w, bottom: 22.h),
                  child: CustomTextField(
                    controller: _phoneController,
                    key: UniqueKey(),
                    hintText: 'Enter Phone number',
                    keyboardType: TextInputType.phone,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                    prefixIcon: Container(
                      // width: 60.w,
                      padding: EdgeInsets.only(left: (16.w - 8).clamp(0.0, double.infinity)),
                      decoration: const BoxDecoration(
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(10),
                            bottomLeft: Radius.circular(10),
                          ),
                          color: Colors.transparent),
                      // width: 42.w,
                      // height: 51.h,
                      child: CountryCodePicker2(
                        dropDownColor: Provider.of<ThemeNotifier>(context)
                            .currentTheme
                            .textFieldBGProfile,
                        height: 30.78.h,
                        decoration: const BoxDecoration(
                          color: Colors.transparent,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(10),
                            bottomLeft: Radius.circular(10),
                          ),
                        ),
                        onChanged: (CountryCode countryCode) {
                          selectedCountryCode = countryCode;
                        },
                        getPhoneNumberWithoutCountryCode: (String phoneNumber) {
                          _phoneController.text = phoneNumber;
                        },
                        // isEditable: false,
                        initialSelection: null,
                      ),
                    ),
                  )),
              Padding(
                  padding: EdgeInsets.only(left: 35.w, right: 35.w),
                  child: CustomTextField(
                    controller: activationCodeController,
                    key: UniqueKey(),

                    // iconPath: 'assets/icons/mail.svg',
                    hintText: 'Enter Activation Code',
                    prefixIcon: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.w),
                        child: Icon(
                          Icons.key,
                          color: Provider.of<ThemeNotifier>(context)
                              .currentTheme
                              .textfieldHintColor,
                        )),
                    // suffixIcon: GestureDetector(
                    //     //clipboard paste
                    //     onTap: () {
                    //       FlutterClipboard.paste().then((value) {
                    //         String code = value.toString().split("=").last;
                    //         activationCodeController.text = code;
                    //       });
                    //     },
                    //     child: Icon(
                    //       Icons.content_paste_go_outlined,
                    //       color: Provider.of<ThemeNotifier>(context)
                    //           .currentTheme
                    //           .textfieldHintColor,
                    //     )),
                  )),
              SizedBox(height: 40.h),
              Center(
                child: CustomButton(
                  text: "REGISTER",
                  // fontSize: 14,
                  // fontSize: 16,
                  // width: 147.64.w,
                  // height: 58.h,
                  onPressed: () async {
                    if (checkAllTextFields()) {
                      LoaderUtility.showLoader(
                              context,
                              LoginPostRequests.signUp(
                                  activationCodeController.text,
                                  nameController.text,
                                  emailController.text,
                                  getPhoneNumberFull()))
                          .then((value) {
                        CustomAlert.showCustomScaffoldMessenger(
                            context,
                            "Verification code sent to your email address and phone number",
                            AlertType.info);
                        setState(() {
                          verifyPhoneAndEmail = true;
                        });
                      }).catchError((e) {
                        CustomAlert.showCustomScaffoldMessenger(
                            context, e.toString(), AlertType.error);
                        return;
                      });
                    }
                  },
                ),
              ),
              // SizedBox(height: 20.h),
              // Text(
              //     "If you are a customer of Nudron's smart meters and want access, please contact us at hello@nudron.com",
              //     textAlign: TextAlign.center,
              //     style: GoogleFonts.roboto(
              //         fontSize: 15.responsiveSp,
              //
              //         // fontWeight: FontWeight.w500,
              //         color: Provider.of<ThemeNotifier>(context)
              //             .currentTheme
              //             .basicAdvanceTextColor)),
              SizedBox(height: 40.h),
            ],
          ),
        ),
        verifyPhoneAndEmail
            ? EnterTwoFacCodeSignUp(
                changePage: () {
                  setState(() {
                    clearAllFields();
                    verifyPhoneAndEmail = false;
                  });
                  NudronRandomStuff.isSignIn.value = true;
                },
                key: UniqueKey(),
                activationCode: activationCodeController.text,
              )
            : Container(),
      ],
    );
  }
}