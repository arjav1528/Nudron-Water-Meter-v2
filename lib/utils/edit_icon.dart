import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:watermeter2/utils/pok.dart';
import 'package:watermeter2/constants/theme2.dart';

class EditIcon extends StatelessWidget {
  EditIcon({
    super.key,
    required this.onTap,
    this.icon = Icons.edit,
  });
  Function() onTap;
  IconData icon;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: RawMaterialButton(
        onPressed: onTap,
        fillColor:
            Provider.of<ThemeNotifier>(context).currentTheme.editIconBG,
        splashColor: CommonColors.blue.withOpacity(0.25),
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        elevation: 0,
        padding: EdgeInsets.zero,
        constraints: BoxConstraints.tightFor(width: 30.responsiveSp),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(2.responsiveSp),
          side: BorderSide(
            color: Provider.of<ThemeNotifier>(context)
                .currentTheme
                .gridLineColor, 
            width: 1.responsiveSp, 
          ),
        ),
        child: Center(
          child: Icon(
            icon,
            size: 20.responsiveSp,
            color: Provider.of<ThemeNotifier>(context)
                .currentTheme
                .editIconColor, 
          ),
        ),
      ),
    );
  }
}
