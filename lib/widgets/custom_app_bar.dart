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

class CustomAppBar extends StatefulWidget implements PreferredSizeWidget {

  final void Function(dynamic)? choiceAction;
  final bool isProfile;
  const CustomAppBar({super.key, required this.choiceAction, this.isProfile = false});

  @override
  _CustomAppBarState createState() => _CustomAppBarState();

  @override
  Size get preferredSize => Size.fromHeight(50.h); 
}

class _CustomAppBarState extends State<CustomAppBar> {
  
  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final topPadding = mediaQuery.padding.top;
    
    return PreferredSize(
        preferredSize: Size.fromHeight(50.h + topPadding),
        child: Container(
          color: Colors.transparent,
          child: Column(
            children: [
              
              Container(
                height: topPadding,
                color: Provider.of<ThemeNotifier>(context).currentTheme.bgColor,
              ),
              Container(
                height: 50.h,
                color: Provider.of<ThemeNotifier>(context).currentTheme.bgColor,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        SizedBox(width: 12.w),
                        Image.asset(
                          "assets/icons/nudronlogo.png",
                          width: 34.responsiveSp,
                          height: 34.responsiveSp,
                          fit: BoxFit.cover,
                          color: Provider.of<ThemeNotifier>(context)
                              .currentTheme
                              .loginTitleColor,
                        ),
                        SizedBox(width: 10.w),
                        Text("WATER METERING",
                            
                            style: GoogleFonts.robotoMono(
                              fontSize: 24.responsiveSp,
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
                            borderRadius: BorderRadius.circular(50.r),
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
                                size: 28.responsiveSp,
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
                                  borderRadius: BorderRadius.circular(50.r),
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
                                      width: 28.responsiveSp,
                                      height: 28.responsiveSp,
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