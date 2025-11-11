import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../utils/pok.dart';

import '../../constants/theme2.dart';
import '../../constants/ui_config.dart';
import '../../widgets/chamfered_text_widget.dart';
import '../../widgets/customButton.dart';

class ConfirmationDialog extends StatefulWidget {
  ConfirmationDialog({
    super.key,
    required this.heading,
    required this.message,
  });

  String heading;
  String message;

  @override
  State<ConfirmationDialog> createState() => _ConfirmationDialogState();
}

class _ConfirmationDialogState extends State<ConfirmationDialog> {
  @override
  Widget build(BuildContext context) {
    final dialogWidth = UIConfig.getDesktopDialogWidth(context);

    return Dialog(
      insetPadding: EdgeInsets.all(0.w),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(0.0),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Provider.of<ThemeNotifier>(context).currentTheme.dialogBG,
          border: Border.all(
            color:
                Provider.of<ThemeNotifier>(context).currentTheme.gridLineColor,
            width: 3.responsiveSp,
          ),
        ),
        width: dialogWidth,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ChamferedTextWidgetInverted(
                  text: widget.heading.toUpperCase(),
                  borderColor: Provider.of<ThemeNotifier>(context)
                      .currentTheme
                      .gridLineColor,
                ),
                IconButton(
                  icon: Icon(Icons.close,
                      color: Provider.of<ThemeNotifier>(context)
                          .currentTheme
                          .gridLineColor),
                  onPressed: () {
                    if (mounted) {
                      Navigator.of(context).pop();
                    }
                  },
                ),
              ],
            ),
            SizedBox(height: 20.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Text(
                widget.message,
                textAlign: TextAlign.center,
                style: GoogleFonts.robotoMono(
                  textStyle: TextStyle(
                    fontSize: UIConfig.fontSizeSmallResponsive,
                    color: Provider.of<ThemeNotifier>(context)
                        .currentTheme
                        .basicAdvanceTextColor,
                  ),
                ),
              ),
            ),
            SizedBox(height: 20.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                CustomButton(
                  text: "CANCEL",
                  dynamicWidth: true,
                  onPressed: () {
                    Navigator.of(context).pop(false);
                  },
                  isRed: true,
                ),
                CustomButton(
                  dynamicWidth: true,
                  text: "CONFIRM",
                  onPressed: () {
                    Navigator.of(context).pop(true);
                  },
                ),
              ],
            ),
            SizedBox(height: 20.h),
          ],
        ),
      ),
    );
  }
}
