import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../constants/theme2.dart';
import '../constants/ui_config.dart';
import '../models/country_code.dart';
import '../services/platform_utils.dart';

class CustomCountryCodePicker extends StatefulWidget {
  final double height;
  final Decoration decoration;
  final String? initialSelection;
  final Function(CountryCode) onChanged;
  final Function(String phoneNumber) getPhoneNumberWithoutCountryCode;
  final bool isEditable;
  final Color dropDownColor;
  final ValueNotifier<String>? refreshPhoneCode;

  const CustomCountryCodePicker({
    super.key,
    required this.height,
    required this.decoration,
    required this.initialSelection,
    this.refreshPhoneCode,
    required this.onChanged,
    required this.getPhoneNumberWithoutCountryCode,
    this.isEditable = true,
    this.dropDownColor = Colors.white,
  });

  @override
  State<CustomCountryCodePicker> createState() =>
      _CustomCountryCodePickerState();
}

class _CustomCountryCodePickerState extends State<CustomCountryCodePicker> {
  CountryCode? selectedItem;
  List<CountryCode> allowedCountries = [];
  OverlayEntry? _overlayEntry;
  final LayerLink _layerLink = LayerLink();
  final List<String> priorityCountryCodes = ["IN", "GB", "SG", "MY"];
  VoidCallback? _listener;

  void refresh(String fullNumber) {
    selectedItem = allowedCountries.firstWhere(
      (country) => fullNumber.startsWith(country.dialCode ?? ''),
      orElse: () => allowedCountries.first,
    );

    widget.onChanged(selectedItem!);

    String purePhoneNumber =
        fullNumber.replaceFirst(selectedItem!.dialCode ?? '', '');

    widget.getPhoneNumberWithoutCountryCode(purePhoneNumber);

    if (mounted) setState(() {});
  }

  @override
  void initState() {
    super.initState();

    List<CountryCode> priorityCountries = priorityCountryCodes
        .map((countryCode) => CountryCode.fromCountryCode(countryCode))
        .toList();

    List<CountryCode> allCountries = countryCodes.map((country) {
      return CountryCode.fromJson(country);
    }).toList();

    List<CountryCode> otherCountries = allCountries
        .where((country) => !priorityCountryCodes.contains(country.code))
        .toList();

    allowedCountries = [...priorityCountries, ...otherCountries];
    refresh(widget.initialSelection ?? "+91");
    if (widget.refreshPhoneCode != null) {
      _listener = () {
        if (mounted && widget.refreshPhoneCode != null) {
          refresh(widget.refreshPhoneCode!.value);
        }
      };
      widget.refreshPhoneCode!.addListener(_listener!);
    }
  }

  @override
  void dispose() {
    _overlayEntry?.remove();
    if (widget.refreshPhoneCode != null && _listener != null) {
      widget.refreshPhoneCode!.removeListener(_listener!);
    }
    super.dispose();
  }

  void _toggleDropdown(BuildContext context) {
    if (_overlayEntry == null) {
      _overlayEntry = _createOverlayEntry(context);
      Overlay.of(context).insert(_overlayEntry!);
    } else {
      _overlayEntry?.remove();
      _overlayEntry = null;
    }
  }

  OverlayEntry _createOverlayEntry(BuildContext context) {
    RenderBox renderBox = context.findRenderObject() as RenderBox;
    var size = renderBox.size;
    final screenHeight = MediaQuery.of(context).size.height;

    // Calculate minimum dropdown width - just enough for flag + dial code + padding
    final flagSize = UIConfig.iconSizeSmall * 0.83;
    final padding = UIConfig.paddingHorizontalSmall * 2;
    final dialCodeWidth = 60.0; // Approximate width for dial codes like "+91"
    final minDropdownWidth = flagSize + padding + dialCodeWidth + UIConfig.spacingSmall;
    
    // Use minimum width, but ensure it's at least as wide as the trigger button
    double dropdownWidth = minDropdownWidth.clamp(size.width, double.infinity);

    // Calculate responsive max height
    double maxHeight = UIConfig.dropdownMaxHeight;
    if (PlatformUtils.isMobile) {
      maxHeight = screenHeight * 0.4;
    }

    return OverlayEntry(
      builder: (context) => Positioned(
        width: dropdownWidth,
        child: CompositedTransformFollower(
          link: _layerLink,
          showWhenUnlinked: false,
          offset: Offset(0.0, size.height),
          child: Material(
            color: widget.dropDownColor,
            elevation: UIConfig.dialogOverlayElevation,
            borderRadius: BorderRadius.circular(UIConfig.borderRadiusMedium),
            child: SizedBox(
              height: maxHeight,
              child: ListView(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                children: _buildDropdownItems(),
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildDropdownItems() {
    List<Widget> dropdownItems = [];

    Widget buildDropdownItem(CountryCode country) {
      final flagSize = UIConfig.iconSizeSmall * 0.83;
      final isSelected = selectedItem?.code == country.code;

      return GestureDetector(
        onTap: () {
          setState(() {
            selectedItem = country;
            _toggleDropdown(context);
            widget.onChanged(country);
          });
        },
        child: Container(
          height: widget.height,
          decoration: BoxDecoration(
            color: isSelected
                ? Provider.of<ThemeNotifier>(context)
                    .currentTheme
                    .splashColor
                    .withOpacity(0.1)
                : Colors.transparent,
            borderRadius: (widget.decoration as BoxDecoration?)?.borderRadius,
            border: (widget.decoration as BoxDecoration?)?.border,
          ),
          padding: EdgeInsets.symmetric(
            horizontal: UIConfig.paddingHorizontalSmall,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.max,
            children: [
              _buildFlagWidget(country.flagAssetPath, flagSize),
              SizedBox(width: UIConfig.spacingSmall),
              Expanded(
                child: Text(
                  country.dialCode ?? '',
                  style: GoogleFonts.roboto(
                    fontSize: UIConfig.fontSizeMediumResponsive,
                    color: Provider.of<ThemeNotifier>(context)
                        .currentTheme
                        .textfieldTextColor,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    dropdownItems.addAll(
      allowedCountries
          .sublist(0, priorityCountryCodes.length)
          .map(buildDropdownItem),
    );

    dropdownItems.add(
      Container(
        height: UIConfig.borderWidthThin,
        color: Provider.of<ThemeNotifier>(context)
            .currentTheme
            .textfieldTextColor
            .withOpacity(0.3),
      ),
    );

    dropdownItems.addAll(
      allowedCountries
          .sublist(priorityCountryCodes.length)
          .map(buildDropdownItem),
    );

    return dropdownItems;
  }

  Widget _buildFlagWidget(String assetPath, double size) {
    return SizedBox(
      width: size,
      height: size,
      child: Image.asset(
        assetPath,
        width: size,
        height: size,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) => Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: Colors.grey.withOpacity(0.2),
            borderRadius: BorderRadius.circular(2),
          ),
          child: Center(
            child: Text(
              selectedItem?.code?.substring(0, 1) ?? '?',
              style: TextStyle(
                fontSize: size * 0.5,
                color: Colors.grey,
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final flagSize = UIConfig.iconSizeSmall * 0.83;

    return CompositedTransformTarget(
      link: _layerLink,
      child: Container(
        color: Colors.transparent,
        child: Container(
          height: UIConfig.dropdownRowHeight + 2.09.h,
          decoration: widget.decoration,
          child: GestureDetector(
            onTap: () =>
                widget.isEditable ? _toggleDropdown(context) : null,
            child: Padding(
              padding: UIConfig.paddingSmall,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  _buildFlagWidget(
                    selectedItem?.flagAssetPath ?? '',
                    flagSize,
                  ),
                  SizedBox(width: UIConfig.spacingSmall),
                  Icon(
                    Icons.arrow_drop_down,
                    color: Provider.of<ThemeNotifier>(context)
                        .currentTheme
                        .textfieldTextColor,
                    size: UIConfig.iconSizeSmall,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

