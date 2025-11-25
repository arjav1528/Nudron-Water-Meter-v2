import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:watermeter2/services/platform_utils.dart';
import 'package:watermeter2/utils/pok.dart';
import '../../bloc/auth_bloc.dart';
import '../../bloc/auth_state.dart';
import '../../constants/theme2.dart';
import '../../constants/ui_config.dart';

class CustomAppBar extends StatefulWidget implements PreferredSizeWidget {
  final void Function(dynamic)? choiceAction;
  final bool isProfile;
  const CustomAppBar(
      {super.key, required this.choiceAction, this.isProfile = false});

  @override
  _CustomAppBarState createState() => _CustomAppBarState();

  @override
  Size get preferredSize => Size.fromHeight(UIConfig.appBarHeight);
}

class _CustomAppBarState extends State<CustomAppBar> {
  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final topPadding = mediaQuery.padding.top;
    

    return PreferredSize(
        preferredSize: Size.fromHeight(UIConfig.appBarHeight + topPadding),
        child: Container(
          color: Colors.transparent,
          child: Column(
            children: [
              
              Container(
                height: topPadding,
                color: Provider.of<ThemeNotifier>(context).currentTheme.bgColor,
              ),
              Container(
                height: UIConfig.appBarHeight,
                color: Provider.of<ThemeNotifier>(context).currentTheme.bgColor,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        SizedBox(width: UIConfig.spacingMedium),
                        SvgPicture.asset(
                          "assets/icons/nudronlogo.svg",
                          width: UIConfig.getResponsiveAppBarLogoSize(context),
                          height: UIConfig.getResponsiveAppBarLogoSize(context),
                          colorFilter: ColorFilter.mode(
                            Provider.of<ThemeNotifier>(context)
                                .currentTheme
                                .loginTitleColor,
                            BlendMode.srcIn,
                          ),
                        ),
                        SizedBox(width: UIConfig.spacingAppBarLogo),
                        Text("WATER METERING",
                            style: GoogleFonts.robotoMono(
                              fontSize: UIConfig.fontSizeExtraLargeResponsive,
                              fontWeight: FontWeight.w500,
                              letterSpacing: UIConfig.letterSpacingSp,
                              color: Provider.of<ThemeNotifier>(context)
                                  .currentTheme
                                  .loginTitleColor,
                            )),
                      ],
                    ),
                    Row(
                      children: [
                        Consumer<ThemeNotifier>(
                          builder: (context, themeNotifier, child) {
                            
                            
                            
                            final splashColor = themeNotifier.isDark
                                ? Colors.black.withOpacity(0.4) 
                                : Colors.white.withOpacity(0.4); 
                            
                            return Material(
                              color: Colors.transparent,
                              child: InkWell(
                                borderRadius: UIConfig.borderRadiusAppBarIcon,
                                onTap: themeNotifier.toggleTheme,
                                splashColor: splashColor,
                                highlightColor: splashColor,
                                child: Padding(
                                  padding: EdgeInsets.only(
                                    right: 11.w,
                                    top: 11.w,
                                    bottom: 11.w,
                                    left: 11.w,
                                  ),
                                  child: Icon(
                                    Icons.contrast,
                                    size: 28.responsiveSp,
                                    color: themeNotifier.currentTheme.loginTitleColor,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                        
                        BlocBuilder<AuthBloc, AuthState>(
                          builder: (context, state) {
                            bool isUserLoggedIn = state is AuthAuthenticated;

                            if (isUserLoggedIn)
                              return Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  borderRadius: UIConfig.borderRadiusAppBarIcon,
                                  onTap: () {
                                    if (widget.choiceAction != null) {
                                      widget.choiceAction!(0);
                                    }
                                  },
                                  splashColor: Provider.of<ThemeNotifier>(
                                          context,
                                          listen: false)
                                      .currentTheme
                                      .splashColor,
                                  highlightColor: Provider.of<ThemeNotifier>(
                                          context,
                                          listen: false)
                                      .currentTheme
                                      .splashColor,
                                  child: Padding(
                                    padding: EdgeInsets.only(
                                      right: 11.w,
                                      top: 11.w,
                                      bottom: 11.w,
                                      left: 11.w,
                                    ),
                                    child: SizedBox(
                                      width: 28.responsiveSp,
                                      height: 28.responsiveSp,
                                      child: SvgPicture.asset(
                                        "assets/icons/profile2.svg",
                                        width: 28.responsiveSp,
                                        height: 28.responsiveSp,
                                        colorFilter: ColorFilter.mode(
                                          widget.isProfile
                                              ? CommonColors.blue2
                                              : Provider.of<ThemeNotifier>(
                                                      context)
                                                  .currentTheme
                                                  .loginTitleColor,
                                          BlendMode.srcIn,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              );

                            return SizedBox.shrink();
                          },
                        ),
                        SizedBox(
                            width: UIConfig.spacingXSmall -
                                (PlatformUtils.isMobile ? 2.5.w : 4.w)),
                      ],
                    )
                  ],
                ),
              ),
            ],
          ),
        ));
  }
}
