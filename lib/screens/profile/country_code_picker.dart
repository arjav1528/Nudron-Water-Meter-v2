import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../constants/theme2.dart';
import '../../constants/ui_config.dart';

class CountryCodePicker2 extends StatefulWidget {
  final double height;
  final Decoration decoration;
  final String? initialSelection;
  final Function(CountryCode) onChanged;
  final Function(String phoneNumber) getPhoneNumberWithoutCountryCode;
  final bool isEditable;
  final Color dropDownColor;
  final ValueNotifier<String>? refreshPhoneCode;

  const CountryCodePicker2({
    required this.height,
    required this.decoration,
    super.key,
    required this.initialSelection,
    this.refreshPhoneCode,
    required this.onChanged,
    required this.getPhoneNumberWithoutCountryCode,
    this.isEditable = true,
    this.dropDownColor = Colors.white,
  });

  @override
  _CountryCodePicker2State createState() => _CountryCodePicker2State();
}

class _CountryCodePicker2State extends State<CountryCodePicker2> {
  CountryCode? selectedItem;
  List<CountryCode> allowedCountries = [];
  OverlayEntry? _overlayEntry;
  final LayerLink _layerLink = LayerLink();
  List<String> priorityCountryCodes = ["IN", "GB", "SG", "MY"];
  VoidCallback? _listener;

  refresh(String fullNumber) {

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

    List<CountryCode> allCountries = codes.map((country) {
      return CountryCode(
        name: country['name'],
        code: country['code'],
        dialCode: country['dial_code'],
      );
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
    _overlayEntry
        ?.remove(); 
    
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

    return OverlayEntry(
      builder: (context) => Positioned(
        width: size.width * 1.3,
        child: CompositedTransformFollower(
          link: _layerLink,
          showWhenUnlinked: false,
          offset: Offset(0.0, size.height),
          
          child: Material(
            color: widget.dropDownColor,
            elevation: UIConfig.dialogOverlayElevation,
            child: SizedBox(
              height: UIConfig.dropdownMaxHeight,
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
          decoration: widget.decoration,
          padding: EdgeInsets.symmetric(horizontal: 12.w),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.max,
            children: [
              Image.asset(
                'flags/${country.code!.toLowerCase()}.png',
                package: 'country_code_picker',
                width: UIConfig.iconSizeSmall * 0.83,
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: Text(country.dialCode ?? '',
                    style: GoogleFonts.roboto(
                      fontSize: UIConfig.fontSizeMediumResponsive,
                      color: Provider.of<ThemeNotifier>(context)
                          .currentTheme
                          .textfieldTextColor,
                    )),
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
        color:
            Provider.of<ThemeNotifier>(context).currentTheme.textfieldTextColor,
      ),
    );

    dropdownItems.addAll(
      allowedCountries
          .sublist(priorityCountryCodes.length)
          .map(buildDropdownItem),
    );

    return dropdownItems;
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: Container(
        color: Colors.transparent,
        child: Container(
          height: UIConfig.dropdownRowHeight + 2.09.h,
          decoration: widget.decoration,
          child: GestureDetector(
            onTap: () => widget.isEditable ? _toggleDropdown(context) : null,
            child: Padding(
              padding: UIConfig.paddingSmall,
              child: Row(mainAxisSize: MainAxisSize.min, children: <Widget>[
                Image.asset(
                  'flags/${selectedItem?.code!.toLowerCase()}.png',
                  package: 'country_code_picker',
                  width: UIConfig.iconSizeSmall * 0.83,
                ),
                UIConfig.spacingSizedBoxSmall,
                Icon(
                  Icons.arrow_drop_down,
                  color: Provider.of<ThemeNotifier>(context)
                      .currentTheme
                      .textfieldTextColor,
                ),
              ]),
            ),
          ),
        ),
      ),
    );
  }
}