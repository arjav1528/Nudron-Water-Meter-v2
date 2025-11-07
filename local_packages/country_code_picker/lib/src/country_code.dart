import 'package:collection/collection.dart' show IterableExtension;
import 'package:flutter/cupertino.dart';

import 'country_codes.dart';
import 'country_localizations.dart';

mixin ToAlias {}

class CountryCode {
  
  String? name;

  final String? flagUri;

  final String? code;

  final String? dialCode;

  CountryCode({
    this.name,
    this.flagUri,
    this.code,
    this.dialCode,
  });

  @Deprecated('Use `fromCountryCode` instead.')
  factory CountryCode.fromCode(String isoCode) {
    return CountryCode.fromCountryCode(isoCode);
  }

  factory CountryCode.fromCountryCode(String countryCode) {
    final Map<String, String>? jsonCode = codes.firstWhereOrNull(
      (code) => code['code'] == countryCode,
    );
    return CountryCode.fromJson(jsonCode!);
  }

  factory CountryCode.fromDialCode(String dialCode) {
    final Map<String, String>? jsonCode = codes.firstWhereOrNull(
      (code) => code['dial_code'] == dialCode,
    );
    return CountryCode.fromJson(jsonCode!);
  }

  CountryCode localize(BuildContext context) {
    return this
      ..name = CountryLocalizations.of(context)?.translate(code) ?? name;
  }

  factory CountryCode.fromJson(Map<String, dynamic> json) {
    return CountryCode(
      name: json['name'],
      code: json['code'],
      dialCode: json['dial_code'],
      flagUri: 'flags/${json['code'].toLowerCase()}.png',
    );
  }

  @override
  String toString() => "$dialCode";

  String toLongString() => "$dialCode ${toCountryStringOnly()}";

  String toCountryStringOnly() {
    return '$_cleanName';
  }

  String? get _cleanName {
    return name?.replaceAll(RegExp(r'[[\]]'), '').split(',').first;
  }
}
