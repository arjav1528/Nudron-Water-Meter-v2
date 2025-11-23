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
import 'package:watermeter2/constants/ui_config.dart';
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
    
    NudronRandomStuff.isSignIn.addListener(() {
      setState(() {});
    });
    
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
      child: Scaffold(
        appBar: CustomAppBar(
          choiceAction: null,
        ),
        backgroundColor:
            Provider.of<ThemeNotifier>(context).currentTheme.bgColor,
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
                  child: Column(
                    children: [
                      Container(
                        height: UIConfig.accentLineHeight,
                        color: UIConfig.accentColorBlue,
                      ),
                      Expanded(
                child: Stack(
                children: [
                  Align(
                    alignment: Alignment.bottomCenter,
                    
                    child: Transform.rotate(
                      angle: 0,
                      child: SvgPicture.asset(
                        'assets/icons/nfcicon.svg',
                        fit: BoxFit.cover,
                        clipBehavior: Clip.hardEdge,
                        color: UIConfig.accentColorBlue.withOpacity(UIConfig.opacityMedium),
                        width: UIConfig.getResponsiveIconSize(450.responsiveSp, desktopSize: 450.0),
                      ),
                    ),
                  ),
                  SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: SizedBox(
                            width: MediaQuery.of(context).size.width / 3,
                            child: Column(
                              children: [
                                SizedBox(height: UIConfig.spacingExtraLarge),
                                Center(
                                  child: Text(
                                    'Nudron IoT Solutions',
                                    style: GoogleFonts.roboto(
                                        fontSize: 37.responsiveSp,
                                        fontWeight: FontWeight.bold,
                                        color: Provider.of<ThemeNotifier>(context)
                                            .currentTheme
                                            .loginTitleColor),
                                  ),
                                ),
                                SizedBox(height: UIConfig.spacingLoginTitle),
                                Padding(
                                  padding: UIConfig.paddingTextFieldHorizontal,
                                  child: Center(
                                    child: Text(
                                        "Welcome to Nudron's Water Metering Dashboard",
                                        textAlign: TextAlign.center,
                                        style: GoogleFonts.roboto(
                                            fontSize: ThemeNotifier.medium.responsiveSp,
                                            color: Provider.of<ThemeNotifier>(context)
                                                .currentTheme
                                                .basicAdvanceTextColor)),
                                  ),
                                ),
                                SizedBox(height: UIConfig.spacingExtraLarge),
                                LayoutBuilder(
                                  builder: (context, constraints) {
                                    final toggleWidth = constraints.maxWidth * 0.6;
                                    return Center(
                                      child: ToggleButtonCustom(
                                        key: UniqueKey(),
                                        tabs: const ["SIGN IN", "REGISTER"],
                                        backgroundColor: CommonColors.blue,
                                        fontSize: ThemeNotifier.large.responsiveSp,
                                        width: toggleWidth,
                                        height: 50.91.responsiveSp,
                                        smallerWidth: (toggleWidth / 2) - 12,
                                        smallerHeight: 35.responsiveSp,
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
                                    );
                                  },
                                ),
                                SizedBox(height: UIConfig.spacingXXXLarge),
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
                ],
              ),
            ),
                    ],
                  ),
                ),
                // Container(
                //   height: UIConfig.accentLineHeight,
                //   color: UIConfig.accentColorBlue,
                // ),
              ],
            );
          },
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
          
        } else if (state is AuthAuthenticated) {
          
          // Success message is shown in main.dart after navigation completes
          // to ensure it displays properly after route changes
          
          try {
            final dashboardBloc = BlocProvider.of<DashboardBloc>(context, listen: false);
            dashboardBloc.loadInitialData();
          } catch (e) {
            
            debugPrint('Error initializing dashboard after login: $e');
          }
        } else if (state is AuthTwoFactorRequired) {
          
          CustomAlert.showCustomScaffoldMessenger(
              context,
              "Please enter the code sent to your authenticator app/sms",
              AlertType.info);
          
          Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => EnterTwoFacCode(
                    referenceCode: state.refCode,
                  )));
        } else if (state is AuthError) {
          
          CustomAlert.showCustomScaffoldMessenger(
              context, state.message, AlertType.error);
        } else if (state is AuthForgotPasswordSent) {
          
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
            padding: EdgeInsets.only(left: UIConfig.paddingHorizontalExtraLarge, right: UIConfig.paddingHorizontalExtraLarge),
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
                        height: 20.0.h,
                        width: 24.0.w,
                        fit: BoxFit.scaleDown,
                      ),
                    ),
              hintText: 'Enter Email',
              keyboardType: TextInputType.emailAddress,
              style: GoogleFonts.roboto(
                  fontSize: ThemeNotifier.medium.responsiveSp,
                  color: Provider.of<ThemeNotifier>(context)
                      .currentTheme
                      .textfieldTextColor),
              hintStyle: GoogleFonts.roboto(
                fontSize: ThemeNotifier.medium.responsiveSp,
                color: Provider.of<ThemeNotifier>(context)
                    .currentTheme
                    .textfieldHintColor,
              ),
            )),
        Visibility(
          visible: openForgotPasswordButtons,
          child: Padding(
            padding: EdgeInsets.only(left: UIConfig.paddingHorizontalExtraLarge, right: UIConfig.paddingHorizontalExtraLarge),
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(vertical: UIConfig.spacingForgotPasswordVertical),
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
                SizedBox(height: UIConfig.spacingForgotPasswordVertical),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CustomButton(
                      // width: UIConfig.buttonWidthForgotPassword,
                      dynamicWidth: true,
                      text: "CANCEL",
                      isRed: true,
                      onPressed: () {
                        setState(() {
                          openForgotPasswordButtons = false;
                        });
                      },
                    ),
                    CustomButton(
                      // width: UIConfig.buttonWidthForgotPassword,
                      dynamicWidth: true,
                      text: "SEND EMAIL",
                      onPressed: () async {
                        
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
                            left: UIConfig.paddingHorizontalExtraLarge, right: UIConfig.paddingHorizontalExtraLarge, top: UIConfig.paddingVerticalExtraLarge),
                        child: PasswordTextField(
                          controller: passwordControllerObscure,
                          style: GoogleFonts.roboto(
                              fontSize: ThemeNotifier.medium.responsiveSp,
                              color: Provider.of<ThemeNotifier>(context)
                                  .currentTheme
                                  .textfieldTextColor),
                          hintStyle: GoogleFonts.roboto(
                            fontSize: ThemeNotifier.medium.responsiveSp,
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
                        padding: EdgeInsets.only(right: UIConfig.paddingHorizontalExtraLarge, top: UIConfig.spacingForgotPasswordTop),
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
                    Container(height: UIConfig.spacingXXXLarge),
                    Center(
                      child: CustomButton(
                        dynamicWidth: true,
                        text: "SIGN IN",
                        
                        
                        onPressed: () async {
                          FocusScope.of(context).unfocus();
                          
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
      
                          final authBloc = BlocProvider.of<AuthBloc>(context, listen: false);
                          authBloc.add(AuthLogin(
                            email: emailController.text,
                            password: getPassword(),
                          ));
                        },
                      ),
                    ),
                    Container(height: UIConfig.spacingXXXLarge),
                  ],
                ),
                
                Column(
                  children: [
                    Material(
                      
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
                                    .withOpacity(UIConfig.opacityMedium); 
                              }
                              return null; 
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
                              size: 70.responsiveSp,
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
                                fontSize: ThemeNotifier.small.responsiveSp,
                                color: Provider.of<ThemeNotifier>(context)
                                    .currentTheme
                                    .basicAdvanceTextColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: UIConfig.spacingExtraLarge),
                  ],
                )
              ],
            ),
          );
        }),
        
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
        if (state is AuthLoading) {
          // Close the dialog immediately when loading starts (after successful biometric scan)
          if (mounted) {
            Navigator.of(context).pop();
          }
        } else if (state is AuthAuthenticated) {
          
          CustomAlert.showCustomScaffoldMessenger(
              context, "Successfully logged in!", AlertType.success);

          try {
            final dashboardBloc = BlocProvider.of<DashboardBloc>(context, listen: false);
            if (dashboardBloc.projects.isEmpty) {
              dashboardBloc.loadInitialData();
            }
          } catch (e) {
            
            debugPrint('Error initializing dashboard after biometric login: $e');
          }

          if (mounted) {
            Navigator.of(context).pop();
          }
        } else if (state is AuthTwoFactorRequired) {
          // Close the dialog - navigation to 2FA screen is handled in main.dart
          if (mounted) {
            Navigator.of(context).pop();
          }
        } else if (state is AuthError) {
          
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
            width: UIConfig.dialogBorderWidth,
          ),
        ),
        width: UIConfig.getDesktopDialogWidth(context),
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
            SizedBox(height: UIConfig.spacingExtraLarge),
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
            SizedBox(height: UIConfig.spacingExtraLarge),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                CustomButton(
                  text: "NO",
                  dynamicWidth: true,
                  isRed: true,
                  onPressed: () {
                    if (mounted) {
                      Navigator.of(context).pop();
                    }
                  },
                ),
                CustomButton(
                  text: "YES",
                  dynamicWidth: true,
                  onPressed: () async {
                    
                    final authBloc = BlocProvider.of<AuthBloc>(context, listen: false);
                    authBloc.add(AuthLoginWithBiometric());
                  },
                ),
              ],
            ),
            SizedBox(height: UIConfig.spacingExtraLarge),
          ],
        ),
      ),
    ),
    );
  }
}