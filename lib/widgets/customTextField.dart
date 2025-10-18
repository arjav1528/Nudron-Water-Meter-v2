import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../utils/pok.dart';
import '../../constants/theme2.dart';
import '../constants/app_config.dart';

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
  //
  // @override
  // void initState() {
  //   super.initState();
  //   _focusNode = FocusNode();
  // }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color:
            Provider.of<ThemeNotifier>(context).currentTheme.textFieldFillColor,
        borderRadius: const BorderRadius.all(Radius.circular(10)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            spreadRadius: 0,
            blurRadius: 4,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 0),
        child: TextField(
          controller: widget.controller,
          focusNode: _focusNode,
          onSubmitted: widget.onChanged,
          //how to disable copy paste
          enableInteractiveSelection: widget.enableInteractiveSelection,
          keyboardType: widget.keyboardType,
          inputFormatters: widget.inputFormatters,
          style: widget.style ??
              GoogleFonts.roboto(
                fontSize: ThemeNotifier.medium.responsiveSp,
                color: Provider.of<ThemeNotifier>(context)
                    .currentTheme
                    .textfieldTextColor,
              ),
          cursorColor: Provider.of<ThemeNotifier>(context)
              .currentTheme
              .textfieldCursorColor,
          cursorHeight: 30.responsiveSp,
          enableSuggestions: widget.enableSuggestions,
          autocorrect: widget.autocorrect,
          decoration: InputDecoration(
            suffixIcon: widget.suffixIcon,
            prefixIcon: widget.prefixIcon ??
                Container(
                  child: Padding(
                    padding: widget.iconPath != null
                        ? EdgeInsets.symmetric(horizontal: 16.w)
                        : EdgeInsets.zero,
                    child: widget.iconPath != null
                        ? SvgPicture.asset(
                            widget.iconPath!,
                            height: 16.69.h,
                            width: 21.w,
                            fit: BoxFit.scaleDown,
                          )
                        : null,
                  ),
                ),
            prefixIconConstraints: BoxConstraints(
              minHeight: 16.69.h,
              minWidth: 21.w,
            ),
            focusedBorder: widget.border ??
                OutlineInputBorder(
                  borderSide: BorderSide(
                    color: CommonColors.blue,
                  ),
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                ),
            filled: true,
            fillColor: widget.fillColor ??
                Provider.of<ThemeNotifier>(context)
                    .currentTheme
                    .textFieldFillColor,
            hintText: widget.hintText,
            hintStyle: widget.hintStyle ??
                GoogleFonts.roboto(
                  fontSize: ThemeNotifier.medium.responsiveSp,
                  color: Provider.of<ThemeNotifier>(context)
                      .currentTheme
                      .textfieldHintColor,
                ),
            border: widget.border ??
                OutlineInputBorder(
                  borderSide: BorderSide.none,
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                ),
            contentPadding: EdgeInsets.symmetric(
                vertical: isLargerTextField
                    ? 22.h
                    : 10.h), // Adjust vertical padding to fill the space
          ),
        ),
      ),
    );
  }
}