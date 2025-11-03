import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:watermeter2/bloc/dashboard_bloc.dart';
import 'package:watermeter2/bloc/auth_bloc.dart';
import 'package:watermeter2/bloc/auth_event.dart';
import 'package:watermeter2/bloc/auth_state.dart';
import 'package:watermeter2/services/platform_utils.dart';
import 'package:watermeter2/utils/pok.dart';

import 'package:watermeter2/services/app_state_service.dart';
import 'package:watermeter2/constants/app_config.dart';
import 'package:watermeter2/constants/theme2.dart';
import 'package:watermeter2/utils/alert_message.dart';
import 'package:watermeter2/utils/biometric_helper.dart';
import 'package:watermeter2/utils/misc_functions.dart';
import 'package:watermeter2/utils/toggle_button.dart';
import '../../widgets/chamfered_text_widget.dart';
import '../../widgets/customButton.dart';
import '../../widgets/customTextField.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/password_controller.dart';
import 'register_screen.dart';
import 'two_factor_screen.dart';


class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  @override
  void initState() {
    SystemChrome.setPreferredOrientations(
        [DeviceOrientation.portraitDown, DeviceOrientation.portraitUp]);
    // SystemChrome.setPreferredOrientations(
    //     [DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight]);
    NudronRandomStuff.isSignIn.addListener(() {
      setState(() {});
    });
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   _showEmailConfirmationDialog(context);
    // });
    super.initState();
  }

  List<Widget> pages = [
    const SigninPage(),
    const RegisterPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: SafeArea(
        child: Scaffold(
          appBar: CustomAppBar(
            choiceAction: null,
          ),
          backgroundColor:
              Provider.of<ThemeNotifier>(context).currentTheme.bgColor,
          resizeToAvoidBottomInset: false,
          // Prevents resize when the keyboard appears
          body: SizedBox(
            // color:Colors.green,
            height: 1.sh - 51.h,
            width: 1.sw,
            child: Stack(
              children: [
                Align(
                  alignment: Alignment.bottomCenter,
                  // Keeps the icon at the bottom center
                  child: Transform.rotate(
                    angle: 0,
                    child: SvgPicture.asset(
                      'assets/icons/nfcicon.svg',
                      fit: BoxFit.cover,
                      clipBehavior: Clip.hardEdge,
                      color: CommonColors.blue.withOpacity(0.25),
                      width: PlatformUtils.isMobile ? 450.responsiveSp : 450.0,
                    ),
                  ),
                ),
                Scaffold(
                  backgroundColor: Colors.transparent,
                  resizeToAvoidBottomInset: true,
                  body: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          height: 3.h,
                          color: CommonColors.blue,
                        ),
                        Center(
                          child: SizedBox(
                            width: PlatformUtils.isMobile ? 1.sw : 600,
                            child: Column(
                              children: [
                                SizedBox(height: 20.h),
                                Center(
                                  child: Text(
                                    'Nudron IoT Solutions',
                                    style: GoogleFonts.roboto(
                                        fontSize: PlatformUtils.isMobile ? 37.responsiveSp : 37.0,
                                        fontWeight: FontWeight.bold,
                                        color: Provider.of<ThemeNotifier>(context)
                                            .currentTheme
                                            .loginTitleColor),
                                  ),
                                ),
                                SizedBox(height: 10.h),
                                Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                                  child: Center(
                                    child: Text(
                                        "Welcome to Nudron's Water Metering Dashboard",
                                        textAlign: TextAlign.center,
                                        style: GoogleFonts.roboto(
                                            fontSize: PlatformUtils.isMobile ? ThemeNotifier.medium.responsiveSp : 16.0,
                                            color: Provider.of<ThemeNotifier>(context)
                                                .currentTheme
                                                .basicAdvanceTextColor)),
                                  ),
                                ),
                                SizedBox(height: 20.h),
                                Center(
                                  child: ToggleButtonCustom(
                                    key: UniqueKey(),
                                    tabs: const ["SIGN IN", "REGISTER"],
                                    backgroundColor: null,
                                    selectedTextColor: Colors.white,
                                    unselectedTextColor:
                                        Provider.of<ThemeNotifier>(context)
                                            .currentTheme
                                            .basicAdvanceTextColor,
                                    index: NudronRandomStuff.isSignIn.value ? 0 : 1,
                                    onTap: (index) {
                                      setState(() {
                                        NudronRandomStuff.isSignIn.value = index == 0;
                                      });
                                    },
                                  ),
                                ),
                                SizedBox(height: 40.h),
                                IndexedStack(
                                  index: NudronRandomStuff.isSignIn.value ? 0 : 1,
                                  children: pages,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class SigninPage extends StatefulWidget {
  const SigninPage({super.key});

  @override
  State<SigninPage> createState() => _SigninPageState();
}

class _SigninPageState extends State<SigninPage> {
  void _showEmailConfirmationDialog(BuildContext context) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      // Prevents the dialog from being dismissed by tapping outside
      builder: (BuildContext dialogContext) {
        return AutoLogin(email: emailBiometricSaved!);
      },
    );
  }

  bool isLargerTextField = ConfigurationCustom.isLargerTextField;

  TextEditingController emailController = TextEditingController();

  var passwordControllerObscure = ObscuringTextEditingController();

  bool openForgotPasswordButtons = false;
  double scale = 1.2;

  String getPassword() {
    return passwordControllerObscure.getText();
  }

  @override
  void initState() {
    super.initState();
  }

  String? emailBiometricSaved;

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthLoading) {
          // Loading is handled by main.dart BlocBuilder - no need to show additional loader
        } else if (state is AuthAuthenticated) {
          // Login successful
          CustomAlert.showCustomScaffoldMessenger(
              context, "Successfully logged in!", AlertType.success);
          
          // Reload dashboard data after successful login
          try {
            final dashboardBloc = BlocProvider.of<DashboardBloc>(context, listen: false);
            dashboardBloc.loadInitialData();
          } catch (e) {
            // If dashboard initialization fails, log it but don't block the UI
            // The dashboard will handle the error state
            debugPrint('Error initializing dashboard after login: $e');
          }
        } else if (state is AuthTwoFactorRequired) {
          // Two-factor authentication required
          CustomAlert.showCustomScaffoldMessenger(
              context,
              "Please enter the code sent to your authenticator app/sms",
              AlertType.info);
          
          Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => EnterTwoFacCode(
                    referenceCode: state.refCode,
                  )));
        } else if (state is AuthError) {
          // Show error message
          CustomAlert.showCustomScaffoldMessenger(
              context, state.message, AlertType.error);
        } else if (state is AuthForgotPasswordSent) {
          // Forgot password email sent
          CustomAlert.showCustomScaffoldMessenger(
              context, state.message, AlertType.info);
          
          setState(() {
            openForgotPasswordButtons = false;
          });
        }
      },
      child: Column(
        children: [
        Padding(
            padding: EdgeInsets.only(left: 35.w, right: 35.w),
            child: CustomTextField(
              key: UniqueKey(),
              controller: emailController,
              iconPath: PlatformUtils.isMobile ? 'assets/icons/mail.svg' : null,
              prefixIcon: PlatformUtils.isMobile
                  ? null
                  : Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.w),
                      child: SvgPicture.asset(
                        'assets/icons/mail.svg',
                        height: 20.0,
                        width: 24.0,
                        fit: BoxFit.scaleDown,
                      ),
                    ),
              hintText: 'Enter Email',
              keyboardType: TextInputType.emailAddress,
              style: GoogleFonts.roboto(
                  fontSize: PlatformUtils.isMobile
                      ? ThemeNotifier.medium.responsiveSp
                      : 18.0,
                  color: Provider.of<ThemeNotifier>(context)
                      .currentTheme
                      .textfieldTextColor),
              hintStyle: GoogleFonts.roboto(
                fontSize: PlatformUtils.isMobile
                    ? ThemeNotifier.medium.responsiveSp
                    : 18.0,
                color: Provider.of<ThemeNotifier>(context)
                    .currentTheme
                    .textfieldHintColor,
              ),
            )),
        Visibility(
          visible: openForgotPasswordButtons,
          child: Padding(
            padding: EdgeInsets.only(left: 35.w, right: 35.w),
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 5.h),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        "Forgot Password?",
                        style: GoogleFonts.roboto(
                            fontSize: ThemeNotifier.medium.responsiveSp,
                            fontWeight: FontWeight.w500,
                            color: CommonColors.red),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 5.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CustomButton(
                      width: 130.w,
                      text: "CANCEL",
                      isRed: true,
                      onPressed: () {
                        setState(() {
                          openForgotPasswordButtons = false;
                        });
                      },
                    ),
                    CustomButton(
                      width: 130.w,
                      text: "SEND EMAIL",
                      onPressed: () async {
                        // Trigger forgot password using AuthBloc
                        final authBloc = BlocProvider.of<AuthBloc>(context, listen: false);
                        authBloc.add(AuthForgotPassword(email: emailController.text));
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        LayoutBuilder(builder: (context, constraints) {
          return Visibility(
            visible: !openForgotPasswordButtons,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  children: [
                    Padding(
                        padding: EdgeInsets.only(
                            left: 35.w, right: 35.w, top: 22.h),
                        child: PasswordTextField(
                          controller: passwordControllerObscure,
                          style: GoogleFonts.roboto(
                              fontSize: PlatformUtils.isMobile
                                  ? ThemeNotifier.medium.responsiveSp
                                  : 18.0,
                              color: Provider.of<ThemeNotifier>(context)
                                  .currentTheme
                                  .textfieldTextColor),
                          hintStyle: GoogleFonts.roboto(
                            fontSize: PlatformUtils.isMobile
                                ? ThemeNotifier.medium.responsiveSp
                                : 18.0,
                            color: Provider.of<ThemeNotifier>(context)
                                .currentTheme
                                .textfieldHintColor,
                          ),
                          desktopPrefixIconHeight: 20.0,
                          desktopPrefixIconWidth: 24.0,
                          desktopSuffixIconSize: 18.0,
                        )),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Padding(
                        padding: EdgeInsets.only(right: 35.w, top: 25.h),
                        child: GestureDetector(
                          onTap: () async {
                            if (emailController.text.isNotEmpty) {
                              final bool emailValid =
                                  MiscellaneousFunctions.isEmailValid(
                                      emailController.text);
                              if (emailValid == false) {
                                CustomAlert.showCustomScaffoldMessenger(
                                    context,
                                    "Please enter a valid email",
                                    AlertType.warning);
                                return;
                              } else {
                                setState(() {
                                  openForgotPasswordButtons = true;
                                });
                              }
                            } else {
                              CustomAlert.showCustomScaffoldMessenger(
                                  context,
                                  "Please enter an email",
                                  AlertType.warning);
                            }
                          },
                          child: Text(
                            "Forgot Password?",
                            style: GoogleFonts.roboto(
                                fontSize: ThemeNotifier.medium.responsiveSp,
                                decoration: TextDecoration.underline,
                                decorationColor: CommonColors.red,
                                fontWeight: FontWeight.w500,
                                color: CommonColors.red),
                          ),
                        ),
                      ),
                    ),
                    Container(height: 40.h),
                    Center(
                      child: CustomButton(
                        text: "SIGN IN",
                        // fontSize: 16,
                        // width: 147.64.w,
                        // height: 58.h,
                        dynamicWidth: true,
                        onPressed: () async {
                          FocusScope.of(context).unfocus();
                          
                          // Validate inputs
                          if (ConfigurationCustom.skipAnyAuths == false) {
                            if (emailController.text.isEmpty || getPassword().isEmpty) {
                              CustomAlert.showCustomScaffoldMessenger(
                                  context,
                                  "Please Enter Email and Password",
                                  AlertType.warning);
                              return;
                            }
                            final bool emailValid = MiscellaneousFunctions.isEmailValid(emailController.text);
                            if (emailValid == false) {
                              CustomAlert.showCustomScaffoldMessenger(
                                  context,
                                  "Please enter a valid email",
                                  AlertType.warning);
                              return;
                            }
                          }
      
                          // Trigger login using AuthBloc
                          final authBloc = BlocProvider.of<AuthBloc>(context, listen: false);
                          authBloc.add(AuthLogin(
                            email: emailController.text,
                            password: getPassword(),
                          ));
                        },
                      ),
                    ),
                    Container(height: 40.h),
                  ],
                ),
                // Container(height: 70.h),
                // ((emailBiometricSaved == null) ||
                //         (emailBiometricSaved!.isEmpty))
                //     ? Container()
                Column(
                  children: [
                    Material(
                      //make the splash blue color
                      color: Colors.transparent,
                      child: ElevatedButton(
                        style: ButtonStyle(
                          backgroundColor:
                              MaterialStateProperty.all(Colors.transparent),
                          shadowColor:
                              MaterialStateProperty.all(Colors.transparent),
                          elevation: MaterialStateProperty.all(0),
                          overlayColor:
                              MaterialStateProperty.resolveWith<Color?>(
                            (Set<MaterialState> states) {
                              if (states.contains(MaterialState.pressed)) {
                                return CommonColors.blue
                                    .withOpacity(0.25); // Custom splash color
                              }
                              return null; // Default splash color
                            },
                          ),
                        ),
                        onPressed: () async {
                          emailBiometricSaved = await BiometricHelper.isBiometricEnabled();
                          if (emailBiometricSaved == null || emailBiometricSaved!.isEmpty) {
                            CustomAlert.showCustomScaffoldMessenger(
                                context,
                                "No biometric data saved. Please enable in the profile section on login",
                                AlertType.warning);
                            return;
                          }
                          _showEmailConfirmationDialog(context);
                        },
                        child: Column(
                          children: [
                            Icon(
                              Icons.fingerprint,
                              size: PlatformUtils.isMobile ? 70.responsiveSp : 70.0,
                              color: Provider.of<ThemeNotifier>(context)
                                  .currentTheme
                                  .basicAdvanceTextColor,
                            ),
                            Text(
                              "LOGIN WITH BIOMETRICS",
                              style: GoogleFonts.robotoMono(
                                decoration: TextDecoration.underline,
                                decorationColor:
                                    Provider.of<ThemeNotifier>(context)
                                        .currentTheme
                                        .basicAdvanceTextColor,
                                fontSize: PlatformUtils.isMobile ? ThemeNotifier.small.responsiveSp : 12.0,
                                color: Provider.of<ThemeNotifier>(context)
                                    .currentTheme
                                    .basicAdvanceTextColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 20.h),
                  ],
                )
              ],
            ),
          );
        }),
        // SizedBox(height: 38.h),
      ],
            ),
    );
  }
}

class AutoLogin extends StatefulWidget {
  final String email;

  const AutoLogin({super.key, required this.email});

  @override
  State<AutoLogin> createState() => _AutoLoginState();
}

class _AutoLoginState extends State<AutoLogin> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated) {
          // Login successful
          CustomAlert.showCustomScaffoldMessenger(
              context, "Successfully logged in!", AlertType.success);

          // Reload dashboard data after successful biometric login
          try {
            final dashboardBloc = BlocProvider.of<DashboardBloc>(context, listen: false);
            dashboardBloc.loadInitialData();
          } catch (e) {
            // If dashboard initialization fails, log it but don't block the UI
            // The dashboard will handle the error state
            debugPrint('Error initializing dashboard after biometric login: $e');
          }

          if (mounted) {
            Navigator.of(context).pop();
          }
        } else if (state is AuthTwoFactorRequired) {
          // Two-factor authentication required
          Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => EnterTwoFacCode(
                    referenceCode: state.refCode,
                  )));
        } else if (state is AuthError) {
          // Show error message
          CustomAlert.showCustomScaffoldMessenger(
              context, state.message, AlertType.error);
          Navigator.of(context).pop();
        }
      },
      child: Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(0.0),
        ),
        backgroundColor:
            Provider.of<ThemeNotifier>(context).currentTheme.dialogBG,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(
            color:
                Provider.of<ThemeNotifier>(context).currentTheme.gridLineColor,
            width: 3.responsiveSp,
          ),
        ),
        width: 350.w,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ChamferedTextWidgetInverted(
                  text: "  AUTO LOGIN  ",
                  borderColor: Provider.of<ThemeNotifier>(context)
                      .currentTheme
                      .gridLineColor,
                ),
                IconButton(
                  icon: Icon(
                    Icons.close,
                    color: Provider.of<ThemeNotifier>(context)
                        .currentTheme
                        .gridLineColor,
                  ),
                  onPressed: () {
                    if (mounted) {
                      Navigator.of(context).pop();
                    }
                  },
                ),
              ],
            ),
            SizedBox(height: 20.h),
            Center(
              child: Text(
                "WELCOME BACK! \nLOGIN AS ${widget.email}?",
                textAlign: TextAlign.center,
                style: GoogleFonts.robotoMono(
                  color: Provider.of<ThemeNotifier>(context)
                      .currentTheme
                      .basicAdvanceTextColor,
                  fontSize: ThemeNotifier.small.responsiveSp,
                ),
              ),
            ),
            SizedBox(height: 20.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                CustomButton(
                  text: "NO",
                  isRed: true,
                  onPressed: () {
                    if (mounted) {
                      Navigator.of(context).pop();
                    }
                  },
                ),
                CustomButton(
                  text: "YES",
                  onPressed: () async {
                    // Trigger biometric login using AuthBloc
                    final authBloc = BlocProvider.of<AuthBloc>(context, listen: false);
                    authBloc.add(AuthLoginWithBiometric());
                  },
                ),
              ],
            ),
            SizedBox(height: 20.h),
          ],
        ),
      ),
    ),
    );
  }
}