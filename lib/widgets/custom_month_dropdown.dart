import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../utils/pok.dart';
import '../../bloc/dashboard_bloc.dart';
import '../../constants/theme2.dart';
import '../../utils/alert_message.dart';
import '../../utils/new_loader.dart';
import 'customButton.dart';

class CustomMonthDropdown extends StatefulWidget {
  const CustomMonthDropdown({super.key});

  @override
  _CustomMonthDropdownState createState() => _CustomMonthDropdownState();
}

class _CustomMonthDropdownState extends State<CustomMonthDropdown>
    with SingleTickerProviderStateMixin {
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;
  bool _isDropdownOpen = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  String selectedMonth = '';

  @override
  void initState() {
    super.initState();
    final dashboardBloc = BlocProvider.of<DashboardBloc>(context);
    selectedMonth = dashboardBloc.selectedMonth.toString();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Ink(
        color: Provider.of<ThemeNotifier>(context).currentTheme.dropDownColor,
        child: InkWell(
          onTap: _toggleDropdown,
          splashFactory: InkRipple.splashFactory,
          splashColor: Provider.of<ThemeNotifier>(context, listen: false)
              .currentTheme
              .splashColor,
          child: CompositedTransformTarget(
            link: _layerLink,
            child: Container(
              decoration: BoxDecoration(
                border: Border(
                  left: BorderSide(
                    color: CommonColors.green,
                    width: 12.minSp,
                  ),
                ),
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 12.w),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        BlocProvider.of<DashboardBloc>(context)
                            .convertMonthNumberToText(selectedMonth)
                            .toUpperCase(),
                        style: GoogleFonts.robotoMono(
                          fontSize: ThemeNotifier.small.minSp,
                          color: Provider.of<ThemeNotifier>(context)
                              .currentTheme
                              .basicAdvanceTextColor,
                        ),
                      ),
                    ),
                    Icon(
                      Icons.arrow_drop_down,
                      color: Provider.of<ThemeNotifier>(context)
                          .currentTheme
                          .basicAdvanceTextColor,
                      size: 30.minSp,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _toggleDropdown() {
    if (_isDropdownOpen) {
      _closeDropdown();
    } else {
      _openDropdown();
    }
  }

  void _openDropdown() {
    final overlay = Overlay.of(context);
    _overlayEntry = _createOverlayEntry(context);
    overlay.insert(_overlayEntry!);
    _animationController.forward();
    setState(() {
      _isDropdownOpen = true;
    });
  }

  void _closeDropdown() {
    _animationController.reverse().then((_) {
      _overlayEntry?.remove();
      setState(() {
        _isDropdownOpen = false;
      });
    });
  }

  OverlayEntry _createOverlayEntry(BuildContext context) {
    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final size = renderBox.size;

    return OverlayEntry(
      builder: (context2) => Stack(
        children: [
          Positioned.fill(
            child: GestureDetector(
              onTap: _closeDropdown,
              behavior: HitTestBehavior.opaque,
              child: Container(
                color: Colors.transparent,
              ),
            ),
          ),
          Positioned(
            width: size.width,
            child: CompositedTransformFollower(
              link: _layerLink,
              showWhenUnlinked: false,
              offset: Offset(0, size.height + 3.minSp),
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Material(
                  elevation: 4,
                  child: Container(
                    constraints: BoxConstraints(
                      minHeight: 100.h,
                      maxHeight: MediaQuery.of(context).size.height * 0.7,
                    ),
                    decoration: BoxDecoration(
                      color: Provider.of<ThemeNotifier>(context)
                          .currentTheme
                          .dropDownColor,
                    ),
                    child: StringSelectorOverlay(
                      context: context,
                      values: BlocProvider.of<DashboardBloc>(context).getMonthNumbers(),
                      initialValue: selectedMonth,
                      onValueSelected: _onMonthSelected,
                      onClose: _closeDropdown,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _onMonthSelected(String newValue) async {
    if (newValue != selectedMonth) {
      final dashboardBloc = BlocProvider.of<DashboardBloc>(context);
      int? monthNumber = int.tryParse(newValue);
      if (monthNumber == null) {
        return;
      }

      bool shouldChange = await LoaderUtility.showLoader(
        context,
        dashboardBloc
            .selectMonth(monthNumber)
            .then((_) => true)
            .catchError((e) {
          CustomAlert.showCustomScaffoldMessenger(
              context, "$e", AlertType.error);
          return false;
        }),
      );
      if (shouldChange) {
        setState(() {
          selectedMonth = newValue;
        });
      }
      _closeDropdown();
    }
  }
}

class StringSelectorOverlay extends StatefulWidget {
  final List<String> values;
  final String initialValue;
  final ValueChanged<String> onValueSelected;
  final VoidCallback onClose;
  final BuildContext context;

  StringSelectorOverlay({
    required this.values,
    required this.initialValue,
    required this.onValueSelected,
    required this.onClose,
    required this.context,
  });

  @override
  _StringSelectorOverlayState createState() => _StringSelectorOverlayState();
}

class _StringSelectorOverlayState extends State<StringSelectorOverlay> {
  late String _currentValue;
  late FixedExtentScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _currentValue = widget.initialValue;

    int initialIndex = widget.values.indexOf(_currentValue);
    if (initialIndex == -1) {
      initialIndex = 0;
      _currentValue = widget.values[0];
    }
    _scrollController = FixedExtentScrollController(initialItem: initialIndex);
  }

  @override
  Widget build(BuildContext context) {
    final dashboardBloc = BlocProvider.of<DashboardBloc>(widget.context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          height: 200.h,
          child: ListWheelScrollView.useDelegate(
            controller: _scrollController,
            itemExtent: 60,
            perspective: 0.005,
            diameterRatio: 1.6,
            physics: FixedExtentScrollPhysics(),
            onSelectedItemChanged: (index) {
              setState(() {
                _currentValue = widget.values[index];
              });
            },
            childDelegate: ListWheelChildBuilderDelegate(
              childCount: widget.values.length,
              builder: (context, index) {
                final monthText = dashboardBloc.convertMonthNumberToText(widget.values[index]);
                return StringItem(
                  value: monthText,
                  isSelected: _currentValue == widget.values[index],
                );
              },
            ),
          ),
        ),
        SizedBox(height: 20.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            CustomButton(
              text: "CANCEL",
              onPressed: widget.onClose,
              isRed: true,
            ),
            CustomButton(
              text: "CONFIRM",
              onPressed: () {
                widget.onValueSelected(_currentValue);
              },
            ),
          ],
        ),
        SizedBox(height: 20.h),
      ],
    );
  }
}

class StringItem extends StatelessWidget {
  final String value;
  final bool isSelected;

  StringItem({
    required this.value,
    required this.isSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: Container(
        width: 311.w,
        decoration: BoxDecoration(
          color: isSelected
              ? Provider.of<ThemeNotifier>(context).currentTheme.numberWheelSelectedBG
              : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Center(
          child: Text(
            value.toUpperCase(),
            style: GoogleFonts.robotoMono(
              textStyle: TextStyle(
                  fontSize: ThemeNotifier.medium.minSp,
                  color: Provider.of<ThemeNotifier>(context).currentTheme.basicAdvanceTextColor),
            ),
          ),
        ),
      ),
    );
  }
}
