import 'package:timeago/timeago.dart' as timeago;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../bloc/dashboard_bloc.dart';
import '../../constants/theme2.dart';
import '../../constants/ui_config.dart';
import '../../models/userInfo.dart';
import '../../utils/pok.dart';

class ActiveDevices extends StatelessWidget {
  const ActiveDevices({super.key});

  @override
  Widget build(BuildContext context) {
    var sessions =
        BlocProvider.of<DashboardBloc>(context, listen: true).sessions;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: List.generate(
            sessions.length,
            (index) => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.only(
                      top: index == 0 ? 0 : UIConfig.spacingSmall.h,
                      bottom: (index == sessions.length - 1) ? UIConfig.spacingSmall.h : UIConfig.spacingSmall.h),
                  child: SessionWidget(session: sessions[index]),
                ),
                
                Container(
                  height: UIConfig.borderWidthThin,
                  color: Provider.of<ThemeNotifier>(context)
                      .currentTheme
                      .basicAdvanceTextColor,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class SessionWidget extends StatelessWidget {
  Session session;

  SessionWidget({super.key, required this.session});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Client: ${session.clientID}',
          style: GoogleFonts.roboto(
            fontSize: UIConfig.fontSizeLarge.responsiveSp,
            color: CommonColors.blue2,
            fontWeight: FontWeight.bold,
          ),
        ),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Text(
            'Device: ${session.deviceInfo}',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.roboto(
              fontSize: UIConfig.fontSizeMedium.responsiveSp,
              color: Provider.of<ThemeNotifier>(context)
                  .currentTheme
                  .basicAdvanceTextColor,
            ),
          ),
        ),
        Text(
          'Location: ${session.location}',
          style: GoogleFonts.roboto(
            fontSize: UIConfig.fontSizeMedium.responsiveSp,
            color: Provider.of<ThemeNotifier>(context)
                .currentTheme
                .basicAdvanceTextColor,
          ),
        ),
        Text(
          'Last Active: ${timeago.format(session.lastRefresh)}',
          style: GoogleFonts.roboto(
            fontSize: UIConfig.fontSizeMedium.responsiveSp,
            color: Provider.of<ThemeNotifier>(context)
                .currentTheme
                .basicAdvanceTextColor,
          ),
        )
      ],
    );
  }
}
