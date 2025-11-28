import '../utils/country_codes_data.dart';

class CountryCode {
  final String? name;
  final String? code;
  final String? dialCode;

  CountryCode({
    this.name,
    this.code,
    this.dialCode,
  });

  factory CountryCode.fromCountryCode(String countryCode) {
    final jsonCode = countryCodes.firstWhere(
      (code) => code['code'] == countryCode,
      orElse: () => countryCodes.first,
    );
    return CountryCode.fromJson(jsonCode);
  }

  factory CountryCode.fromDialCode(String dialCode) {
    final jsonCode = countryCodes.firstWhere(
      (code) => code['dial_code'] == dialCode,
      orElse: () => countryCodes.first,
    );
    return CountryCode.fromJson(jsonCode);
  }

  factory CountryCode.fromJson(Map<String, String> json) {
    return CountryCode(
      name: json['name'],
      code: json['code'],
      dialCode: json['dial_code'],
    );
  }

  String get flagAssetPath => 'assets/flags/${code?.toLowerCase()}.png';

  @override
  String toString() => dialCode ?? '';

  String toLongString() => "$dialCode ${toCountryStringOnly()}";

  String toCountryStringOnly() {
    return _cleanName ?? '';
  }

  String? get _cleanName {
    return name?.replaceAll(RegExp(r'[[\]]'), '').split(',').first;
  }
}

List<Map<String, String>> get countryCodes => countryCodesData;

