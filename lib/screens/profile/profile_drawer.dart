import 'dart:ui';

import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gradient_borders/box_borders/gradient_box_border.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:provider/provider.dart';
import 'package:watermeter2/services/platform_utils.dart';
import 'package:watermeter2/widgets/custom_app_bar.dart';
import '../../api/auth_service.dart';
import '../../bloc/auth_bloc.dart';
import '../../bloc/auth_event.dart';
import '../../bloc/auth_state.dart';
import '../../bloc/dashboard_bloc.dart';
import '../../bloc/dashboard_state.dart';
import '../../constants/theme2.dart';
import '../../constants/ui_config.dart';
import '../../services/app_state_service.dart';
import '../../utils/alert_message.dart';
import '../../utils/biometric_helper.dart';
import '../../utils/custom_exception.dart';
import '../../utils/misc_functions.dart';
import '../../utils/new_loader.dart';
import '../../utils/pok.dart';
import '../../utils/toggle_button.dart';
import '../../widgets/chamfered_text_widget.dart';
import '../../widgets/customButton.dart';
import '../../widgets/customTextField.dart';
import '../../widgets/password_controller.dart';
import 'active_devices.dart';
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
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  TextEditingController emailOtpFieldController = TextEditingController();
  TextEditingController phoneOtpFieldController = TextEditingController();
  TextEditingController deleteConfirmationFieldController = TextEditingController();
  bool deleteAccountVisible = false;
  bool _isLoggingOut = false;
  bool _isGlobalLoggingOut = false;
  bool _isLoaderShowing = false;
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _deleteAccountKey = GlobalKey();
  final GlobalKey _twoFactorKey = GlobalKey();
  final GlobalKey _biometricKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    initControllers();
  }

  ValueNotifier<String> refreshPhoneCode = ValueNotifier<String>("");

  @override
  void dispose() {
    
    refreshPhoneCode.dispose();
    _scrollController.dispose();
    
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    emailOtpFieldController.dispose();
    phoneOtpFieldController.dispose();
    deleteConfirmationFieldController.dispose();
    newPasswordController.dispose();
    oldPasswordController.dispose();
    confirmNewPasswordController.dispose();
    super.dispose();
  }

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
  }

  CountryCode findCountry(String dialCode) {
    List<CountryCode> countries =
        codes.map((e) => CountryCode.fromJson(e)).toList();

    for (var country in countries) {
      if (country.dialCode == dialCode) {
        return country; 
      }
    }
    return CountryCode(code: "IN", dialCode: "+91", name: "India");
  }

  clearPasswords() {
    newPasswordController.clear();
    oldPasswordController.clear();
    confirmNewPasswordController.clear();
  }

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
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthLoading) {
          if ((_isLoggingOut || _isGlobalLoggingOut) && !_isLoaderShowing) {
            _isLoaderShowing = true;
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (BuildContext context) {
                return PopScope(
                  canPop: false,
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: UIConfig.blurSigmaX, sigmaY: UIConfig.blurSigmaY),
                    child: Container(
                      alignment: FractionalOffset.center,
                      decoration: BoxDecoration(color: Colors.black.withOpacity(UIConfig.opacityBackdrop)),
                      child: SizedBox(
                        width: UIConfig.loaderSize,
                        height: UIConfig.loaderSize,
                        child: LoadingAnimationWidget.hexagonDots(
                          size: UIConfig.loaderSize,
                          color: CommonColors.blue,
                        ),
                      ),
                    ),
                  ),
                );
              },
            );
          }
        } else if (state is AuthUnauthenticated) {
          if (_isLoaderShowing) {
            Navigator.of(context, rootNavigator: true).pop('dialog');
            _isLoaderShowing = false;
          }
          
          if (_isLoggingOut) {
            CustomAlert.showCustomScaffoldMessenger(
              context,
              "Successfully logged out!",
              AlertType.success,
            );
            _isLoggingOut = false;
          } else if (_isGlobalLoggingOut) {
            CustomAlert.showCustomScaffoldMessenger(
              context,
              "Successfully logged out from all devices!",
              AlertType.success,
            );
            _isGlobalLoggingOut = false;
          }
          
          Navigator.of(context).pop();
        } else if (state is AuthError) {
          if (_isLoaderShowing) {
            Navigator.of(context, rootNavigator: true).pop('dialog');
            _isLoaderShowing = false;
          }
          
          _isLoggingOut = false;
          _isGlobalLoggingOut = false;
          
          CustomAlert.showCustomScaffoldMessenger(
            context, 
            state.message, 
            AlertType.error
          );
        }
      },
      child: GestureDetector(
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
          body: MediaQuery.removePadding(
            removeTop: true,
            removeBottom: true,
            context: context,
            child: Builder(
              builder: (context) {
                return Column(
                children: [
                  Expanded(
                    child: BlocBuilder<DashboardBloc, DashboardState>(
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
                  height: UIConfig.accentLineHeight,
                  color: CommonColors.blue2,
                ),
                Expanded(
                  child: SizedBox(
                    width: PlatformUtils.isMobile ? MediaQuery.of(context).size.width : MediaQuery.of(context).size.width / 3,
                    child: SingleChildScrollView(
                      controller: _scrollController,
                      physics: ClampingScrollPhysics(),
                      child: Container(
                        color: Provider.of<ThemeNotifier>(context)
                            .currentTheme
                            .bgColor,
                        child: Column(
                        children: [
                          Container(
                            height: UIConfig.headerSectionHeight,
                            padding: EdgeInsets.only(left: UIConfig.spacingLarge.w, right: (UIConfig.spacingExtraLarge - 1).w),
                            child: Row(
                              children: [
                                MouseRegion(
                                  cursor: SystemMouseCursors.click,
                                  child: GestureDetector(
                                    onTap: () {
                                      Navigator.of(context).pop();
                                    },
                                    child: Container(
                                      height: UIConfig.backButtonHeight,
                                      // width: UIConfig.backButtonWidth,
                                      decoration: BoxDecoration(
                                          shape: BoxShape.rectangle,
                                          borderRadius: UIConfig.borderRadiusCircularMedium,
                                          color: UIConfig.colorTransparent,
                                          border: GradientBoxBorder(
                                            width: UIConfig.chartBorderWidth,
                                            gradient: LinearGradient(
                                              colors: [

                                                CommonColors.blue2,
                                                CommonColors.blue.withOpacity(UIConfig.opacityVeryHigh),
                                                CommonColors.blue,

                                              ],
                                              begin: Alignment.centerLeft,
                                              end: Alignment.centerRight,
                                            ),
                                          )),
                                      child: Center(
                                        child: SvgPicture.asset(
                                          'assets/icons/back_arrow.svg',
                                          height: UIConfig.projectIconHeight,
                                          width: UIConfig.projectIconWidth,
                                          colorFilter: ColorFilter.mode(
                                            Provider.of<ThemeNotifier>(context)
                                                .currentTheme
                                                .basicAdvanceTextColor,
                                            BlendMode.srcIn,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(width: UIConfig.spacingSizedBoxLarge.width),

                                Text(
                                  "PROFILE",
                                  style: GoogleFonts.robotoMono(
                                    fontSize: UIConfig.fontSizeMedium.responsiveSp,
                                    fontWeight: FontWeight.w500,
                                    color: Provider.of<ThemeNotifier>(context).currentTheme.loginTitleColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // User Section
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: UIConfig.spacingMedium.w, vertical: 0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,

                              children: [
                                ChamferedTextWidget(
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
                                  borderColor:
                                  Provider.of<ThemeNotifier>(context)
                                      .currentTheme
                                      .profileBorderColor,
                                  fontSize: ThemeNotifier.medium.responsiveSp,
                                ),

                                Container(
                                  padding: EdgeInsets.symmetric(horizontal: 12.w),

                                  decoration: BoxDecoration(
                                      border: Border.all(
                                        color: Provider.of<ThemeNotifier>(context)
                                            .currentTheme
                                            .profileBorderColor,
                                        width: UIConfig.profileFieldBorderWidth,
                                      )),
                                  child: Column(
                                    children: [
                                      UIConfig.spacingSizedBoxVerticalLarge,
                                      UIConfig.spacingSizedBoxVerticalLarge,
                                      CustomTextField(
                                        controller: _nameController,
                                        iconPath: 'assets/icons/profile2.svg',
                                        hintText: 'Enter Full Name',
                                        keyboardType: TextInputType.name,
                                      ),
                                      UIConfig.spacingSizedBoxVerticalSmall,
                                      CustomTextField(
                                        controller: _emailController,
                                        iconPath: 'assets/icons/mail.svg',
                                        hintText: 'Enter Email',
                                        keyboardType:
                                        TextInputType.emailAddress,
                                      ),
                                      UIConfig.spacingSizedBoxVerticalSmall,
                                      CustomTextField(
                                        controller: _phoneController,
                                        hintText: 'Enter Phone number',
                                        keyboardType: TextInputType.phone,
                                        inputFormatters: [
                                          FilteringTextInputFormatter
                                              .digitsOnly,
                                        ],
                                        prefixIcon: Container(
                                          padding:
                                          UIConfig.paddingFromLTRBWithClamp,
                                          decoration: BoxDecoration(
                                              borderRadius: UIConfig.borderRadiusTopLeft,
                                              color: Colors.transparent),
                                          child: CountryCodePicker2(
                                            refreshPhoneCode: refreshPhoneCode,
                                            dropDownColor:
                                            Provider.of<ThemeNotifier>(
                                                context)
                                                .currentTheme
                                                .textFieldBGProfile,
                                            height: UIConfig.dropdownItemHeight * 0.77,
                                            decoration: BoxDecoration(
                                              color: Colors.transparent,
                                              borderRadius: UIConfig.borderRadiusTopLeft,
                                            ),
                                            onChanged:
                                                (CountryCode countryCode) {
                                              selectedCountryCode = countryCode;
                                            },
                                            getPhoneNumberWithoutCountryCode:
                                                (String phoneNumber) async {
                                              await Future.delayed(
                                                  const Duration(
                                                      milliseconds: 100));
                                              _phoneController.text =
                                                  phoneNumber;
                                            },
                                            initialSelection:
                                            _phoneController.text,
                                          ),
                                        ),
                                      ),
                                      UIConfig.spacingSizedBoxVerticalSmall,
                                      Container(
                                        height: UIConfig.borderWidthThin,
                                        color:
                                        Provider.of<ThemeNotifier>(context)
                                            .currentTheme
                                            .profileBorderColor,
                                      ),
                                      UIConfig.spacingSizedBoxVerticalSmall,
                                      PasswordTextField(
                                        controller: oldPasswordController,
                                        hint: "Enter current password",
                                      ),
                                      UIConfig.spacingSizedBoxVerticalSmall,
                                      PasswordTextField(
                                        controller: newPasswordController,
                                        hint: "Enter new password",
                                      ),
                                      UIConfig.spacingSizedBoxVerticalSmall,
                                      PasswordTextField(
                                        controller:
                                        confirmNewPasswordController,
                                        hint: "Confirm new password",
                                      ),
                                      UIConfig.spacingSizedBoxVerticalLarge,
                                      UIConfig.spacingSizedBoxVerticalLarge,
                                      CustomButton(
                                        dynamicWidth: true,
                                        text: "SUBMIT",
                                        fontSize: ThemeNotifier.medium,
                                        onPressed: () async {
                                          FocusScope.of(context).unfocus();

                                          try {
                                            if (kDebugMode) {
                                            }

                                            checkAllTextFields();
                                          } catch (e) {
                                            if (kDebugMode) {
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

                                      UIConfig.spacingSizedBoxVerticalLarge,
                                      UIConfig.spacingSizedBoxVerticalLarge,


                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          UIConfig.spacingSizedBoxVerticalLarge,
                          UIConfig.spacingSizedBoxVerticalLarge,

                          // Authentication Section
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: UIConfig.spacingMedium.w, vertical: 0),
                            child: Column(
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
                                  borderColor:
                                  Provider.of<ThemeNotifier>(context)
                                      .currentTheme
                                      .profileBorderColor,
                                  fontSize: ThemeNotifier.medium.responsiveSp,
                                ),
                                AuthenticationWidget(
                                  bottomOpen: true,
                                  scrollKey: _twoFactorKey,
                                  scrollController: _scrollController,
                                  onToggle: () {
                                    // Auto-scroll to the 2FA section after the widget is built
                                    WidgetsBinding.instance.addPostFrameCallback((_) {
                                      if (_twoFactorKey.currentContext != null) {
                                        Scrollable.ensureVisible(
                                          _twoFactorKey.currentContext!,
                                          duration: const Duration(milliseconds: 100),
                                          curve: Curves.easeInOut,
                                        );
                                      }
                                    });
                                  },
                                ),
                                BiometricWidget(
                                  topOpen: true,
                                  scrollKey: _biometricKey,
                                  scrollController: _scrollController,
                                  onToggle: () {
                                    // Auto-scroll to the biometric section after the widget is built
                                    WidgetsBinding.instance.addPostFrameCallback((_) {
                                      if (_biometricKey.currentContext != null) {
                                        Scrollable.ensureVisible(
                                          _biometricKey.currentContext!,
                                          duration: const Duration(milliseconds: 100),
                                          curve: Curves.easeInOut,
                                        );
                                      }
                                    });
                                  },
                                ),
                              ],
                            ),
                          ),

                          UIConfig.spacingSizedBoxVerticalLarge,
                          UIConfig.spacingSizedBoxVerticalLarge,

                          // Logout
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: UIConfig.spacingMedium.w, vertical: 0),
                            child: Column(
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
                                  borderColor:
                                  Provider.of<ThemeNotifier>(context)
                                      .currentTheme
                                      .profileBorderColor,
                                  fontSize: ThemeNotifier.medium.responsiveSp,
                                ),
                                Container(
                                    padding: EdgeInsets.symmetric(horizontal: 12.w),
                                    decoration: BoxDecoration(
                                        border: Border.all(
                                          color: Provider.of<ThemeNotifier>(context)
                                              .currentTheme
                                              .profileBorderColor,
                                          width: UIConfig.profileFieldBorderWidth,
                                        )),
                                    child: Column(
                                      children: [
                                        UIConfig.spacingSizedBoxVerticalLarge,
                                        UIConfig.spacingSizedBoxVerticalLarge,
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Expanded(
                                              child: Text(
                                                "Logout from this app",
                                                style: GoogleFonts.roboto(
                                                  fontSize: UIConfig.fontSizeMedium.responsiveSp,
                                                  color: Provider.of<ThemeNotifier>(
                                                      context)
                                                      .currentTheme
                                                      .basicAdvanceTextColor,
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                            CustomButton(
                                              text: "LOGOUT",
                                              dynamicWidth: true,
                                              fontSize: ThemeNotifier.medium,
                                              onPressed: () async {
                                                setState(() {
                                                  _isLoggingOut = true;
                                                });
                                                BlocProvider.of<AuthBloc>(context).add(AuthLogout());
                                              },
                                              isRed: true,
                                            ),
                                          ],
                                        ),
                                        UIConfig.spacingSizedBoxVerticalLarge,
                                        UIConfig.spacingSizedBoxVerticalLarge,
                                      ],
                                    )),
                              ],
                            ),
                          ),

                          UIConfig.spacingSizedBoxVerticalLarge,
                          UIConfig.spacingSizedBoxVerticalLarge,

                          // active seshh
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: UIConfig.spacingMedium.w, vertical: 0),
                            child: Column(
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
                                  borderColor:
                                  Provider.of<ThemeNotifier>(context)
                                      .currentTheme
                                      .profileBorderColor,
                                  fontSize: ThemeNotifier.medium.responsiveSp,
                                ),
                                Container(
                                    padding: EdgeInsets.symmetric(horizontal: 12.w),
                                    decoration: BoxDecoration(
                                        border: Border.all(
                                          color: Provider.of<ThemeNotifier>(context)
                                              .currentTheme
                                              .profileBorderColor,
                                          width: UIConfig.profileFieldBorderWidth,
                                        )),
                                    child: Column(
                                      crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                      children: [
                                        UIConfig.spacingSizedBoxVerticalLarge,
                                        UIConfig.spacingSizedBoxVerticalLarge,
                                        ActiveDevices(key: UniqueKey()),
                                        UIConfig.spacingSizedBoxVerticalLarge,
                                        UIConfig.spacingSizedBoxVerticalLarge,
                                        Row(
                                          mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                          children: [
                                            Expanded(
                                              child: Padding(
                                                padding: UIConfig.paddingProfileFieldRight,
                                                child: Text(
                                                  "Logout from all devices",
                                                  style: GoogleFonts.roboto(
                                                    fontSize: ThemeNotifier.medium.responsiveSp,
                                                    color: Provider.of<
                                                        ThemeNotifier>(
                                                        context)
                                                        .currentTheme
                                                        .basicAdvanceTextColor,
                                                  ),
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ),
                                            ),
                                            CustomButton(
                                              text: "GLOBAL LOGOUT",
                                              dynamicWidth: true,
                                              fontSize: ThemeNotifier.medium,
                                              onPressed: () async {
                                                setState(() {
                                                  _isGlobalLoggingOut = true;
                                                });
                                                BlocProvider.of<AuthBloc>(context).add(AuthGlobalLogout());
                                              },
                                              isRed: true,
                                            ),
                                          ],
                                        ),
                                        UIConfig.spacingSizedBoxVerticalLarge,
                                        UIConfig.spacingSizedBoxVerticalLarge,
                                      ],
                                    )),

                              ],
                            ),
                          ),

                          UIConfig.spacingSizedBoxVerticalLarge,
                          UIConfig.spacingSizedBoxVerticalLarge,

                          // account delete
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: UIConfig.spacingMedium.w, vertical: 0),
                          child: Column(
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
                                borderColor:
                                    Provider.of<ThemeNotifier>(context)
                                        .currentTheme
                                        .profileBorderColor,
                                fontSize: ThemeNotifier.medium.responsiveSp,
                              ),
                              Container(
                                key: _deleteAccountKey,
                                  padding: EdgeInsets.symmetric(horizontal: 12.w),
                                  decoration: BoxDecoration(
                                      border: Border.all(
                                    color: Provider.of<ThemeNotifier>(context)
                                        .currentTheme
                                        .profileBorderColor,
                                    width: UIConfig.profileFieldBorderWidth,
                                  )),
                                  child: Column(
                                    children: [
                                      UIConfig.spacingSizedBoxVerticalLarge,
                                      UIConfig.spacingSizedBoxVerticalLarge,
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: Text(
                                              "Delete your account",
                                              style: GoogleFonts.roboto(
                                                fontSize: ThemeNotifier.medium.responsiveSp,
                                                color: Provider.of<ThemeNotifier>(
                                                        context)
                                                    .currentTheme
                                                    .basicAdvanceTextColor,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          CustomButton(
                                            text: "DELETE",
                                            dynamicWidth: true,
                                            fontSize: ThemeNotifier.medium,
                                            onPressed: () async {
                                              setState(() {
                                                deleteAccountVisible = true;
                                              });
                                              // Auto-scroll to the delete account section after the widget is built
                                              WidgetsBinding.instance.addPostFrameCallback((_) {
                                                if (_deleteAccountKey.currentContext != null) {
                                                  Scrollable.ensureVisible(
                                                    _deleteAccountKey.currentContext!,
                                                    duration: const Duration(milliseconds: 100),
                                                    curve: Curves.easeInOut,
                                                  );
                                                }
                                              });
                                            },
                                            isRed: true,
                                          ),
                                        ],
                                      ),
                                      Visibility(
                                        visible: deleteAccountVisible,
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.center,

                                          children: [
                                            UIConfig.spacingSizedBoxVerticalSmall,
                                            Text(
                                              "Warning: This action is irreversible. You will no longer be able to access your IoT data.",
                                              style: GoogleFonts.roboto(
                                                fontSize: UIConfig.fontSizeExtraSmallResponsive,
                                                color: CommonColors.red,
                                              ),
                                            ),
                                            UIConfig.spacingSizedBoxVerticalLarge,
                                            CustomTextField(controller: deleteConfirmationFieldController, hintText: "Type 'DELETE' to confirm"),
                                            UIConfig.spacingSizedBoxVerticalLarge,
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                CustomButton(
                                                  dynamicWidth: true,
                                                  text: "CANCEL",
                                                  fontSize: ThemeNotifier.medium,
                                                  onPressed: () {
                                                    setState(() {
                                                      deleteAccountVisible = false;
                                                    });

                                                  },
                                                ),
                                                UIConfig.spacingSizedBoxSmall,
                                                CustomButton(
                                                  dynamicWidth: true,
                                                  text: "CONFIRM",
                                                  fontSize: ThemeNotifier.medium,
                                                  onPressed: () {
                                                    if (deleteConfirmationFieldController.text.toUpperCase() == "DELETE") {

                                                      BlocProvider.of<AuthBloc>(context).add(AuthDeleteAccount());
                                                    } else {
                                                      CustomAlert.showCustomScaffoldMessenger(context, "Please type 'DELETE' to confirm.", AlertType.error);
                                                    }
                                                  },
                                                  isRed: true,
                                                ),
                                              ],
                                            )
                                          ],
                                        ),
                                      ),
                                      UIConfig.spacingSizedBoxVerticalLarge,
                                      UIConfig.spacingSizedBoxVerticalLarge,
                                    ],
                                  )),
                              ],
                            ),
                          ),

                          UIConfig.spacingSizedBoxVerticalLarge,
                          UIConfig.spacingSizedBoxVerticalLarge,
                        ],
                      ),
                    ),
                  ),
                ),
              ),
                // Container(
                //   height: UIConfig.accentLineHeight,
                //   color: CommonColors.blue2,
                // ),
              ],
            );
          });
        },
                    ),
                  ),
                Container(
                  color: Colors.black,
                ),
              ],
            );
          },
            ),
        ),
      ),
    ));
  }
}

class AuthenticationWidget extends StatefulWidget {
  const AuthenticationWidget({
    super.key,
    this.topOpen = false,
    this.bottomOpen = false,
    this.scrollKey,
    this.scrollController,
    this.onToggle,
  });

  final bool topOpen;
  final bool bottomOpen;
  final GlobalKey? scrollKey;
  final ScrollController? scrollController;
  final VoidCallback? onToggle;
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
      key: widget.scrollKey,
      padding: EdgeInsets.symmetric(horizontal: 12.w),
      decoration: BoxDecoration(
        border: widget.topOpen
            ? Border(
                left: BorderSide(
                  color: Provider.of<ThemeNotifier>(context)
                      .currentTheme
                      .profileBorderColor,
                  width: UIConfig.profileFieldBorderWidth,
                ),
                right: BorderSide(
                  color: Provider.of<ThemeNotifier>(context)
                      .currentTheme
                      .profileBorderColor,
                  width: UIConfig.profileFieldBorderWidth,
                ),
                bottom: BorderSide(
                  color: Provider.of<ThemeNotifier>(context)
                      .currentTheme
                      .profileBorderColor,
                  width: UIConfig.profileFieldBorderWidth,
                ),
              )
            : widget.bottomOpen
                ? Border(
                    left: BorderSide(
                      color: Provider.of<ThemeNotifier>(context)
                          .currentTheme
                          .profileBorderColor,
                      width: UIConfig.profileFieldBorderWidth,
                    ),
                    right: BorderSide(
                      color: Provider.of<ThemeNotifier>(context)
                          .currentTheme
                          .profileBorderColor,
                      width: UIConfig.profileFieldBorderWidth,
                    ),
                    top: BorderSide(
                      color: Provider.of<ThemeNotifier>(context)
                          .currentTheme
                          .profileBorderColor,
                      width: UIConfig.profileFieldBorderWidth,
                    ),
                  )
                : Border.all(
                    color: Provider.of<ThemeNotifier>(context)
                        .currentTheme
                        .profileBorderColor,
                    width: UIConfig.profileFieldBorderWidth,
                  ),
      ),
      child: Column(
        children: [
          UIConfig.spacingSizedBoxVerticalLarge,
          UIConfig.spacingSizedBoxVerticalLarge,
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  "Two Factor Authentication",
                  style: GoogleFonts.roboto(
                    fontSize: UIConfig.fontSizeMedium.responsiveSp,
                    color: Provider.of<ThemeNotifier>(context)
                        .currentTheme
                        .basicAdvanceTextColor,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              ToggleButtonCustom(
                fillBackground: true,
                key: UniqueKey(),
                index: is2FAEnabled ? 1 : 0,
                dontChangeImmediately: true,
                adjustDesktopPosition: true,
                tabs: const ["NO", "YES"],
                onTap: (int newIndex) {
                  if (newIndex == 1) {
                    if (!is2FAEnabled) {
                      setState(() {
                        showAuthenticationDialog = true;
                        showDisableConfirm = false;
                      });
                      widget.onToggle?.call();
                    }
                  } else {
                    if (is2FAEnabled) {
                      setState(() {
                        showDisableConfirm = true;
                        showAuthenticationDialog = false;
                      });
                      widget.onToggle?.call();
                    }
                  }
                },
                backgroundColor: Provider.of<ThemeNotifier>(context)
                    .currentTheme
                    .toggleColor,
                selectedTextColor: Colors.white,
                unselectedTextColor: Colors.white,
                  width: PlatformUtils.isMobile ? 110.w : 140.w,
                  height: PlatformUtils.isMobile ? 28.h : 30.h,
                  fontSize: ThemeNotifier.medium.responsiveSp,
                tabColor: CommonColors.red,
                tabColor2: const Color(0xFF00BC8A),
              ),
            ],
          ),
          Visibility(
              visible: showDisableConfirm,
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: UIConfig.spacingLarge),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CustomButton(
                      dynamicWidth: true,
                      text: "CANCEL",
                      fontSize: UIConfig.fontSizeSmall,
                      onPressed: () {
                        setState(() {
                          showDisableConfirm = false;
                        });
                      },
                      isRed: true,
                    ),
                    SizedBox(width: UIConfig.spacingXXXLarge.w),
                    CustomButton(
                      dynamicWidth: true,
                      text: "CONFIRM",
                      fontSize: UIConfig.fontSizeSmall,
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
          UIConfig.spacingSizedBoxVerticalLarge,
          UIConfig.spacingSizedBoxVerticalLarge,
          Container(
            height: UIConfig.borderWidthThin,
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
    this.scrollKey,
    this.scrollController,
    this.onToggle,
  });

  final bool topOpen;
  final bool bottomOpen;
  final GlobalKey? scrollKey;
  final ScrollController? scrollController;
  final VoidCallback? onToggle;
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
      
      return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        key: widget.scrollKey,
        padding: EdgeInsets.symmetric(horizontal: 12.w),
        decoration: BoxDecoration(
          border: widget.topOpen
              ? Border(
                  left: BorderSide(
                    color: Provider.of<ThemeNotifier>(context)
                        .currentTheme
                        .profileBorderColor,
                    width: UIConfig.profileFieldBorderWidth,
                  ),
                  right: BorderSide(
                    color: Provider.of<ThemeNotifier>(context)
                        .currentTheme
                        .profileBorderColor,
                    width: UIConfig.profileFieldBorderWidth,
                  ),
                  bottom: BorderSide(
                    color: Provider.of<ThemeNotifier>(context)
                        .currentTheme
                        .profileBorderColor,
                    width: UIConfig.profileFieldBorderWidth,
                  ),
                  top: BorderSide.none,
                )
              : widget.bottomOpen
                  ? Border(
                      left: BorderSide(
                        color: Provider.of<ThemeNotifier>(context)
                            .currentTheme
                            .profileBorderColor,
                        width: UIConfig.profileFieldBorderWidth,
                      ),
                      right: BorderSide(
                        color: Provider.of<ThemeNotifier>(context)
                            .currentTheme
                            .profileBorderColor,
                        width: UIConfig.profileFieldBorderWidth,
                      ),
                      top: BorderSide(
                        color: Provider.of<ThemeNotifier>(context)
                            .currentTheme
                            .profileBorderColor,
                        width: UIConfig.profileFieldBorderWidth,
                      ),
                      bottom: BorderSide.none,
                    )
                  : Border.all(
                      color: Provider.of<ThemeNotifier>(context)
                          .currentTheme
                          .profileBorderColor,
                      width: UIConfig.profileFieldBorderWidth,
                    ),
        ),
        child: Column(
          children: [
            UIConfig.spacingSizedBoxVerticalLarge,
            UIConfig.spacingSizedBoxVerticalLarge,
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    "Biometric Login",
                    style: GoogleFonts.roboto(
                    fontSize: UIConfig.fontSizeMedium.responsiveSp,
                    color: Provider.of<ThemeNotifier>(context)
                          .currentTheme
                          .basicAdvanceTextColor,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                ToggleButtonCustom(
                  fillBackground: true,
                  key: UniqueKey(),
                  index: isBiometricEnabled ? 1 : 0,
                  dontChangeImmediately: true,
                  adjustDesktopPosition: true,
                  tabs: const ["NO", "YES"],
                  onTap: (int newIndex) {
                    if (newIndex == 1) {
                      if (!isBiometricEnabled) {
                        setState(() {
                          showBiometricDialog = true;
                          showDisableConfirm = false;
                        });
                        widget.onToggle?.call();
                      }
                    } else {
                      if (isBiometricEnabled) {
                        setState(() {
                          showDisableConfirm = true;
                          showBiometricDialog = false;
                        });
                        widget.onToggle?.call();
                      }
                    }
                  },
                  backgroundColor: Provider.of<ThemeNotifier>(context)
                      .currentTheme
                      .toggleColor,
                  selectedTextColor: Colors.white,
                  unselectedTextColor: Colors.white,
                  width: PlatformUtils.isMobile ? 110.w : 140.w,
                  height: PlatformUtils.isMobile ? 28.h : 30.h,
                  fontSize: ThemeNotifier.medium.responsiveSp,
                  tabColor: CommonColors.red,
                  tabColor2: const Color(0xFF00BC8A),
                ),
              ],
            ),
            Visibility(
                visible: showDisableConfirm,
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: UIConfig.spacingLarge),
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CustomButton(
                          dynamicWidth: true,
                          text: "CANCEL",
                          fontSize: UIConfig.fontSizeSmall,
                          onPressed: () {
                            setState(() {
                              showDisableConfirm = false;
                            });
                          },
                          isRed: true,
                        ),
                        SizedBox(width: UIConfig.spacingXXXLarge.w),
                        CustomButton(
                          dynamicWidth: true,
                          text: "CONFIRM",
                          fontSize: ThemeNotifier.medium,
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
            UIConfig.spacingSizedBoxVerticalLarge,
            UIConfig.spacingSizedBoxVerticalLarge,
          ],
        ));
  }
}