import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../utils/pok.dart';
import '../../screens/profile/profile_drawer.dart';
import '../../constants/theme2.dart';
import '../../widgets/custom_app_bar.dart';


class DrawerWithAlert extends StatefulWidget {
  final int drawerIndex;
  final List<String> drawerName;

  const DrawerWithAlert({super.key, 
    required this.drawerIndex,
    required this.drawerName,
  });

  @override
  _DrawerWithAlertState createState() => _DrawerWithAlertState();
}

class _DrawerWithAlertState extends State<DrawerWithAlert> {
  @override
  Widget build(BuildContext context) {
    List<Widget> list = [
      // ProfileDrawer(),
      const ProfileDrawer(),
    ];
    return SafeArea(
      child: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: Scaffold(
          backgroundColor: Provider.of<ThemeNotifier>(context).currentTheme.bgColor,
          body: Container(
              child: Column(
            children: [
              // CustomAppBar outside the scrollable region
              CustomAppBar(choiceAction: null),

              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Container(
                        color: Provider.of<ThemeNotifier>(context)
                            .currentTheme
                            .bgColor,
                        child: Padding(
                          padding: EdgeInsets.only(left: 10.w, right: 10.w),
                          child: Stack(
                            children: [
                              Container(),
                              Align(
                                alignment: Alignment.topLeft,
                                child: IconButton(
                                  icon: Icon(
                                    Icons.arrow_back_ios,
                                    color: Provider.of<ThemeNotifier>(context)
                                        .currentTheme
                                        .drawerHeadingColor,
                                    size: 24.minSp,
                                  ),
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                ),
                              ),



                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Center(
                                  child: Text(
                                    widget.drawerName[widget.drawerIndex],
                                    style: GoogleFonts.roboto(
                                      fontSize: 24.minSp,
                                      fontWeight: FontWeight.bold,
                                      color:
                                          Provider.of<ThemeNotifier>(context)
                                              .currentTheme
                                              .drawerHeadingColor,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      // Padding(
                      //   padding: const EdgeInsets.all(0.0),
                      //   child: Container(
                      //     height: 1.h,
                      //     color: Color(0xFFB3B3B3),
                      //   ),
                      // ),
                      widget.drawerIndex >= 1 ? Container() : list[widget.drawerIndex],
                    ],
                  ),
                ),
              ),
            ],
          )),
        ),
      ),
    );
  }
}
