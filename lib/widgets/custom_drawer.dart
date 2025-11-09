import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../utils/pok.dart';
import '../../screens/profile/profile_drawer.dart';
import '../../constants/theme2.dart';
import '../../constants/ui_config.dart';
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
      
      const ProfileDrawer(),
    ];
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        backgroundColor: Provider.of<ThemeNotifier>(context).currentTheme.bgColor,
        body: Column(
          children: [
          
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
                              icon: Transform.scale(
                                scaleX: -1,
                                child: Icon(
                                Icons.arrow_right_alt,
                                color: Provider.of<ThemeNotifier>(context)
                                    .currentTheme
                                    .drawerHeadingColor,
                                size: 24.responsiveSp,
                              ),
                              ),
                              onPressed: () {
                                Navigator.pop(context);
                              },
                            ),
                          ),
          
                          Padding(
                            padding: EdgeInsets.all(8.w),
                            child: Center(
                              child: Text(
                                widget.drawerName[widget.drawerIndex],
                                style: GoogleFonts.roboto(
                                  fontSize: UIConfig.fontSizeLargeResponsive + 4.responsiveSp,
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
                  
                  widget.drawerIndex >= 1 ? Container() : list[widget.drawerIndex],
                ],
              ),
            ),
          ),
          ],
        ),
      ),
    );
  }
}
