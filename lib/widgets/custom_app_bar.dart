import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:watermeter2/utils/pok.dart';
import '../../bloc/auth_bloc.dart';
import '../../bloc/auth_state.dart';
import '../../constants/theme2.dart';
import '../../constants/ui_config.dart';

class CustomAppBar extends StatefulWidget implements PreferredSizeWidget {

  final void Function(dynamic)? choiceAction;
  final bool isProfile;
  const CustomAppBar({super.key, required this.choiceAction, this.isProfile = false});

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
                color: Colors.black,
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
                        Image.asset(
                          "assets/icons/nudronlogo.png",
                          width: UIConfig.iconSizeAppBarLogo,
                          height: UIConfig.iconSizeAppBarLogo,
                          fit: BoxFit.cover,
                          color: Provider.of<ThemeNotifier>(context)
                              .currentTheme
                              .loginTitleColor,
                        ),
                        SizedBox(width: UIConfig.spacingAppBarLogo),
                        Text("WATER METERING",
                            
                            style: GoogleFonts.robotoMono(
                              fontSize: UIConfig.fontSizeLargeResponsive,
                              fontWeight: FontWeight.w500,
                              color: Provider.of<ThemeNotifier>(context)
                                  .currentTheme
                                  .loginTitleColor,
                            )),
                      ],
                    ),
                    Row(
                      children: [
                        
                        Material(
                          color: Colors.transparent,
                          
                          child: InkWell(
                            borderRadius: UIConfig.borderRadiusAppBarIcon,
                            onTap: Provider.of<ThemeNotifier>(context)
                                .toggleTheme,
                            splashColor: Provider.of<ThemeNotifier>(context,
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
                                top: ((51.h - 28.responsiveSp) / 2).clamp(0.0, double.infinity),
                                bottom: ((51.h - 28.responsiveSp) / 2).clamp(0.0, double.infinity),
                                left: 11.w,
                              ),
                              child: Icon(
                                Icons.contrast,
                                size: UIConfig.iconSizeAppBarIcon,
                                color: Provider.of<ThemeNotifier>(context)
                                    .currentTheme
                                    .loginTitleColor,
                              ),
                            ),
                          ),
                        ),
                        
                        BlocBuilder<AuthBloc, AuthState>(
                          builder: (context, state) {
                            bool isUserLoggedIn = state is AuthAuthenticated;
                            
                            if (isUserLoggedIn)
                              return Material(
                                color:Colors.transparent,
                                child: InkWell(
                                  borderRadius: UIConfig.borderRadiusAppBarIcon,
                                  onTap: () {
                                    if (widget.choiceAction != null) {
                                      widget.choiceAction!(0); 
                                    }
                                  },
                                  splashColor: Provider.of<ThemeNotifier>(context,
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
                                      top: ((51.h - 28.responsiveSp) / 2).clamp(0.0, double.infinity),
                                      bottom: ((51.h - 28.responsiveSp) / 2).clamp(0.0, double.infinity),
                                      left: 11.w,
                                    ),
                                    child: SvgPicture.asset(
                                      "assets/icons/profile2.svg",
                                      width: UIConfig.iconSizeAppBarIcon,
                                      height: UIConfig.iconSizeAppBarIcon,
                                      color: widget.isProfile
                                          ? CommonColors.blue2
                                          : Provider.of<ThemeNotifier>(context)
                                              .currentTheme
                                              .loginTitleColor,
                                    ),  
                                    
                                  ),
                                ),
                              );
                            
                            return SizedBox.shrink();
                          },
                        ),
                                    
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