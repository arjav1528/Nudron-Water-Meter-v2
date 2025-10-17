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
  CustomAppBar({super.key, required this.choiceAction, this.isProfile = false});


  @override
  _CustomAppBarState createState() => _CustomAppBarState();

  @override
  Size get preferredSize => Size.fromHeight(51.h);
}

class _CustomAppBarState extends State<CustomAppBar> {
  
  @override
  Widget build(BuildContext context) {
    return PreferredSize(
        preferredSize: Size.fromHeight(50.h),
        child: Container(
          color: Colors.transparent,
          child: Column(
            children: [
              Container(
                height: 50.h,
                color: Provider.of<ThemeNotifier>(context).currentTheme.bgColor,
                child: Container(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        child: Row(
                          children: [
                            SizedBox(width: 12.w),
                            Container(
                              child: Image.asset(
                                "assets/icons/nudronlogo.png",
                                width: 34.minSp,
                                height: 34.minSp,
                                fit: BoxFit.cover,
                                color: Provider.of<ThemeNotifier>(context)
                                    .currentTheme
                                    .loginTitleColor,
                              ),
                            ),
                            SizedBox(width: 10.w),
                            Container(
                              // color: Colors.blue,
                              child: Text("WATER METERING",
                                  // textAlign: TextAlign.center,
                                  style: GoogleFonts.robotoMono(
                                    fontSize: 24.minSp,
                                    fontWeight: FontWeight.w500,
                                    color: Provider.of<ThemeNotifier>(context)
                                        .currentTheme
                                        .loginTitleColor,
                                  )),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        child: Row(
                          children: [
                            // Theme toggle button
                            Material(
                              color: Colors.transparent,
                              // Set this to transparent to only show the splash

                              child: InkWell(
                                borderRadius: BorderRadius.circular(50.r),
                                onTap: Provider.of<ThemeNotifier>(context)
                                    .toggleTheme,
                                splashColor: Provider.of<ThemeNotifier>(context,
                                    listen: false)
                                    .currentTheme
                                    .splashColor,

                                // Customize the splash color
                                highlightColor: Provider.of<ThemeNotifier>(
                                    context,
                                    listen: false)
                                    .currentTheme
                                    .splashColor,
                                // Customize the highlight color
                                child: Padding(
                                  padding: EdgeInsets.only(
                                    right: 11.w,
                                    top: (51.h - 28.minSp) / 2,
                                    bottom: (51.h - 28.minSp) / 2,
                                    left: 11.w,
                                  ),
                                  child: Icon(
                                    Icons.contrast,
                                    size: 28.minSp,
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
                                          widget.choiceAction!(0); // 0 is for profile
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
                                          top: (51.h - 28.minSp) / 2,
                                          bottom: (51.h - 28.minSp) / 2,
                                          left: 11.w,
                                        ),
                                        child: SvgPicture.asset(
                                          "assets/icons/profile2.svg",
                                          width: 28.minSp,
                                          height: 28.minSp,
                                          color: widget.isProfile
                                              ? CommonColors.blue2
                                              : Provider.of<ThemeNotifier>(context)
                                                  .currentTheme
                                                  .loginTitleColor,
                                        ),  
                                        
                                      ),
                                    ),
                                  );
                                
                                return const SizedBox.shrink();
                              },
                            ),


                            // if (widget.choiceAction == null)
                            //   Container(width: 5.w)
                            // else
                            //   Container(
                            //     color: Colors.transparent,
                            //     child: Center(
                            //       child: Material(
                            //         color: Colors.transparent,
                            //         // borderRadius: BorderRadius.circular(5.r),
                            //         child: Theme(
                            //           data: Theme.of(context).copyWith(
                            //             splashColor:
                            //             Provider.of<ThemeNotifier>(context, listen: false)
                            //                 .currentTheme
                            //                 .splashColor,
                            //             splashFactory: InkRipple.splashFactory,
                            //             // Customize the splash color
                            //             highlightColor:
                            //             Provider.of<ThemeNotifier>(context, listen: false)
                            //                 .currentTheme
                            //                 .splashColor,
                            //           ),
                            //           child: PopupMenuButton(
                            //               // enableFeedback: true,
                            //               // shape: RoundedRectangleBorder(
                            //               //     borderRadius:
                            //               //         BorderRadius.circular(50)),
                            //               // splashRadius: 50,
                            //               offset: Offset(0, (51.h)),
                            //               padding: EdgeInsets.zero,
                            //               color: Provider.of<ThemeNotifier>(
                            //                       context)
                            //                   .currentTheme
                            //                   .dropDownColor,
                            //               onSelected: widget.choiceAction,
                            //               //rectangle border with color
                            //               shape: RoundedRectangleBorder(
                            //                   borderRadius:
                            //                       BorderRadius.circular(0),
                            //                   side: BorderSide(
                            //                       width: 2.minSp,
                            //                       color: CommonColors.blue)),
                            //               itemBuilder: (context2) {
                            //                 return <PopupMenuEntry>[
                            //                   PopupMenuItem(
                            //                     value: 0,
                            //                     height: 0,
                            //                     padding: EdgeInsets.only(
                            //                         top: 16.h - 8,
                            //                         right: 12,
                            //                         bottom: 10.5.h,
                            //                         left: 12),
                            //                     child: Text('PROFILE',
                            //                         style:
                            //                             GoogleFonts.robotoMono(
                            //                           fontSize: ThemeNotifier
                            //                               .small.minSp,
                            //                           fontWeight:
                            //                               FontWeight.w500,
                            //                           color: Provider.of<
                            //                                       ThemeNotifier>(
                            //                                   context,
                            //                                   listen: false)
                            //                               .currentTheme
                            //                               .tableText,
                            //                         )),
                            //                   ),
                            //                   PopupMenuItem(
                            //                     value: 1,
                            //                     height: 0,
                            //                     padding: EdgeInsets.only(
                            //                         top: 10.5.h,
                            //                         right: 12,
                            //                         bottom: 5.h,
                            //                         left: 12),
                            //                     child: Text('LOGOUT',
                            //                         style:
                            //                             GoogleFonts.robotoMono(
                            //                           fontSize: ThemeNotifier
                            //                               .small.minSp,
                            //                           fontWeight:
                            //                               FontWeight.w500,
                            //                           color: Provider.of<
                            //                                       ThemeNotifier>(
                            //                                   context,
                            //                                   listen: false)
                            //                               .currentTheme
                            //                               .tableText,
                            //                         )),
                            //                   ),
                            //                 ];
                            //               },
                            //               child: Container(
                            //                 padding: EdgeInsets.only(
                            //                   right: 16.w,
                            //                   left: 11.w,
                            //                   top: (51.h - 28.minSp) / 2,
                            //                   bottom: (51.h - 28.minSp) / 2,
                            //                 ),
                            //                 child: SvgPicture.asset(
                            //                   "assets/icons/hamburger.svg",
                            //                   width: 26.minSp,
                            //                   height: 26.minSp,
                            //                   color: Provider.of<ThemeNotifier>(
                            //                           context)
                            //                       .currentTheme
                            //                       .loginTitleColor,
                            //                 ),
                            //               )),
                            //         ),
                            //       ),
                            //     ),
                            //   ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ),
              //line
              // Padding(
              //   padding: const EdgeInsets.all(0.0),
              //   child: Container(
              //     height: 2.h,
              //     color: const Color(0xFFB3B3B3),
              //   ),
              // ),
            ],
          ),
        ));
  }
}