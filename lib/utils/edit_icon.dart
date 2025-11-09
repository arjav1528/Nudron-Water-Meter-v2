import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:watermeter2/constants/theme2.dart';
import 'package:watermeter2/constants/ui_config.dart';

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
        splashColor: UIConfig.accentColorBlue.withOpacity(UIConfig.opacityMedium),
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        elevation: UIConfig.dialogElevation,
        padding: EdgeInsets.zero,
        constraints: BoxConstraints.tightFor(width: UIConfig.iconSizeLarge),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(UIConfig.spacingXSmall * 0.5),
          side: BorderSide(
            color: Provider.of<ThemeNotifier>(context)
                .currentTheme
                .gridLineColor, 
            width: UIConfig.borderWidthThin, 
          ),
        ),
        child: Center(
          child: Icon(
            icon,
            size: UIConfig.fontSizeSmallResponsive + UIConfig.spacingXSmall,
            color: Provider.of<ThemeNotifier>(context)
                .currentTheme
                .editIconColor, 
          ),
        ),
      ),
    );
  }
}
