import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:watermeter2/services/platform_utils.dart';
import '../../utils/pok.dart';
import '../../constants/theme2.dart';
import 'customTextField.dart';

class PasswordTextField extends StatefulWidget {
  const PasswordTextField(
      {super.key,
      required this.controller,
      this.hint = 'Enter Password',
      this.style,
      this.hintStyle,
      this.desktopPrefixIconHeight,
      this.desktopPrefixIconWidth,
      this.desktopSuffixIconSize});

  final ObscuringTextEditingController controller;
  final String hint;
  final TextStyle? style;
  final TextStyle? hintStyle;
  final double? desktopPrefixIconHeight;
  final double? desktopPrefixIconWidth;
  final double? desktopSuffixIconSize;

  @override
  State<PasswordTextField> createState() => _PasswordTextFieldState();
}

class _PasswordTextFieldState extends State<PasswordTextField> {

  @override
  void initState() {
    super.initState();
    
    widget.controller.addListener(_updateObscureText);
  }

  @override
  void dispose() {
    
    widget.controller.removeListener(_updateObscureText);
    super.dispose();
  }

  void _updateObscureText() {
    setState(() {}); 
  }

  void _toggleObscureText() {
    widget.controller.changeObscuringText();
  }

  @override
  Widget build(BuildContext context) {
    final bool isMobile = PlatformUtils.isMobile;
    return CustomTextField(
      controller: widget.controller,
      iconPath: (!isMobile && (widget.desktopPrefixIconHeight != null || widget.desktopPrefixIconWidth != null))
          ? null
          : 'assets/icons/pwd.svg',
      prefixIcon: (!isMobile && (widget.desktopPrefixIconHeight != null || widget.desktopPrefixIconWidth != null))
          ? Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: SvgPicture.asset(
                'assets/icons/pwd.svg',
                height: widget.desktopPrefixIconHeight ?? 20.0,
                width: widget.desktopPrefixIconWidth ?? 24.0,
                fit: BoxFit.scaleDown,
              ),
            )
          : null,
      hintText: widget.hint,
      enableSuggestions: false,
      autocorrect: false,
      style: widget.style,
      hintStyle: widget.hintStyle,
      suffixIcon: IconButton(
        icon: Icon(
          widget.controller.isObscuring ? Icons.visibility : Icons.visibility_off,
          color: Provider.of<ThemeNotifier>(context)
              .currentTheme
              .textfieldHintColor,
          size: isMobile ? 16.responsiveSp : (widget.desktopSuffixIconSize ?? 18.0),
        ),
        onPressed: _toggleObscureText,
      ),
    );
  }
}

class ObscuringTextEditingController extends TextEditingController {
  bool isObscuring = true;

  void changeObscuringText() {
    isObscuring = !isObscuring;
    notifyListeners();
  }

  String getText() {
    return text;
  }

  @override
  TextSpan buildTextSpan(
      {required BuildContext context,
        TextStyle? style,
        required bool withComposing}) {
    var displayValue = isObscuring ? '•' * text.length : text;
    if (!value.composing.isValid || !withComposing) {
      return TextSpan(style: style, text: displayValue);
    }
    final TextStyle? composingStyle = style?.merge(
      const TextStyle(decoration: TextDecoration.underline),
    );
    return TextSpan(
      style: style,
      children: <TextSpan>[
        TextSpan(text: value.composing.textBefore(displayValue)),
        TextSpan(
          style: composingStyle,
          text: value.composing.textInside(displayValue),
        ),
        TextSpan(text: value.composing.textAfter(displayValue)),
      ],
    );
  }
}
