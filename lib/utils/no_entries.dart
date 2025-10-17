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
        // print("NoEntries: ${constraints.maxHeight}");

        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SvgPicture.asset(
                'assets/icons/noentries.svg',
                height: min(114,constraints.maxHeight*0.8).minSp,
                width: min(114,constraints.maxHeight*0.8).minSp,
                color:
                Provider.of<ThemeNotifier>(context).currentTheme.noEntriesColor,
              ),
              // SizedBox(height: 20.minSp),
              // Text(
              //   "NO ENTRIES FOUND",
              //   style: GoogleFonts.robotoMono(
              //       fontSize: ThemeNotifier.small.minSp,
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
