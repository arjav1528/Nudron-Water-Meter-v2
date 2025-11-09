import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import '../constants/theme2.dart';
import '../constants/ui_config.dart';
class NoEntries extends StatelessWidget {
  const NoEntries({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context,constraints) {

        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SvgPicture.asset(
                'assets/icons/noentries.svg',
                height: min(UIConfig.noEntriesIconSize, constraints.maxHeight * UIConfig.opacityIcon),
                width: min(UIConfig.noEntriesIconSize, constraints.maxHeight * UIConfig.opacityIcon),
                color:
                Provider.of<ThemeNotifier>(context).currentTheme.noEntriesColor,
              ),
              
            ],
          ),
        );
      }
    );
  }
}
