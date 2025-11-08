import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:watermeter2/services/platform_utils.dart';
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
    // Calculate font size gradient for desktop
    final totalWidth = PlatformUtils.isMobile 
        ? null 
        : (widget.width1 + widget.width2 + 30.0 + 20.0); // width1 + width2 + icon space + padding
    final fontSize = PlatformUtils.isMobile 
        ? ThemeNotifier.small.responsiveSp 
        : (totalWidth ?? 400) / 30;
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Stack(
          children: [
            Positioned.fill(
              child: CustomPaint(
                painter: RPSCustomPainter(),
              ),
            ),
            SizedBox(
              height: 50.91.h,
              child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  width: 10.w,
                ),
                SizedBox(
                  width: PlatformUtils.isMobile ? widget.width1.w : widget.width1,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Text(
                      widget.fieldName,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.robotoMono(
                        fontSize: fontSize,
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
                    dropdownWidth: PlatformUtils.isMobile ? widget.width2.w + 30.responsiveSp : widget.width2 + 30.0,
                    buttonWidth: (PlatformUtils.isMobile ? widget.width2.w : widget.width2) + (PlatformUtils.isMobile ? 30.responsiveSp : 30.0),
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
                      width: (PlatformUtils.isMobile ? widget.width2.w : widget.width2) + (PlatformUtils.isMobile ? 30.responsiveSp : 30.0),
                      height: 40.h,
                      alignment: Alignment.center,
                      padding: EdgeInsets.only(left: 12.w, right: 8.w),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          SizedBox(
                            width: PlatformUtils.isMobile ? (widget.width2 - 1).w : (widget.width2 - 1),
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
                                    fontSize: fontSize,
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
                              width: PlatformUtils.isMobile ? widget.width2.w + 30.responsiveSp : widget.width2 + 30.0,
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
                                  fontSize: fontSize,
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
                      if (toChange && mounted) {
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
          ],
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
  final double? desktopDropdownWidth;

  const CustomDropdownButton2({
    super.key,
    required this.fieldName,
    required this.value,
    required this.items,
    required this.onChanged,
    this.width1 = 80,
    this.width2 = 273,
    this.fieldNameVisible = true,
    this.desktopDropdownWidth,
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

  @override
  void dispose() {
    _overlayEntry?.remove();
    _overlayEntry = null;
    super.dispose();
  }

  void _toggleDropdown() {
    if (_isOpen) {
      _closeDropdown();
    } else {
      _openDropdown();
    }
  }

  void _openDropdown() {
    if (!mounted) return;
    final overlay = Overlay.of(context);
    _overlayEntry = _createOverlayEntry();
    overlay.insert(_overlayEntry!);
    if (mounted) {
      setState(() {
        _isOpen = true;
      });
    }
  }

  void _closeDropdown() {
    _overlayEntry?.remove();
    _overlayEntry = null;
    if (mounted) {
      setState(() {
        _isOpen = false;
      });
    }
  }

  OverlayEntry _createOverlayEntry() {
    if (!mounted) {
      return OverlayEntry(builder: (_) => const SizedBox.shrink());
    }
    final RenderBox? renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox == null || !renderBox.attached) {
      return OverlayEntry(builder: (_) => const SizedBox.shrink());
    }
    final size = renderBox.size;

    // Calculate font size gradient for desktop
    final totalWidth = PlatformUtils.isMobile 
        ? null 
        : (widget.width1 + widget.width2 + 30.0 + 20.0);
    final fontSize = PlatformUtils.isMobile 
        ? ThemeNotifier.small.responsiveSp 
        : (totalWidth ?? 400) / 30;

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
                maxHeight: 4.6 * 50.h, 
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
                physics: ClampingScrollPhysics(), 
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
                            fontSize: fontSize,
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
    // Calculate font size gradient for desktop
    final totalWidth = PlatformUtils.isMobile 
        ? null 
        : (widget.width1 + widget.width2 + 30.0 + 20.0); // width1 + width2 + icon space + padding
    final fontSize = PlatformUtils.isMobile 
        ? ThemeNotifier.small.responsiveSp 
        : (totalWidth ?? 400) / 30;
    
    return GestureDetector(
      onTap: _toggleDropdown,
      child: CompositedTransformTarget(
        link: _layerLink,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              children: [
                Positioned.fill(
                  child: CustomPaint(
                    painter: RPSCustomPainter(),
                  ),
                ),
                SizedBox(
                  height: 50.91.h,
                  child: Row(
                    children: [
                      widget.fieldNameVisible ? Row(
                        children: [
                          SizedBox(width: 10.w),
                          SizedBox(
                            width: widget.width1.w,
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Padding(
                                padding: EdgeInsets.only(left: 8.w),
                                child: Text(
                                  widget.fieldName,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.robotoMono(
                                    fontSize: fontSize,
                                    color: Provider.of<ThemeNotifier>(context)
                                        .currentTheme
                                        .basicAdvanceTextColor,
                                  ),
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
                          width: PlatformUtils.isMobile ? widget.width2.w + 30.responsiveSp : widget.width2 + 30.0,
                          height: 40.h,
                          alignment: Alignment.center,
                          padding: EdgeInsets.symmetric(horizontal: 8.w),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: Padding(
                                    padding: EdgeInsets.only(left: 15.w),
                                    child: Text(
                                      selectedValue ?? '-',
                                      overflow: TextOverflow.ellipsis,
                                      style: GoogleFonts.robotoMono(
                                        fontSize: fontSize,
                                        color: Provider.of<ThemeNotifier>(context)
                                            .currentTheme
                                            .basicAdvanceTextColor,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Icon(
                                _isOpen
                                    ? Icons.arrow_drop_up
                                    : Icons.arrow_drop_down,
                                size: 35.responsiveSp,
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
          ],
        ),
      ),
    );
  }
}

class RPSCustomPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    Path path_0 = Path();
    path_0.moveTo(size.width * 0.9797295, 0);
    path_0.lineTo(size.width * 0.02027029, 0);
    path_0.lineTo(0, size.height * 0.4991373);
    path_0.lineTo(size.width * 0.02027029, size.height * 0.9982745);
    path_0.lineTo(size.width * 0.9797295, size.height * 0.9982745);
    path_0.lineTo(size.width, size.height * 0.4991373);
    path_0.lineTo(size.width * 0.9797295, 0);
    path_0.close();
    path_0.moveTo(size.width * 0.9767254, size.height * 0.9223196);
    path_0.lineTo(size.width * 0.02327328, size.height * 0.9223196);
    path_0.lineTo(size.width * 0.006756762, size.height * 0.4991373);
    path_0.lineTo(size.width * 0.02327328, size.height * 0.07595529);
    path_0.lineTo(size.width * 0.9767254, size.height * 0.07595529);
    path_0.lineTo(size.width * 0.9932418, size.height * 0.4991373);
    path_0.lineTo(size.width * 0.9767254, size.height * 0.9223196);
    path_0.close();

    Paint paint_0_fill = Paint()..style = PaintingStyle.fill;
    paint_0_fill.color = Color(0xff145166).withOpacity(1.0);
    canvas.drawPath(path_0, paint_0_fill);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}