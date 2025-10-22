import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../constants/theme2.dart';
import '../../utils/pok.dart';
import 'package:dropdown_button2/dropdown_button2.dart';

class CustomDropDown extends StatefulWidget {
  CustomDropDown({
    super.key,
    required this.onChanged,
    required this.fieldName,
    required this.defaultValue,
    required this.values,
    this.width1 = 80,
    this.width2 = 150,
    this.valueConvertor,
  });

  final Function(String?) onChanged;
  final String fieldName;
  final String defaultValue;
  final List<dynamic> values;
  final double width1;
  final double width2;
  Function? valueConvertor;

  @override
  State<CustomDropDown> createState() => _CustomDropDownState();
}

class _CustomDropDownState extends State<CustomDropDown> {
  late String selectedValue;

  @override
  void initState() {
    super.initState();
    selectedValue = widget.defaultValue;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          height: 50.91.h,
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage("assets/images/basic_advance.png"),
              fit: BoxFit.fill,
            ),
          ),
          child: SizedBox(
            height: 50.91.h,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  width: 10.w,
                ),
                SizedBox(
                  width: widget.width1.w,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Text(
                      widget.fieldName,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.robotoMono(
                        fontSize: ThemeNotifier.small.responsiveSp,
                        color: Provider.of<ThemeNotifier>(context)
                            .currentTheme
                            .basicAdvanceTextColor,
                      ),
                    ),
                  ),
                ),
                Container(
                  width: 10.w,
                ),
                Container(
                  height: 50.91.h,
                  width: 1.w,
                  color: CommonColors.blue,
                ),
                DropdownButtonHideUnderline(
                  child: DropdownButton2<dynamic>(
                    isDense: true,
                    enableFeedback: false,
                    buttonSplashColor: Colors.transparent,
                    buttonPadding: EdgeInsets.zero,
                    dropdownPadding: EdgeInsets.symmetric(vertical: 0.h),
                    itemHeight: 40.h,
                    iconSize: 30.responsiveSp,
                    itemPadding: EdgeInsets.zero,
                    dropdownMaxHeight: 200.h,
                    dropdownWidth: widget.width2.w + 30.responsiveSp,
                    buttonWidth: widget.width2.w + 30.responsiveSp,
                    dropdownDecoration: BoxDecoration(
                      color: Provider.of<ThemeNotifier>(context)
                          .currentTheme
                          .dropDownColor,
                      border: Border(
                        left: BorderSide(
                          color: CommonColors.blue,
                          width: 1.w,
                        ),
                        right: BorderSide(
                          color: CommonColors.blue,
                          width: 1.w,
                        ),
                        bottom: BorderSide(
                          color: CommonColors.blue,
                          width: 1.w,
                        ),
                      ),
                    ),
                    customButton: Container(
                      width: widget.width2.w + 30.responsiveSp,
                      height: 40.h,
                      alignment: Alignment.center,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          SizedBox(
                            width: (widget.width2 - 1).w,
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Padding(
                                padding: EdgeInsets.only(left: 8.w),
                                child: Text(
                                  widget.valueConvertor == null
                                      ? selectedValue
                                      : widget.valueConvertor!(selectedValue),
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.robotoMono(
                                    fontSize: ThemeNotifier.small.responsiveSp,
                                    color: Provider.of<ThemeNotifier>(context)
                                        .currentTheme
                                        .basicAdvanceTextColor,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Icon(
                            Icons.arrow_drop_down,
                            size: 30.responsiveSp,
                            color: Provider.of<ThemeNotifier>(context)
                                .currentTheme
                                .basicAdvanceTextColor,
                          ),
                        ],
                      ),
                    ),
                    value: selectedValue,
                    items:
                        widget.values.map<DropdownMenuItem<dynamic>>((value) {
                      return DropdownMenuItem<dynamic>(
                        value: value.toString(),
                        child: Column(
                          children: [
                            Container(
                              width: widget.width2.w + 30.responsiveSp,
                              height: 39.5.h,
                              color: Provider.of<ThemeNotifier>(context)
                                  .currentTheme
                                  .primaryContainer,
                              padding: EdgeInsets.symmetric(
                                  horizontal: 8.w, vertical: 8.h),
                              child: Text(
                                widget.valueConvertor == null
                                    ? value.toString()
                                    : widget.valueConvertor!(value),
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.robotoMono(
                                  fontSize: ThemeNotifier.small.responsiveSp,
                                  color: Provider.of<ThemeNotifier>(context)
                                      .currentTheme
                                      .basicAdvanceTextColor,
                                ),
                              ),
                            ),
                            Container(
                              height: 0.5.h,
                              color: CommonColors.blue,
                            )
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (dynamic newValue) async {
                      bool toChange = await widget.onChanged(newValue);
                      if (toChange) {
                        setState(() {
                          selectedValue = newValue.toString();
                        });
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class CustomDropdownButton2 extends StatefulWidget {
  final String fieldName;
  final String? value;
  final List<String> items;
  final ValueChanged<String?> onChanged;
  final double width1;
  final double width2;
  final bool fieldNameVisible;

  const CustomDropdownButton2({
    super.key,
    required this.fieldName,
    required this.value,
    required this.items,
    required this.onChanged,
    this.width1 = 80,
    this.width2 = 273,
    this.fieldNameVisible = true,
  });

  @override
  _CustomDropdownButton2State createState() => _CustomDropdownButton2State();
}

class _CustomDropdownButton2State extends State<CustomDropdownButton2> {
  bool _isOpen = false;
  OverlayEntry? _overlayEntry;
  final LayerLink _layerLink = LayerLink();
  String? selectedValue;

  @override
  void initState() {
    super.initState();
    selectedValue = widget.value;
  }

  @override
  void didUpdateWidget(covariant CustomDropdownButton2 oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != oldWidget.value || widget.items != oldWidget.items) {
      setState(() {
        selectedValue = widget.value;
      });
    }
  }

  void _toggleDropdown() {
    if (_isOpen) {
      _closeDropdown();
    } else {
      _openDropdown();
    }
  }

  void _openDropdown() {
    final overlay = Overlay.of(context);
    _overlayEntry = _createOverlayEntry();
    overlay.insert(_overlayEntry!);
    setState(() {
      _isOpen = true;
    });
  }

  void _closeDropdown() {
    _overlayEntry?.remove();
    setState(() {
      _isOpen = false;
    });
  }

  OverlayEntry _createOverlayEntry() {
    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final size = renderBox.size;

    return OverlayEntry(
      builder: (context) => Positioned(
        width: size.width,
        child: CompositedTransformFollower(
          link: _layerLink,
          showWhenUnlinked: false,
          offset: Offset(0, size.height),
          child: Material(
            elevation: 4,
            child: Container(
              constraints: BoxConstraints(
                maxHeight: 4.6 * 50.h, // Adjust height based on item count
              ),
              decoration: BoxDecoration(
                color: Provider.of<ThemeNotifier>(context)
                    .currentTheme
                    .dropDownColor,
                border: Border.all(
                  color: CommonColors.blue,
                  width: 1.w,
                ),
              ),
              child: ListView.builder(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                physics: ClampingScrollPhysics(), // Prevents bounce effect
                itemCount: widget.items.length,
                itemBuilder: (context, index) {
                  return Column(
                    children: [
                      ListTile(
                        minTileHeight: 50.h,
                        titleAlignment: ListTileTitleAlignment.center,
                        title: Text(
                          widget.items[index],
                          textAlign: TextAlign.center,
                          style: GoogleFonts.robotoMono(
                            fontSize: ThemeNotifier.small.responsiveSp,
                            color: Provider.of<ThemeNotifier>(context)
                                .currentTheme
                                .basicAdvanceTextColor,
                          ),
                        ),
                        onTap: () {
                          widget.onChanged(widget.items[index]);
                          setState(() {
                            selectedValue = widget.items[index];
                          });
                          _closeDropdown();
                        },
                      ),
                      Divider(
                        height: 0.5.h,
                        color: CommonColors.blue,
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _toggleDropdown,
      child: CompositedTransformTarget(
        link: _layerLink,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: 50.91.h,
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage("assets/images/basic_advance.png"),
                  fit: BoxFit.fill,
                ),
              ),
              child: Row(
                children: [
                  widget.fieldNameVisible ? Row(
                    children: [
                      SizedBox(width: 10.w),
                      SizedBox(
                        width: widget.width1.w,
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Text(
                            widget.fieldName,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.robotoMono(
                              fontSize: ThemeNotifier.small.responsiveSp,
                              color: Provider.of<ThemeNotifier>(context)
                                  .currentTheme
                                  .basicAdvanceTextColor,
                            ),
                          ),
                        ),
                      ),
                      Container(width: 10.w),
                      Container(
                        height: 50.91.h,
                        width: 1.w,
                        color: CommonColors.blue,
                      ),
                    ],
                  ) : Container(),
                  GestureDetector(
                    onTap: _toggleDropdown,
                    child: Container(
                      width: widget.width2.w + 30.responsiveSp,
                      height: 40.h,
                      alignment: Alignment.center,
                      padding: EdgeInsets.symmetric(horizontal: 8.w),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Text(
                                selectedValue ?? '-',
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.robotoMono(
                                  fontSize: ThemeNotifier.small.responsiveSp,
                                  color: Provider.of<ThemeNotifier>(context)
                                      .currentTheme
                                      .basicAdvanceTextColor,
                                ),
                              ),
                            ),
                          ),
                          Icon(
                            _isOpen
                                ? Icons.arrow_drop_up
                                : Icons.arrow_drop_down,
                            size: 30.responsiveSp,
                            color: Provider.of<ThemeNotifier>(context)
                                .currentTheme
                                .basicAdvanceTextColor,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}