import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:local_auth/local_auth.dart';
import 'package:watermeter2/main.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../bloc/dashboard_bloc.dart';
import '../../constants/theme2.dart';
import '../../constants/ui_config.dart';
import '../../services/app_state_service.dart';
import '../../utils/alert_message.dart';
import '../../utils/new_loader.dart';
import '../../widgets/customButton.dart';
import 'authenticator.dart';
import '../../api/auth_service.dart';
import '../../utils/biometric_helper.dart';

class TwoFADisabled extends StatefulWidget {
  const TwoFADisabled({super.key, required this.closeFunction});

  final Function closeFunction;

  @override
  State<TwoFADisabled> createState() => _TwoFADisabledState();
}

class _TwoFADisabledState extends State<TwoFADisabled> {
  String image = "";
  String url = "";
  bool showQrCode = false;
  bool showCancelConfirmQrCode = false;
  bool showCancelConfirmSms = false;
  bool showCancelConfirmBiometric = false;

  reset() {
    setState(() {
      showCancelConfirmQrCode = false;
      showCancelConfirmSms = false;
      showCancelConfirmBiometric = false;
    });
  }

  checkIfAlreadyEnabled() async {
    if (NudronRandomStuff.isAuthEnabled.value) {
      CustomAlert.showCustomScaffoldMessenger(mainNavigatorKey.currentContext!,
          "Authentication already enabled", AlertType.error);
      return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final width = UIConfig.getDesktopDrawerWidth(context);
    return Container(
      width: width,
      decoration: BoxDecoration(
        borderRadius: UIConfig.borderRadiusCircularSmall,
      ),
      child: Column(
        children: [
          SizedBox(height: UIConfig.spacingLarge * 1.25.h),
          CustomtwofacRow(
            icon: Icons.lock_outline,
            title: "Authenticator app",
            customRichText: RichText(
              text: TextSpan(
                  style: GoogleFonts.roboto(
                    color: const Color(0xFF00BC8A),
                    fontSize: UIConfig.fontSizeSmallResponsive,
                  ),
                  children: [
                    TextSpan(
                        text: "Recommended! ",
                        style: GoogleFonts.roboto(
                          color: const Color(0xFF00BC8A),
                          fontSize: UIConfig.getResponsiveFontSize(context, UIConfig.fontSizeSmall, desktopWidth: width),
                        )),
                    TextSpan(
                        style: GoogleFonts.roboto(
                          fontSize: UIConfig.getResponsiveFontSize(context, UIConfig.fontSizeSmall, desktopWidth: width),
                          color: Provider.of<ThemeNotifier>(context)
                              .currentTheme
                              .basicAdvanceTextColor,
                        ),
                        text:
                            "Use an app such as Google Authenticator to generate verification codes for added protection"),
                  ]),
            ),
            onTap: () async {
              setState(() {
                showCancelConfirmQrCode = !showCancelConfirmQrCode;
              });
            },
          ),
          Visibility(
            visible: showCancelConfirmQrCode,
            child: Column(
              children: [
                SizedBox(height: UIConfig.spacingLarge * 1.25.h),
                Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  CustomButton(
                    dynamicWidth: true,
                    fontSize: UIConfig.getResponsiveFontSize(context, UIConfig.fontSizeSmall, desktopWidth: width),
                    text: "CANCEL",
                    onPressed: () {
                      setState(() {
                        showCancelConfirmQrCode = false;
                      });
                    },
                    isRed: true,
                  ),
                  SizedBox(width: UIConfig.spacingXXXLarge.w),
                  CustomButton(
                    dynamicWidth: true,
                    fontSize: UIConfig.getResponsiveFontSize(context, UIConfig.fontSizeSmall, desktopWidth: width),
                    text: "CONFIRM",
                    onPressed: () async {
                      if (!await checkIfAlreadyEnabled()) {
                        bool isDarkMode =
                            Provider.of<ThemeNotifier>(context, listen: false)
                                .isDark;
                        LoaderUtility.showLoader(
                                context,
                                LoginPostRequests.enableTwoFactorAuth(
                                    isDarkMode ? 11 : 10))
                            .then((a) {
                          image = a[0]!;
                          url = a[1]!;
                          setState(() {
                            showQrCode = true;
                          });

                          NudronRandomStuff.isAuthEnabled.value = true;
                        }).catchError((e) {
                          CustomAlert.showCustomScaffoldMessenger(
                              mainNavigatorKey.currentContext!,
                              e.toString(),
                              AlertType.error);
                        });

                        reset();
                      }
                    },
                  ),
                ]),
              ],
            ),
          ),
          Visibility(
            visible: showQrCode,
            child: AuthenticatorPage(
              image: image,
              url: url,
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(vertical: UIConfig.spacingSmall.h, horizontal: UIConfig.spacingMedium * 0.83.w),
            child: Divider(
              color: Provider.of<ThemeNotifier>(context)
                  .currentTheme
                  .gridLineColor,
            ),
          ),
          CustomtwofacRow(
            icon: Icons.message,
            title: "Text message (SMS)",
            subtitle:
                "Receive verification codes via text message. We'll send a code to ${BlocProvider.of<DashboardBloc>(context).userInfo.phone}",
            onTap: () async {
              setState(() {
                showCancelConfirmSms = !showCancelConfirmSms;
              });
            },
          ),
          Visibility(
            visible: showCancelConfirmSms,
            child: Padding(
              padding: EdgeInsets.only(top: UIConfig.spacingLarge * 1.25.h),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CustomButton(
                    dynamicWidth: true,
                    fontSize: UIConfig.getResponsiveFontSize(context, UIConfig.fontSizeSmall, desktopWidth: width),
                    text: "CANCEL",
                    onPressed: () {
                      setState(() {
                        showCancelConfirmSms = false;
                      });
                    },
                    isRed: true,
                  ),
                  SizedBox(width: UIConfig.spacingXXXLarge.w),
                  CustomButton(
                    dynamicWidth: true,
                    fontSize: UIConfig.getResponsiveFontSize(context, UIConfig.fontSizeSmall, desktopWidth: width),
                    text: "CONFIRM",
                    onPressed: () async {
                      if (await checkIfAlreadyEnabled()) return;
                      LoaderUtility.showLoader(
                              context, LoginPostRequests.enableTwoFactorAuth(2))
                          .then((s) async {
                        CustomAlert.showCustomScaffoldMessenger(
                            mainNavigatorKey.currentContext!,
                            "Two factor authentication (SMS) enabled",
                            AlertType.success);
                        NudronRandomStuff.isAuthEnabled.value = true;
                      }).catchError((e) {
                        CustomAlert.showCustomScaffoldMessenger(
                            mainNavigatorKey.currentContext!,
                            e.toString(),
                            AlertType.error);
                      })
                        .whenComplete(
                          () {
                            reset();
                            widget.closeFunction();
                          },
                        );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class CustomtwofacRow extends StatefulWidget {
  const CustomtwofacRow(
      {super.key,
      required this.icon,
      required this.title,
      this.subtitle = "",
      required this.onTap,
      this.customRichText});

  final IconData icon;
  final String title;
  final String subtitle;
  final Function onTap;
  final RichText? customRichText;

  @override
  State<CustomtwofacRow> createState() => _CustomtwofacRowState();
}

class _CustomtwofacRowState extends State<CustomtwofacRow> {
  @override
  Widget build(BuildContext context) {
    final width = UIConfig.getDesktopDrawerWidth(context);
    return GestureDetector(
      onTap: () {
        widget.onTap();
      },
      child: Row(
        children: [
          Padding(
            padding: UIConfig.paddingSmall,
            child: Icon(
              widget.icon,
              color: Provider.of<ThemeNotifier>(context)
                  .currentTheme
                  .basicAdvanceTextColor,
            ),
          ),
          SizedBox(width: UIConfig.spacingMedium * 0.83.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.title,
                  style: GoogleFonts.roboto(
                    fontSize: UIConfig.fontSizeMediumResponsive,
                    color: Provider.of<ThemeNotifier>(context)
                        .currentTheme
                        .basicAdvanceTextColor,
                  ),
                ),
                widget.customRichText ??
                    Text(
                      widget.subtitle,
                      style: GoogleFonts.roboto(
                        fontSize: UIConfig.getResponsiveFontSize(context, UIConfig.fontSizeSmall, desktopWidth: width),
                        color: Provider.of<ThemeNotifier>(context)
                            .currentTheme
                            .basicAdvanceTextColor,
                      ),
                    ),
              ],
            ),
          ),
          Padding(
            padding: UIConfig.paddingSmall,
            child: Icon(
              Icons.chevron_right,
              color: Provider.of<ThemeNotifier>(context)
                  .currentTheme
                  .basicAdvanceTextColor,
            ),
          ),
        ],
      ),
    );
  }
}

class BiometricDisabled extends StatefulWidget {
  const BiometricDisabled({super.key, required this.closeFunction});

  final Function closeFunction;

  @override
  State<BiometricDisabled> createState() => _BiometricDisabledState();
}

class _BiometricDisabledState extends State<BiometricDisabled> {
  String image = "";
  String url = "";
  bool showCancelConfirmBiometric = false;
  LocalAuthentication localAuthentication = LocalAuthentication();
  
  reset() {
    setState(() {
      showCancelConfirmBiometric = false;
    });
  }

  Future<bool> checkForFaceID() async {
    List<BiometricType> availableBiometrics =
        await localAuthentication.getAvailableBiometrics();

    BiometricType tobeUsedBiometric = availableBiometrics[0];

    return (tobeUsedBiometric == BiometricType.face);
  }

  checkIfAlreadyEnabled() async {
    if (NudronRandomStuff.isBiometricEnabled.value) {
      CustomAlert.showCustomScaffoldMessenger(mainNavigatorKey.currentContext!,
          "Biometric already enabled", AlertType.error);
      return true;
    }
    return false;
  }

  Future<void> enableBiometric() async {
    BiometricHelper biometricHelper = BiometricHelper();
    bool isSetup = await biometricHelper.isBiometricSetup();
    if (isSetup) {
      await biometricHelper.authenticateWithBiometrics().then((value) async {
        if (value) {
          await biometricHelper.toggleBiometric(true);
          CustomAlert.showCustomScaffoldMessenger(
              mainNavigatorKey.currentContext!,
              "Biometric Authentication Enabled",
              AlertType.success);
        } else {
          CustomAlert.showCustomScaffoldMessenger(
              mainNavigatorKey.currentContext!,
              "Biometric Authentication Failed",
              AlertType.error);
        }
      }).catchError((e) {
        CustomAlert.showCustomScaffoldMessenger(
            mainNavigatorKey.currentContext!, e.toString(), AlertType.error);
      });
    } else {
      CustomAlert.showCustomScaffoldMessenger(
          mainNavigatorKey.currentContext!,
          "Biometric Authentication is not set up on this device",
          AlertType.error);
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = UIConfig.getDesktopDrawerWidth(context);
    return Container(
      decoration: BoxDecoration(
        borderRadius: UIConfig.borderRadiusCircularSmall,
      ),
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(vertical: UIConfig.spacingSmall.h, horizontal: UIConfig.spacingMedium * 0.83.w),
          ),
          CustomtwofacRow(
            icon: Icons.fingerprint,
            title: "Fingerprint / Face ID",
            subtitle:
                "Log in without a password using your Fingerprint or Face ID",
            
            onTap: () async {
              setState(() {
                showCancelConfirmBiometric = !showCancelConfirmBiometric;
              });
            },
          ),
          Visibility(
            visible: showCancelConfirmBiometric,
            child: Padding(
              padding: EdgeInsets.only(top: UIConfig.spacingLarge * 1.25.h),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CustomButton(
                    dynamicWidth: true,
                    fontSize: UIConfig.getResponsiveFontSize(context, UIConfig.fontSizeSmall, desktopWidth: width),
                    text: "CANCEL",
                    onPressed: () {
                      setState(() {
                        showCancelConfirmBiometric = false;
                      });
                    },
                    isRed: true,
                  ),
                  SizedBox(width: UIConfig.spacingXXXLarge.w),
                  CustomButton(
                    dynamicWidth: true,
                    fontSize: UIConfig.getResponsiveFontSize(context, UIConfig.fontSizeSmall, desktopWidth: width),
                    text: "CONFIRM",
                    onPressed: () async {
                      if (await checkIfAlreadyEnabled()) return;
                      enableBiometric();
                      reset();
                      widget.closeFunction();
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
