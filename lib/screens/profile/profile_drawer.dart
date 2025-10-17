import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:watermeter2/utils/pok.dart';
import 'package:watermeter2/widgets/custom_app_bar.dart';
import '../../api/auth_service.dart';
import '../../bloc/dashboard_bloc.dart';
import '../../bloc/dashboard_state.dart';
import '../../constants/theme2.dart';
import '../../services/app_state_service.dart';
import '../../utils/alert_message.dart';
import '../../utils/biometric_helper.dart';
import '../../utils/custom_exception.dart';
import '../../utils/misc_functions.dart';
import '../../utils/new_loader.dart';
import '../../utils/toggle_button.dart';
import '../../widgets/chamfered_text_widget.dart';
import '../../widgets/customButton.dart';
import '../../widgets/customTextField.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/password_controller.dart';
import 'active_devices.dart';
import 'authenticator.dart';
import 'country_code_picker.dart';
import 'two_factor_disabled.dart';


class ProfileDrawer extends StatefulWidget {
  const ProfileDrawer({super.key});

  @override
  _ProfileDrawerState createState() {
    return _ProfileDrawerState();
  }
}

class _ProfileDrawerState extends State<ProfileDrawer> {
  String dropdownValue = 'D';

  CountryCode? selectedCountryCode = CountryCode(code: "IN");
  var newPasswordController = ObscuringTextEditingController();
  var oldPasswordController = ObscuringTextEditingController();
  var confirmNewPasswordController = ObscuringTextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _activationCodeController =
      TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  TextEditingController emailOtpFieldController = TextEditingController();
  TextEditingController phoneOtpFieldController = TextEditingController();
  TextEditingController deleteConfirmationFieldController = TextEditingController();
  bool deleteAccountVisible = false;

  // late String oldPhone;
  // late String oldEmail;
  // late String oldName;

  @override
  void initState() {
    super.initState();
    initControllers();
  }

  ValueNotifier<String> refreshPhoneCode = ValueNotifier<String>("");

  initControllers() {
    _nameController.text =
        BlocProvider.of<DashboardBloc>(context, listen: false).userInfo.name;
    _emailController.text =
        BlocProvider.of<DashboardBloc>(context, listen: false).userInfo.email;
    _phoneController.text =
        BlocProvider.of<DashboardBloc>(context, listen: false).userInfo.phone;
    selectedCountryCode = findCountry(
        _phoneController.text.substring(0, _phoneController.text.length - 10));
    emailOtpFieldController.clear();
    phoneOtpFieldController.clear();
    clearPasswords();
    refreshPhoneCode.value = _phoneController.text;
    refreshPhoneCode.notifyListeners();
  }

  CountryCode findCountry(String dialCode) {
    List<CountryCode> countries =
        codes.map((e) => CountryCode.fromJson(e)).toList();

    for (var country in countries) {
      if (country.dialCode == dialCode) {
        return country; // Returns the country code like "IN", "US"
      }
    }
    return CountryCode(code: "IN", dialCode: "+91", name: "India");
  }

  clearPasswords() {
    newPasswordController.clear();
    oldPasswordController.clear();
    confirmNewPasswordController.clear();
  }

  // bool emailChanged() {
  //   return _emailController.text !=
  //       BlocProvider.of<HomeBloc>(context, listen: false).userInfo.email;
  // }
  //
  // getPhoneNumberFull() {
  //   return (selectedCountryCode?.dialCode ?? '') + (_phoneController.text);
  // }
  //
  // bool phoneChanged() {
  //   print("Phone number is ${getPhoneNumberFull()}");
  //   return getPhoneNumberFull() !=
  //       BlocProvider.of<HomeBloc>(context, listen: false).userInfo.phone;
  // }

  bool emailChanged() {
    return _emailController.text !=
        BlocProvider.of<DashboardBloc>(context, listen: false).userInfo.email;
  }

  getPhoneNumberFull() {
    return (selectedCountryCode?.dialCode ?? '') + (_phoneController.text);
  }

  bool phoneChanged() {
    return getPhoneNumberFull() !=
        BlocProvider.of<DashboardBloc>(context, listen: false).userInfo.phone;
  }

  void checkAllTextFields() {
    if (_emailController.text.isNotEmpty) {
      if (MiscellaneousFunctions.isEmailValid(_emailController.text) == false) {
        throw CustomException("Invalid Email");
      }
    }
    if (_phoneController.text.isNotEmpty) {
      if (selectedCountryCode == null ||
          selectedCountryCode!.dialCode == null) {
        throw CustomException("Invalid Country Code");
      }
    }
    if (oldPasswordController.text.isEmpty) {
      throw CustomException("Password (old) cannot be empty");
    }
    if (oldPasswordController.text.length < 8) {
      throw CustomException(
          "Password (old) must be at least 8 characters long");
    }
    if (newPasswordController.text.isNotEmpty &&
        newPasswordController.text.length < 8) {
      throw CustomException(
          "Password (new) must be at least 8 characters long");
    }
    if (newPasswordController.text.isNotEmpty &&
        newPasswordController.text != confirmNewPasswordController.text) {
      throw CustomException(
          "Password (new) and Confirm Password (new) do not match");
    }
  }

  void updateProfile(context) async {
    try {
      BlocProvider.of<DashboardBloc>(context, listen: false).updateProfile();
    } catch (e) {
      CustomAlert.showCustomScaffoldMessenger(
          context, e.toString(), AlertType.error);
    }
  }

  @override
  Widget build(BuildContext context) {



    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        appBar: CustomAppBar(
                choiceAction: (value) {
                  Navigator.of(context).pop();
                },
                isProfile: true,
              ),
        backgroundColor: Provider.of<ThemeNotifier>(context).currentTheme.bgColor,
        resizeToAvoidBottomInset: false,
        body: BlocBuilder<DashboardBloc, DashboardState>(
            buildWhen: (previous, current) {
          if (current is UserInfoUpdate || current is UserInfoUpdate2) {
            initControllers();
            CustomAlert.showCustomScaffoldMessenger(
                context, "Profile Updated Successfully!", AlertType.success);
            return true;
          }
          return false;
        }, builder: (context, state) {
          return LayoutBuilder(builder: (context, constraints) {
            return Column(
              children: [
                Container(
                  height: 3.h,
                  color: CommonColors.blue2,
                ),
                Container(
                  height: constraints.maxHeight - 6.h,
                  child: SingleChildScrollView(
                    physics: ClampingScrollPhysics(),
                    child: Container(
                      color: Provider.of<ThemeNotifier>(context)
                          .currentTheme
                          .bgColor,
                      child: Column(
                        children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              height: 51.h,
                              color: Provider.of<ThemeNotifier>(context).currentTheme.bgColor,
                              child: Row(
                                children: [
                                  IconButton(
                                    icon: Icon(
                                      Icons.arrow_back,
                                      color: Provider.of<ThemeNotifier>(context).currentTheme.loginTitleColor,
                                    ),
                                    onPressed: () => Navigator.of(context).pop(),
                                  ),
                                  Text(
                                    "PROFILE",
                                    style: GoogleFonts.robotoMono(
                                      fontSize: 18.minSp,
                                      fontWeight: FontWeight.w500,
                                      color: Provider.of<ThemeNotifier>(context).currentTheme.loginTitleColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 0),
                              child: ChamferedTextWidget(
                                text: "USER",
                                fillColor: Provider.of<ThemeNotifier>(context)
                                    .currentTheme
                                    .bgColor,
                                bgColor: Provider.of<ThemeNotifier>(context)
                                    .currentTheme
                                    .profileChamferColor,
                                textColor: Provider.of<ThemeNotifier>(context)
                                    .currentTheme
                                    .drawerHeadingColor,
                                // text: "EEFWEFEW",
                                borderColor:
                                    Provider.of<ThemeNotifier>(context)
                                        .currentTheme
                                        .profileBorderColor,
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 0),
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 11.w, vertical: 13.h),
                                decoration: BoxDecoration(
                                    border: Border.all(
                                  color: Provider.of<ThemeNotifier>(context)
                                      .currentTheme
                                      .profileBorderColor,
                                  width: 3.minSp,
                                )),
                                child: Column(
                                  children: [
                                    CustomTextField(
                                      controller: _nameController,
                                      iconPath: 'assets/icons/profile2.svg',
                                      hintText: 'Enter Full Name',
                                      keyboardType: TextInputType.name,
                                    ),
                                    SizedBox(height: 8.h),
                                    CustomTextField(
                                      controller: _emailController,
                                      iconPath: 'assets/icons/mail.svg',
                                      hintText: 'Enter Email',
                                      keyboardType:
                                          TextInputType.emailAddress,
                                    ),
                                    SizedBox(height: 8.h),
                                    CustomTextField(
                                      controller: _phoneController,
                                      hintText: 'Enter Phone number',
                                      keyboardType: TextInputType.phone,
                                      inputFormatters: [
                                        FilteringTextInputFormatter
                                            .digitsOnly,
                                      ],
                                      prefixIcon: Container(
                                        // width: 60.w,
                                        padding:
                                            EdgeInsets.only(left: 16.w - 8),
                                        decoration: const BoxDecoration(
                                            borderRadius: BorderRadius.only(
                                              topLeft: Radius.circular(10),
                                              bottomLeft: Radius.circular(10),
                                            ),
                                            color: Colors.transparent),
                                        // width: 42.w,
                                        // height: 51.h,
                                        child: CountryCodePicker2(
                                          // key: UniqueKey(),
                                          refreshPhoneCode: refreshPhoneCode,
                                          dropDownColor:
                                              Provider.of<ThemeNotifier>(
                                                      context)
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
                                          onChanged:
                                              (CountryCode countryCode) {
                                            selectedCountryCode = countryCode;
                                          },
                                          getPhoneNumberWithoutCountryCode:
                                              (String phoneNumber) async {
                                            // print("This is executed");
                                            await Future.delayed(
                                                const Duration(
                                                    milliseconds: 100));
                                            _phoneController.text =
                                                phoneNumber;
                                          },
                                          // isEditable: false,
                                          initialSelection:
                                              _phoneController.text,
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: 8.h),
                                    Container(
                                      height: 1.h,
                                      color:
                                          Provider.of<ThemeNotifier>(context)
                                              .currentTheme
                                              .profileBorderColor,
                                    ),
                                    SizedBox(height: 8.h),
                                    PasswordTextField(
                                      controller: oldPasswordController,
                                      hint: "Enter current password",
                                    ),
                                    SizedBox(height: 8.h),
                                    PasswordTextField(
                                      controller: newPasswordController,
                                      hint: "Enter new password",
                                    ),
                                    SizedBox(height: 8.h),
                                    PasswordTextField(
                                      controller:
                                          confirmNewPasswordController,
                                      hint: "Confirm new password",
                                    ),
                                    SizedBox(height: 16.h),
                                    CustomButton(
                                      text: "SUBMIT",
                                      onPressed: () async {
                                        FocusScope.of(context).unfocus();

                                        try {
                                          if (kDebugMode) {
                                            print("Checking all text fields");
                                          }

                                          checkAllTextFields();
                                        } catch (e) {
                                          if (kDebugMode) {
                                            print(
                                                "Error in checking all text fields $e");
                                          }
                                          CustomAlert
                                              .showCustomScaffoldMessenger(
                                                  context,
                                                  e.toString(),
                                                  AlertType.error);
                                          return;
                                        }
                                        LoaderUtility.showLoader(
                                                context,
                                                LoginPostRequests.updateInfo(
                                                    oldPasswordController
                                                        .text,
                                                    _nameController.text,
                                                    emailChanged()
                                                        ? _emailController
                                                            .text
                                                        : '',
                                                    phoneChanged()
                                                        ? getPhoneNumberFull()
                                                        : '',
                                                    newPasswordController
                                                        .text))
                                            .then((s) async {
                                          clearPasswords();

                                          updateProfile(context);
                                        }).catchError((e) {
                                          CustomAlert
                                              .showCustomScaffoldMessenger(
                                                  context,
                                                  e.toString(),
                                                  AlertType.error);
                                        });
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 0),
                          child: Column(
                            children: [
                              SizedBox(height: 20.h),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  ChamferedTextWidget(
                                    text: "AUTHENTICATION",
                                    fillColor: Provider.of<ThemeNotifier>(context)
                                        .currentTheme
                                        .bgColor,
                                    bgColor: Provider.of<ThemeNotifier>(context)
                                        .currentTheme
                                        .profileChamferColor,
                                    textColor: Provider.of<ThemeNotifier>(context)
                                        .currentTheme
                                        .drawerHeadingColor,
                                    // text: "EEFWEFEW",
                                    borderColor:
                                        Provider.of<ThemeNotifier>(context)
                                            .currentTheme
                                            .profileBorderColor,
                                  ),
                                  AuthenticationWidget(
                                    bottomOpen: true,
                                  ),
                                  BiometricWidget(
                                    topOpen: true,
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: 16.h,
                              ),
                              SizedBox(
                                height: 16,
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  ChamferedTextWidget(
                                    text: "LOGOUT",
                                    fillColor: Provider.of<ThemeNotifier>(context)
                                        .currentTheme
                                        .bgColor,
                                    bgColor: Provider.of<ThemeNotifier>(context)
                                        .currentTheme
                                        .profileChamferColor,
                                    textColor: Provider.of<ThemeNotifier>(context)
                                        .currentTheme
                                        .drawerHeadingColor,
                                    // text: "EEFWEFEW",
                                    borderColor:
                                        Provider.of<ThemeNotifier>(context)
                                            .currentTheme
                                            .profileBorderColor,
                                  ),
                                  Container(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 11.w, vertical: 13.h),
                                      decoration: BoxDecoration(
                                          border: Border.all(
                                        color: Provider.of<ThemeNotifier>(context)
                                            .currentTheme
                                            .profileBorderColor,
                                        width: 3.minSp,
                                      )),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Padding(
                                            padding: EdgeInsets.only(left: 8.w),
                                            child: Text(
                                              "Log out from this app",
                                              style: GoogleFonts.roboto(
                                                fontSize:
                                                    ThemeNotifier.medium.minSp,
                                                color: Provider.of<ThemeNotifier>(
                                                        context)
                                                    .currentTheme
                                                    .basicAdvanceTextColor,
                                              ),
                                            ),
                                          ),
                                          CustomButton(
                                            text: "LOGOUT",
                                            dynamicWidth: true,
                                            // width: 154.w,
                                            onPressed: () async {
                                              LoaderUtility.showLoader(context,
                                                      NudronRandomStuff.logout())
                                                  .then((s) {
                                                CustomAlert
                                                    .showCustomScaffoldMessenger(
                                                        context,
                                                        "Logged out successfully!",
                                                        AlertType.success);
                                              }).catchError((e) {
                                                CustomAlert
                                                    .showCustomScaffoldMessenger(
                                                        context,
                                                        e.toString(),
                                                        AlertType.error);
                                              });
                                            },
                                            isRed: true,
                                          ),
                                        ],
                                      )),

                                  // const MenuBarContainer(
                                  //     "Global Logout", double.infinity, 36.19),
                                ],
                              ),
                              SizedBox(
                                height: 16.h,
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  ChamferedTextWidget(
                                    text: "ACTIVE SESSIONS",
                                    fillColor: Provider.of<ThemeNotifier>(context)
                                        .currentTheme
                                        .bgColor,
                                    bgColor: Provider.of<ThemeNotifier>(context)
                                        .currentTheme
                                        .profileChamferColor,
                                    textColor: Provider.of<ThemeNotifier>(context)
                                        .currentTheme
                                        .drawerHeadingColor,
                                    // text: "EEFWEFEW",
                                    borderColor:
                                        Provider.of<ThemeNotifier>(context)
                                            .currentTheme
                                            .profileBorderColor,
                                  ),
                                  Container(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 11.w, vertical: 13.h),
                                      decoration: BoxDecoration(
                                          border: Border.all(
                                        color: Provider.of<ThemeNotifier>(context)
                                            .currentTheme
                                            .profileBorderColor,
                                        width: 3.minSp,
                                      )),
                                      child: Padding(
                                        padding: EdgeInsets.only(left: 8.w),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            ActiveDevices(key: UniqueKey()),
                                            SizedBox(height: 16.h),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceBetween,
                                              children: [
                                                Text(
                                                  "Log out from all devices",
                                                  style: GoogleFonts.roboto(
                                                    fontSize: ThemeNotifier
                                                        .medium.minSp,
                                                    color: Provider.of<
                                                                ThemeNotifier>(
                                                            context)
                                                        .currentTheme
                                                        .basicAdvanceTextColor,
                                                  ),
                                                ),
                                                CustomButton(
                                                  text: "GLOBAL LOGOUT",
                                                  dynamicWidth: true,
                                                  // width: 154.w,
                                                  onPressed: () async {
                                                    LoaderUtility.showLoader(
                                                            context,
                                                            LoginPostRequests
                                                                .globalLogout())
                                                        .then((s) {
                                                      CustomAlert
                                                          .showCustomScaffoldMessenger(
                                                              context,
                                                              "Logged out of all devices",
                                                              AlertType.success);
                                                    }).catchError((e) {
                                                      CustomAlert
                                                          .showCustomScaffoldMessenger(
                                                              context,
                                                              e.toString(),
                                                              AlertType.error);
                                                    });
                                                  },
                                                  isRed: true,
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      )),

                                  // const MenuBarContainer(
                                  //     "Global Logout", double.infinity, 36.19),
                                ],
                              ),
                              SizedBox(
                                height: 16.h,
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  ChamferedTextWidget(
                                    text: "DELETE ACCOUNT",
                                    fillColor: Provider.of<ThemeNotifier>(context)
                                        .currentTheme
                                        .bgColor,
                                    bgColor: Provider.of<ThemeNotifier>(context)
                                        .currentTheme
                                        .profileChamferColor,
                                    textColor: Provider.of<ThemeNotifier>(context)
                                        .currentTheme
                                        .drawerHeadingColor,
                                    // text: "EEFWEFEW",
                                    borderColor:
                                        Provider.of<ThemeNotifier>(context)
                                            .currentTheme
                                            .profileBorderColor,
                                  ),
                                  Container(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 11.w, vertical: 13.h),
                                      decoration: BoxDecoration(
                                          border: Border.all(
                                        color: Provider.of<ThemeNotifier>(context)
                                            .currentTheme
                                            .profileBorderColor,
                                        width: 3.minSp,
                                      )),
                                      child: Column(
                                        children: [
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Padding(
                                                padding: EdgeInsets.only(left: 8.w),
                                                child: Text(
                                                  "Delete your account",
                                                  style: GoogleFonts.roboto(
                                                    fontSize:
                                                        ThemeNotifier.medium.minSp,
                                                    color: Provider.of<ThemeNotifier>(
                                                            context)
                                                        .currentTheme
                                                        .basicAdvanceTextColor,
                                                  ),
                                                ),
                                              ),
                                              CustomButton(
                                                text: "DELETE",
                                                dynamicWidth: true,
                                                // width: 154.w,
                                                onPressed: () async {
                                                  setState(() {
                                                    deleteAccountVisible = true;
                                                  });
                                                },
                                                isRed: true,
                                              ),
                                            ],
                                          ),
                                          Visibility(
                                            visible: deleteAccountVisible,
                                            child: Column(
                                              children: [
                                                SizedBox(height: 8.h),
                                                Padding(
                                                  padding: EdgeInsets.only(top: 8.h),
                                                  child: Text(
                                                    "Warning: This action is irreversible. You will no longer be able to access your IoT data.",
                                                    style: GoogleFonts.roboto(
                                                      fontSize:
                                                          ThemeNotifier.extrasmall.minSp,
                                                      color: CommonColors.red,
                                                    ),
                                                  ),
                                                ),
                                                SizedBox(height: 16.h),
                                                CustomTextField(controller: deleteConfirmationFieldController, hintText: "Type 'DELETE' to confirm"),
                                                SizedBox(height: 16.h),
                                                Padding(
                                                  padding: EdgeInsets.symmetric(horizontal: 16.0.w),
                                                  child: Row(
                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                    children: [
                                                      
                                                      CustomButton(
                                                        text: "CANCEL",
                                                        onPressed: () {
                                                          setState(() {
                                                            deleteAccountVisible = false;
                                                          });
                                                          print("Delete action cancelled");
                                                          // Perform cancel action
                                                        },
                                                      ),
                                                  
                                                      CustomButton(
                                                        text: "CONFIRM",
                                                        onPressed: () {
                                                          if (deleteConfirmationFieldController.text.toUpperCase() == "DELETE") {
                                                            LoaderUtility.showLoader(
                                                                      context,
                                                                      LoginPostRequests
                                                                          .globalLogout())
                                                                  .then((s) {
                                                                CustomAlert
                                                                    .showCustomScaffoldMessenger(
                                                                        context,
                                                                        "Logged out of all devices",
                                                                        AlertType.success);
                                                              }).catchError((e) {
                                                                CustomAlert
                                                                    .showCustomScaffoldMessenger(
                                                                        context,
                                                                        e.toString(),
                                                                        AlertType.error);
                                                              });
                                                            
                                                          } else {
                                                            print("Delete confirmation failed");
                                                            CustomAlert.showCustomScaffoldMessenger(context, "Please type 'DELETE' to confirm.", AlertType.error);
                                                          }
                                                        },
                                                        isRed: true,
                                                      ),
                                                    ],
                                                  ),
                                                )
                                              ],
                                            ),
                                          ),
                                        ],
                                      )),

                                  // const MenuBarContainer(
                                  //     "Global Logout", double.infinity, 36.19),
                                ],
                              ),
                              SizedBox(
                                height: 16.h,
                              ),
                            ],
                          ),
                        ),
                      ]),
                    ),
                  ),
                ),
                Container(
                  height: 3.h,
                  color: CommonColors.blue2,
                ),
              ],
            );
          });
        }),
      ),
    );
  }
}

class AuthenticationWidget extends StatefulWidget {
  const AuthenticationWidget({
    super.key,
    this.topOpen = false,
    this.bottomOpen = false,
  });

  final bool topOpen;
  final bool bottomOpen;
  @override
  State<AuthenticationWidget> createState() => _AuthenticationWidgetState();
}

class _AuthenticationWidgetState extends State<AuthenticationWidget> {
  bool showAuthenticationDialog = false;
  bool showDisableConfirm = false;
  bool is2FAEnabled = NudronRandomStuff.isAuthEnabled.value;

  @override
  void initState() {
    NudronRandomStuff.isAuthEnabled.addListener(() {
      print(
          "isAuthEnabled changed to ${NudronRandomStuff.isAuthEnabled.value}");
      if (mounted) {
        setState(() {
          is2FAEnabled = NudronRandomStuff.isAuthEnabled.value ||
              NudronRandomStuff.isBiometricEnabled.value;
        });
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(11.w, 13.h, 11.w, 9.h),
      decoration: BoxDecoration(
        border: widget.topOpen
            ? Border(
                left: BorderSide(
                  color: Provider.of<ThemeNotifier>(context)
                      .currentTheme
                      .profileBorderColor,
                  width: 3.minSp,
                ),
                right: BorderSide(
                  color: Provider.of<ThemeNotifier>(context)
                      .currentTheme
                      .profileBorderColor,
                  width: 3.minSp,
                ),
                bottom: BorderSide(
                  color: Provider.of<ThemeNotifier>(context)
                      .currentTheme
                      .profileBorderColor,
                  width: 3.minSp,
                ),
              )
            : widget.bottomOpen
                ? Border(
                    left: BorderSide(
                      color: Provider.of<ThemeNotifier>(context)
                          .currentTheme
                          .profileBorderColor,
                      width: 3.minSp,
                    ),
                    right: BorderSide(
                      color: Provider.of<ThemeNotifier>(context)
                          .currentTheme
                          .profileBorderColor,
                      width: 3.minSp,
                    ),
                    top: BorderSide(
                      color: Provider.of<ThemeNotifier>(context)
                          .currentTheme
                          .profileBorderColor,
                      width: 3.minSp,
                    ),
                  )
                : Border.all(
                    color: Provider.of<ThemeNotifier>(context)
                        .currentTheme
                        .profileBorderColor,
                    width: 3.minSp,
                  ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: EdgeInsets.only(left: 8.w),
                child: Text(
                  "Two Factor Authentication",
                  style: GoogleFonts.roboto(
                    fontSize: ThemeNotifier.medium.minSp,
                    color: Provider.of<ThemeNotifier>(context)
                        .currentTheme
                        .basicAdvanceTextColor,
                  ),
                ),
              ),
              ToggleButtonCustom(
                key: UniqueKey(),
                index: is2FAEnabled ? 1 : 0,
                dontChangeImmediately: true,
                tabs: const ["NO", "YES"],
                onTap: (int newIndex) {
                  if (newIndex == 1) {
                    if (!is2FAEnabled) {
                      setState(() {
                        showAuthenticationDialog = true;
                        showDisableConfirm = false;
                      });
                    }
                  } else {
                    if (is2FAEnabled) {
                      setState(() {
                        showDisableConfirm = true;
                        showAuthenticationDialog = false;
                      });
                    }
                  }
                },
                backgroundColor: Provider.of<ThemeNotifier>(context)
                    .currentTheme
                    .toggleColor,
                selectedTextColor: Colors.white,
                unselectedTextColor:
                    Provider.of<ThemeNotifier>(context).currentTheme.tableText,
                width: 112,
                height: 30,
                smallerHeight: 25,
                smallerWidth: 53,
                fontSize: ThemeNotifier.extrasmall,
                leftGap: 3,
                verticalGap: 2.5,
                tabColor: CommonColors.red,
                tabColor2: const Color(0xFF00BC8A),
              ),
            ],
          ),
          Visibility(
              visible: showDisableConfirm,
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 15.h),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CustomButton(
                      text: "CANCEL",
                      onPressed: () {
                        setState(() {
                          showDisableConfirm = false;
                        });
                      },
                      isRed: true,
                    ),
                    SizedBox(width: 40.w),
                    CustomButton(
                      text: "CONFIRM",
                      onPressed: () {
                        if (NudronRandomStuff.isAuthEnabled.value) {
                          LoaderUtility.showLoader(context,
                                  LoginPostRequests.disableTwoFactorAuth())
                              .then((s) {
                            NudronRandomStuff.isAuthEnabled.value = false;
                            setState(() {
                              showDisableConfirm = false;
                              is2FAEnabled = false;
                            });
                            CustomAlert.showCustomScaffoldMessenger(
                                context,
                                "Two Factor Authentication Disabled",
                                AlertType.success);
                          }).catchError((e) {
                            CustomAlert.showCustomScaffoldMessenger(
                                context, e.toString(), AlertType.error);
                          });
                        }
                      },
                    ),
                  ],
                ),
              )),
          showAuthenticationDialog
              ? TwoFADisabled(
                  closeFunction: () {
                    setState(() {
                      showAuthenticationDialog = false;
                    });
                  },
                )
              : Container(),
          SizedBox(
            height: 9.h,
          ),
          Container(
            height: 1,
            color: Provider.of<ThemeNotifier>(context)
                .currentTheme
                .basicAdvanceTextColor,
          )
        ],
      ),
    );
  }
}

class BiometricWidget extends StatefulWidget {
  const BiometricWidget({
    super.key,
    this.topOpen = false,
    this.bottomOpen = false,
  });

  final bool topOpen;
  final bool bottomOpen;
  @override
  State<BiometricWidget> createState() => _BiometricWidgetState();
}

class _BiometricWidgetState extends State<BiometricWidget> {
  bool showBiometricDialog = false;
  bool showDisableConfirm = false;
  bool isBiometricEnabled = NudronRandomStuff.isBiometricEnabled.value;

  @override
  void initState() {
    NudronRandomStuff.isBiometricEnabled.addListener(() {
      if (mounted) {
        print(
            "isBiometricEnabled changed to ${NudronRandomStuff.isBiometricEnabled.value}");
        setState(() {
          isBiometricEnabled = NudronRandomStuff.isBiometricEnabled.value;
        });
      }
    });
    super.initState();
  }

  Future<bool> disableBiometric() async {
    BiometricHelper biometricHelper = BiometricHelper();
    bool isSetup = await biometricHelper.isBiometricSetup();
    if (isSetup) {
      await biometricHelper.isCorrectBiometric().then((value) async {
        if (value) {
          // showDisableConfirm = false;
          await biometricHelper.toggleBiometric(false);
          CustomAlert.showCustomScaffoldMessenger(
              context, "Biometric Authentication Disabled", AlertType.success);
          return true;
        } else {
          CustomAlert.showCustomScaffoldMessenger(
              context, "Biometric Authentication Failed", AlertType.error);
          return false;
        }
      }).catchError((e) {
        CustomAlert.showCustomScaffoldMessenger(
            context, e.toString(), AlertType.error);
        return false;
      });
    } else {
      await biometricHelper.toggleBiometric(false);
      // CustomAlert.showCustomScaffoldMessenger(
      //     context,
      //     "Biometric Authentication is not set up on this device. Removing 2FA",
      //     AlertType.error);
      return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: EdgeInsets.fromLTRB(11.w, 1.h, 11.w, 13.h),
        decoration: BoxDecoration(
          border: widget.topOpen
              ? Border(
                  left: BorderSide(
                    color: Provider.of<ThemeNotifier>(context)
                        .currentTheme
                        .profileBorderColor,
                    width: 3.minSp,
                  ),
                  right: BorderSide(
                    color: Provider.of<ThemeNotifier>(context)
                        .currentTheme
                        .profileBorderColor,
                    width: 3.minSp,
                  ),
                  bottom: BorderSide(
                    color: Provider.of<ThemeNotifier>(context)
                        .currentTheme
                        .profileBorderColor,
                    width: 3.minSp,
                  ),
                  top: BorderSide.none,
                )
              : widget.bottomOpen
                  ? Border(
                      left: BorderSide(
                        color: Provider.of<ThemeNotifier>(context)
                            .currentTheme
                            .profileBorderColor,
                        width: 3.minSp,
                      ),
                      right: BorderSide(
                        color: Provider.of<ThemeNotifier>(context)
                            .currentTheme
                            .profileBorderColor,
                        width: 3.minSp,
                      ),
                      top: BorderSide(
                        color: Provider.of<ThemeNotifier>(context)
                            .currentTheme
                            .profileBorderColor,
                        width: 3.minSp,
                      ),
                      bottom: BorderSide.none,
                    )
                  : Border.all(
                      color: Provider.of<ThemeNotifier>(context)
                          .currentTheme
                          .profileBorderColor,
                      width: 3.minSp,
                    ),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: EdgeInsets.only(left: 8.w),
                  child: Text(
                    "Biometric Login",
                    style: GoogleFonts.roboto(
                      fontSize: ThemeNotifier.medium.minSp,
                      color: Provider.of<ThemeNotifier>(context)
                          .currentTheme
                          .basicAdvanceTextColor,
                    ),
                  ),
                ),
                ToggleButtonCustom(
                  key: UniqueKey(),
                  index: isBiometricEnabled ? 1 : 0,
                  dontChangeImmediately: true,
                  tabs: const ["NO", "YES"],
                  onTap: (int newIndex) {
                    if (newIndex == 1) {
                      if (!isBiometricEnabled) {
                        setState(() {
                          showBiometricDialog = true;
                          showDisableConfirm = false;
                        });
                      }
                    } else {
                      if (isBiometricEnabled) {
                        setState(() {
                          showDisableConfirm = true;
                          showBiometricDialog = false;
                        });
                      }
                    }
                  },
                  backgroundColor: Provider.of<ThemeNotifier>(context)
                      .currentTheme
                      .toggleColor,
                  selectedTextColor: Colors.white,
                  unselectedTextColor: Provider.of<ThemeNotifier>(context)
                      .currentTheme
                      .tableText,
                  width: 112,
                  height: 30,
                  smallerHeight: 25,
                  smallerWidth: 53,
                  fontSize: ThemeNotifier.extrasmall,
                  leftGap: 3,
                  verticalGap: 2.5,
                  tabColor: CommonColors.red,
                  tabColor2: const Color(0xFF00BC8A),
                ),
              ],
            ),
            Visibility(
                visible: showDisableConfirm,
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 15.h),
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CustomButton(
                          text: "CANCEL",
                          onPressed: () {
                            setState(() {
                              showDisableConfirm = false;
                            });
                          },
                          isRed: true,
                        ),
                        SizedBox(width: 40.w),
                        CustomButton(
                          text: "CONFIRM",
                          onPressed: () {
                            if (NudronRandomStuff.isBiometricEnabled.value) {
                              disableBiometric()
                                  .then((value) {})
                                  .catchError((e) {
                                CustomAlert.showCustomScaffoldMessenger(
                                    context, e.toString(), AlertType.error);
                              });
                              setState(() {
                                showDisableConfirm = false;
                              });
                            }
                          },
                        ),
                      ]),
                )),
            showBiometricDialog
                ? BiometricDisabled(
                    closeFunction: () {
                      setState(() {
                        showBiometricDialog = false;
                      });
                    },
                  )
                : Container(),
          ],
        ));
  }
}