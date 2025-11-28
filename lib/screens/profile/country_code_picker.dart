// This file is kept for backward compatibility
// Import the new custom country code picker
import 'package:flutter/material.dart';
import '../../widgets/custom_country_code_picker.dart';

// Re-export as CountryCodePicker2 for backward compatibility
class CountryCodePicker2 extends CustomCountryCodePicker {
  const CountryCodePicker2({
    required super.height,
    required super.decoration,
    required super.initialSelection,
    super.refreshPhoneCode,
    required super.onChanged,
    required super.getPhoneNumberWithoutCountryCode,
    super.isEditable = true,
    super.dropDownColor = Colors.white,
    super.key,
  });
}