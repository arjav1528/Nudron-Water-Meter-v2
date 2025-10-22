import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:watermeter2/utils/pok.dart';

import '../constants/theme2.dart';
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
                height: min(114,constraints.maxHeight*0.8).responsiveSp,
                width: min(114,constraints.maxHeight*0.8).responsiveSp,
                color:
                Provider.of<ThemeNotifier>(context).currentTheme.noEntriesColor,
              ),
              // SizedBox(height: 20.responsiveSp),
              // Text(
              //   "NO ENTRIES FOUND",
              //   style: GoogleFonts.robotoMono(
              //       fontSize: ThemeNotifier.small.responsiveSp,
              //       color: Provider.of<ThemeNotifier>(context)
              //           .currentTheme
              //           .noEntriesColor,
              //       fontWeight: FontWeight.w400),
              // )
            ],
          ),
        );
      }
    );
  }
}
