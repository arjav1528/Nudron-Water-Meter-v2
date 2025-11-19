import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../constants/theme2.dart';
import '../../constants/ui_config.dart';
import '../constants/app_config.dart';
import '../../services/platform_utils.dart';

class CustomTextField extends StatefulWidget {
  CustomTextField({
    super.key,
    required this.controller,
    this.iconPath,
    required this.hintText,
    this.enableSuggestions = true,
    this.autocorrect = true,
    this.keyboardType = TextInputType.text,
    this.inputFormatters,
    this.enableInteractiveSelection = true,
    this.suffixIcon,
    this.prefixIcon,
    this.onChanged,
    this.border,
    this.fillColor,
    this.hintStyle,
    this.style,
  });

  TextEditingController controller;
  String hintText;
  String? iconPath;
  bool enableSuggestions;
  bool autocorrect;
  TextInputType keyboardType;
  List<TextInputFormatter>? inputFormatters;
  Widget? suffixIcon;
  Widget? prefixIcon;
  bool enableInteractiveSelection;
  ValueChanged<String>? onChanged;
  OutlineInputBorder? border;
  Color? fillColor;
  TextStyle? hintStyle;

  TextStyle? style;

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  bool isLargerTextField = ConfigurationCustom.isLargerTextField;
  final FocusNode _focusNode = FocusNode();
  
  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final width = UIConfig.getDesktopDrawerWidth(context);
    final fontSize = UIConfig.getResponsiveFontSize(context, ThemeNotifier.medium, desktopWidth: width);
    final textFieldHeight = UIConfig.getResponsiveTextFieldHeight(context);
    
    // Calculate clamped width
    final screenWidth = MediaQuery.of(context).size.width;
    final calculatedWidth = PlatformUtils.isMobile 
        ? screenWidth.clamp(UIConfig.textFieldMinWidth, UIConfig.textFieldMaxWidth)
        : width.clamp(UIConfig.textFieldMinWidth, UIConfig.textFieldMaxWidth);
    
    return Container(
      width: calculatedWidth,
      height: textFieldHeight,
      constraints: BoxConstraints(
        minHeight: UIConfig.textFieldMinHeight,
        maxHeight: UIConfig.textFieldMaxHeight,
        minWidth: UIConfig.textFieldMinWidth,
        maxWidth: UIConfig.textFieldMaxWidth,
      ),
      decoration: BoxDecoration(
        color:
            Provider.of<ThemeNotifier>(context).currentTheme.textFieldFillColor,
        borderRadius: UIConfig.borderRadiusAllLarge,
        boxShadow: [
          UIConfig.shadowSmall,
        ],
      ),
      child: Padding(
        padding: UIConfig.paddingTextField,
        child: TextField(
          controller: widget.controller,
          focusNode: _focusNode,
          onSubmitted: widget.onChanged,
          
          enableInteractiveSelection: widget.enableInteractiveSelection,
          keyboardType: widget.keyboardType,
          inputFormatters: widget.inputFormatters,
          style: widget.style ??
              GoogleFonts.roboto(
                fontSize: fontSize,
                color: Provider.of<ThemeNotifier>(context)
                    .currentTheme
                    .textfieldTextColor,
              ),
          cursorColor: Provider.of<ThemeNotifier>(context)
              .currentTheme
              .textfieldCursorColor,
          cursorHeight: UIConfig.textFieldCursorHeight,
          enableSuggestions: widget.enableSuggestions,
          autocorrect: widget.autocorrect,
          // textAlign: TextAlign.center,
          textAlignVertical: TextAlignVertical.center,
          textDirection: TextDirection.ltr,
          decoration: InputDecoration(
            suffixIcon: widget.suffixIcon,
            prefixIcon: widget.prefixIcon ??
                Padding(
                  padding: widget.iconPath != null
                      ? UIConfig.paddingTextFieldHorizontal
                      : EdgeInsets.zero,
                  child: widget.iconPath != null
                      ? SvgPicture.asset(
                          widget.iconPath!,
                          height: UIConfig.iconSizePrefix,
                          width: UIConfig.iconSizePrefixWidth,
                          fit: BoxFit.scaleDown,
                        )
                      : null,
                ),
            prefixIconConstraints: BoxConstraints(
              minHeight: UIConfig.textFieldPrefixMinHeight,
              minWidth: UIConfig.textFieldPrefixMinWidth,
            ),
            focusedBorder: widget.border ??
                OutlineInputBorder(
                  borderSide: BorderSide(
                    color: CommonColors.blue,
                  ),
                  borderRadius: UIConfig.borderRadiusAllLarge,
                ),
            filled: true,
            fillColor: widget.fillColor ??
                Provider.of<ThemeNotifier>(context)
                    .currentTheme
                    .textFieldFillColor,
            hintText: widget.hintText,
            hintStyle: widget.hintStyle ??
                GoogleFonts.roboto(
                  fontSize: fontSize,
                  color: Provider.of<ThemeNotifier>(context)
                      .currentTheme
                      .textfieldHintColor,
                ),
            border: widget.border ??
                OutlineInputBorder(
                  borderSide: BorderSide.none,
                  borderRadius: UIConfig.borderRadiusAllLarge,
                ),
            contentPadding: EdgeInsets.symmetric(
                vertical: isLargerTextField
                    ? UIConfig.paddingTextFieldLarger.vertical / 1.h
                    : UIConfig.paddingTextFieldNormal.vertical / 1.h), 
          ),
        ),
      ),
    );
  }
}