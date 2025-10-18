import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:watermeter2/utils/pok.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../constants/theme2.dart';

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
    Key? key,
    required this.initialSelection,
    this.refreshPhoneCode,
    required this.onChanged,
    required this.getPhoneNumberWithoutCountryCode,
    this.isEditable = true,
    this.dropDownColor = Colors.white,
  }) : super(key: key);

  @override
  _CountryCodePicker2State createState() => _CountryCodePicker2State();
}

class _CountryCodePicker2State extends State<CountryCodePicker2> {
  CountryCode? selectedItem;
  List<CountryCode> allowedCountries = [];
  OverlayEntry? _overlayEntry;
  final LayerLink _layerLink = LayerLink();
  List<String> priorityCountryCodes = ["IN", "GB", "SG", "MY"];

  // refresh(String selection) {
  //   print('refreshing');
  //   selectedItem = allowedCountries.firstWhere(
  //     (country) => selection.startsWith(country.code!),
  //     orElse: () => allowedCountries.first,
  //   );
  //   print('selectedItem: $selectedItem');
  //   widget.onChanged(selectedItem!);
  //   //remove selected item.dialcode from the initialSelection
  //   widget.getPhoneNumberWithoutCountryCode(
  //       selectedItem!.dialCode!.length < selection.length
  //           ? selection.substring(selectedItem!.dialCode!.length)
  //           : '');
  //   if (mounted) setState(() {});
  // }

  refresh(String fullNumber) {
    print('Refreshing with: $fullNumber');

    // Find the selected country code from allowedCountries
    selectedItem = allowedCountries.firstWhere(
      (country) => fullNumber.startsWith(country.dialCode ?? ''),
      orElse: () => allowedCountries.first,
    );

    print(
        'Selected Country: ${selectedItem!.code}, Dial Code: ${selectedItem!.dialCode}');

    widget.onChanged(selectedItem!);

    // Remove country code from phone number
    String purePhoneNumber =
        fullNumber.replaceFirst(selectedItem!.dialCode ?? '', '');
    print('Extracted Phone Number: $purePhoneNumber');

    widget.getPhoneNumberWithoutCountryCode(purePhoneNumber);

    if (mounted) setState(() {});
  }

  @override
  void initState() {
    super.initState();
    // Convert the top countries to a list of CountryCode objects
    List<CountryCode> priorityCountries = priorityCountryCodes
        .map((countryCode) => CountryCode.fromCountryCode(countryCode))
        .toList();

    // Convert all countries to a list of CountryCode objects
    List<CountryCode> allCountries = codes.map((country) {
      return CountryCode(
        name: country['name'],
        code: country['code'],
        dialCode: country['dial_code'],
      );
    }).toList();

    // Filter out the priority countries from the all countries list
    List<CountryCode> otherCountries = allCountries
        .where((country) => !priorityCountryCodes.contains(country.code))
        .toList();

    // Combine the lists with priority countries first, followed by others
    allowedCountries = [...priorityCountries, ...otherCountries];
    refresh(widget.initialSelection ?? "+91");
    if (widget.refreshPhoneCode != null) {
      widget.refreshPhoneCode!.addListener(() {
        refresh(widget.refreshPhoneCode!.value);
      });
    }
    //in allowed countries check if initial selection is there. but only the initial part of the code is checked
  }

  @override
  void dispose() {
    _overlayEntry
        ?.remove(); // Make sure to remove the entry to prevent memory leaks.
    if (widget.refreshPhoneCode != null) {
      widget.refreshPhoneCode!.dispose();
    }
    super.dispose();
  }

  void _toggleDropdown(BuildContext context) {
    if (_overlayEntry == null) {
      _overlayEntry = _createOverlayEntry(context);
      Overlay.of(context).insert(_overlayEntry!);
    } else {
      // Close the overlay if it is already open
      _overlayEntry?.remove();
      _overlayEntry = null;
    }
  }

  OverlayEntry _createOverlayEntry(BuildContext context) {
    RenderBox renderBox = context.findRenderObject() as RenderBox;
    var size = renderBox.size;

    return OverlayEntry(
      builder: (context) => Positioned(
        width: size.width,
        child: CompositedTransformFollower(
          link: _layerLink,
          showWhenUnlinked: false,
          offset: Offset(0.0, size.height),
          // Adjust the offset if needed
          child: Material(
            color: widget.dropDownColor,
            elevation: 4.0,
            child: Container(
              height: 200.h,
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

    // Helper function to create a dropdown item
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
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Container(
                child: Image.asset(
                  'flags/${country.code!.toLowerCase()}.png',
                  package: 'country_code_picker',
                  width: 20,
                ),
              ),
              Container(
                child: Text(country.dialCode ?? '',
                    style: GoogleFonts.roboto(
                      fontSize: ThemeNotifier.medium.responsiveSp,
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

    // Add priority countries
    dropdownItems.addAll(
      allowedCountries
          .sublist(0, priorityCountryCodes.length)
          .map(buildDropdownItem),
    );

    // Add divider after priority countries
    dropdownItems.add(
      Container(
        height: 1.responsiveSp,
        color:
            Provider.of<ThemeNotifier>(context).currentTheme.textfieldTextColor,
      ),
    );

    // Add the remaining countries
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
          height: 53.h,
          decoration: widget.decoration,
          child: GestureDetector(
            onTap: () => widget.isEditable ? _toggleDropdown(context) : null,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Row(mainAxisSize: MainAxisSize.min, children: <Widget>[
                Image.asset(
                  'flags/${selectedItem?.code!.toLowerCase()}.png',
                  package: 'country_code_picker',
                  width: 20,
                ),
                const SizedBox(width: 8.0),
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