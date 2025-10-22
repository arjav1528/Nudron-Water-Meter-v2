import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../utils/pok.dart';
import '../../constants/theme2.dart';
import 'customTextField.dart';

class PasswordTextField extends StatefulWidget {
  const PasswordTextField(
      {super.key, required this.controller, this.hint = 'Enter Password'});

  final ObscuringTextEditingController controller;
  final String hint;

  @override
  State<PasswordTextField> createState() => _PasswordTextFieldState();
}

class _PasswordTextFieldState extends State<PasswordTextField> {

  @override
  void initState() {
    super.initState();
    // Add a listener to update the state when the obscuring changes
    widget.controller.addListener(_updateObscureText);
  }

  @override
  void dispose() {
    // Remove the listener to prevent memory leaks
    widget.controller.removeListener(_updateObscureText);
    super.dispose();
  }

  void _updateObscureText() {
    setState(() {}); // Trigger a rebuild to reflect the updated obscure state
  }

  void _toggleObscureText() {
    widget.controller.changeObscuringText();
  }

  @override
  Widget build(BuildContext context) {
    return CustomTextField(
      controller: widget.controller,
      iconPath: 'assets/icons/pwd.svg',
      hintText: widget.hint,
      enableSuggestions: false,
      autocorrect: false,
      suffixIcon: IconButton(
        icon: Icon(
          widget.controller.isObscuring ? Icons.visibility : Icons.visibility_off,
          color: Provider.of<ThemeNotifier>(context)
              .currentTheme
              .textfieldHintColor,
          size: 16.responsiveSp,
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
