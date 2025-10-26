
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_breadcrumb/flutter_breadcrumb.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../utils/pok.dart';

import '../../bloc/dashboard_bloc.dart';
import '../../models/filterAndSummaryForProject.dart';
import '../../constants/theme2.dart';
import '../../utils/alert_message.dart';
import '../../utils/new_loader.dart';
import '../../widgets/custom_dropdown.dart';
import '../../widgets/customButton.dart';

class CustomMultipleSelectorHorizontal extends StatefulWidget {
  const CustomMultipleSelectorHorizontal({super.key});

  @override
  _CustomMultipleSelectorHorizontalState createState() =>
      _CustomMultipleSelectorHorizontalState();
}

class _CustomMultipleSelectorHorizontalState
    extends State<CustomMultipleSelectorHorizontal>
    with SingleTickerProviderStateMixin {
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;
  bool _isDropdownOpen = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
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
          child: Container(
            decoration: BoxDecoration(border: Border()
                ),
            child: CompositedTransformTarget(
              link: _layerLink,
              child: Container(
                decoration: BoxDecoration(
                    border: Border(
                      left: BorderSide(
                        color: CommonColors.yellow,
                        width: 10.responsiveSp,
                      ),
                      top: BorderSide(
                        color: CommonColors.yellow,
                        width: 3.responsiveSp,
                      ),
                      
                      
                    )
                ),
                child: Padding(
                  padding:
                      EdgeInsets.symmetric(vertical: 8.h, horizontal: 12.w),
                  child: Container(
                    color: Colors.transparent,
                    child: Row(
                      children: [
                        Expanded(
                          child: BreadCrumb(
                            items: _buildBreadcrumbItems(context,
                                BlocProvider.of<DashboardBloc>(context)),
                            divider: Icon(
                              Icons.chevron_right,
                              color: Provider.of<ThemeNotifier>(context)
                                  .currentTheme
                                  .basicAdvanceTextColor,
                            ),
                            overflow: const WrapOverflow(
                              keepLastDivider: false,
                              direction: Axis.horizontal,
                            ),
                          ),
                        ),
                        Icon(
                          Icons.arrow_drop_down,
                          color: Provider.of<ThemeNotifier>(context)
                              .currentTheme
                              .basicAdvanceTextColor,
                          size: 30.responsiveSp,
                        )
                      ],
                    ),
                  ),
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
    _overlayEntry = _createOverlayEntry();
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

  OverlayEntry _createOverlayEntry() {
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
                color: Colors.transparent, // This makes the container invisible
              ),
            ),
          ),
          // This Positioned widget will hold your dropdown content
          Positioned(
            width: size.width,
            child: CompositedTransformFollower(
              link: _layerLink,
              showWhenUnlinked: false,
              offset: Offset(0, size.height + 3.responsiveSp),
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Material(
                  elevation: 4,
                  // borderRadius: BorderRadius.circular(8),
                  child: Container(
                    constraints: BoxConstraints(
                      minHeight: 100.h,
                      maxHeight: MediaQuery.of(context).size.height * 0.7,
                    ),
                    decoration: BoxDecoration(
                      color: Provider.of<ThemeNotifier>(context)
                          .currentTheme
                          .dialogBG,
                      // borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                      color: Provider.of<ThemeNotifier>(context).currentTheme.gridLineColor, // Match BillingFormula border color
                      width: 3.responsiveSp, // Match BillingFormula border width
                ),
                    ),
                    child: GestureDetector(
                      onTap: () {},
                      child: DropdownContent(
                        context: context,
                        onProjectSelected: (project, filters) {
                          // Handle selection
                        },
                        onClose: _closeDropdown,
                      ),
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

  List<BreadCrumbItem> _buildBreadcrumbItems(
    BuildContext context, DashboardBloc dashboardBloc) {
    final selectedFilters = dashboardBloc.currentFilters;

    List<BreadCrumbItem> breadcrumbItems = [];

    for (int index = 1; index < selectedFilters.length; index++) {
      final filter = selectedFilters[index];
      if (filter.isNotEmpty) {
        breadcrumbItems.add(
          BreadCrumbItem(
            content: Text(
              filter.toUpperCase(),
              style: GoogleFonts.robotoMono(
                fontSize: ThemeNotifier.small.responsiveSp,
                color: Provider.of<ThemeNotifier>(context)
                    .currentTheme
                    .basicAdvanceTextColor,
              ),
            ),
          ),
        );
      }
    }

    if (breadcrumbItems.isEmpty &&
        dashboardBloc.filterData?.nestedLevels != null) {
      final buildings =
          dashboardBloc.filterData!.nestedLevels.keys.toList().cast<String>();
      if (buildings.isNotEmpty) {
        breadcrumbItems.add(
          BreadCrumbItem(
            content: Text(
              buildings.first.toUpperCase(),
              style: GoogleFonts.robotoMono(
                fontSize: ThemeNotifier.small.responsiveSp,
                color: Provider.of<ThemeNotifier>(context)
                    .currentTheme
                    .basicAdvanceTextColor,
              ),
            ),
          ),
        );
      }
    }

    // Ensure we always return at least one breadcrumb item to prevent the assertion error
    if (breadcrumbItems.isEmpty) {
      breadcrumbItems.add(
        BreadCrumbItem(
          content: Text(
            "NO FILTER SELECTED",
            style: GoogleFonts.robotoMono(
              fontSize: ThemeNotifier.small.responsiveSp,
              color: Provider.of<ThemeNotifier>(context)
                  .currentTheme
                  .basicAdvanceTextColor,
            ),
          ),
        ),
      );
    }

    return breadcrumbItems;
  }


}

class DropdownContent extends StatefulWidget {
  final Function(String?, List<String?>) onProjectSelected;
  final VoidCallback onClose;
  final BuildContext context;

  const DropdownContent({
    super.key,
    required this.onProjectSelected,
    required this.onClose,
    required this.context,
  });

  @override
  _DropdownContentState createState() => _DropdownContentState();
}

class _DropdownContentState extends State<DropdownContent> {
  List<String?> selectedFilters = [];
  List<String> levels = [];
  FilterAndSummaryForProject? filterData;

  late DashboardBloc dashboardBloc;


  @override
  void initState() {
    super.initState();
    dashboardBloc = BlocProvider.of<DashboardBloc>(widget.context);
    _initializeData();
  }

  void _initializeData() {
    levels = ['Project', ...?dashboardBloc.filterData?.levels];

    selectedFilters = List.generate(levels.length, (i) {
      return dashboardBloc.currentFilters.elementAtOrNull(i);
    });

    filterData = dashboardBloc.filterData;
  }

  


  @override
  Widget build(BuildContext context) {
    final projects = dashboardBloc.projects;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(height: 12.h),
        for (int index = 1; index < levels.length; index++)
          Builder(
            builder: (context) {
              var items = _getItemsForLevel(index, projects);

              return Padding(
                padding: EdgeInsets.symmetric(vertical: 8.h),
                child: CustomDropdownButton2(
                  fieldName: levels[index],
                  value: selectedFilters[index],
                  items: items,
                  onChanged: (value) => _onFilterChanged(index, value),
                ),
              );
            }
          ),
        SizedBox(height: 20.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // SizedBox(
            //   width: 273.w + 30.responsiveSp, // Match dropdown width
            //   child: Row(
            //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //     children: [
                  
            //     ],
            //   ),
            // ),
            CustomButton(
              text: 'CANCEL',
              isRed: true,
              onPressed: widget.onClose,
              width: 120.w, // Fixed width for each button
            ),
            SizedBox(width: 160.w),
            CustomButton(
              text: 'CONFIRM',
              onPressed: _onConfirm,
              width: 120.w, // Fixed width for each button
            ),
          ],
        ),
        SizedBox(height: 20.h),
        
      ],
    );
  }

  void _onFilterChanged(int index, String? value) async {
  if (index == 0) {
    try {
      filterData = await LoaderUtility.showLoader(
        context,
        dashboardBloc.selectProject(dashboardBloc.projects.indexOf(value!)),
      );

      setState(() {
        levels = ['Project', ...?filterData?.levels];
        selectedFilters = [value, ...List.filled(levels.length - 1, null)];

        // ✅ Immediately check if level 1 has only 1 option
        final items = _getFilterItems(1);
        if (items.length == 1) {
          selectedFilters[1] = items.first;
        }
      });
    } catch (e) {
      CustomAlert.showCustomScaffoldMessenger(
        context,
        e.toString(),
        AlertType.error,
      );
    }
  } else {
    if (value == "-") value = null;

    setState(() {
      selectedFilters[index] = value;

      for (int i = index + 1; i < selectedFilters.length; i++) {
        selectedFilters[i] = null;
      }

      if (value != null && index + 1 < levels.length) {
        final nextItems = _getFilterItems(index + 1);
        if (nextItems.length == 1) {
          selectedFilters[index + 1] = nextItems.first;
        }
      }
    });
  }
}


  void _onConfirm() {
    widget.onProjectSelected(selectedFilters.first, selectedFilters);
    LoaderUtility.showLoader(
      context,
      dashboardBloc.updateSelectedFilters(selectedFilters, filterData),
    ).then((value) {
      widget.onClose();
    }).catchError((e) {
      CustomAlert.showCustomScaffoldMessenger(
        context,
        e.toString(),
        AlertType.error,
      );
      throw e;
    });
  }

  List<String> _getItemsForLevel(int level, List<String> projects) {
    if (level == 0) {
      return projects;
    } else {
      var items = _getFilterItems(level);

      if (items.isNotEmpty) {
        items = ["-", ...items];

        // Auto-preselect if only one valid option and not selected yet
        if (items.length == 2 && selectedFilters[level] == null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              setState(() {
                selectedFilters[level] = items[1]; // auto-select first option
              });

              // Persist auto-selection into Bloc
              dashboardBloc.updateSelectedFilters(selectedFilters, filterData);
            }
          });
        }
      }

      return items;
    }
  }





  List<String> _getFilterItems(int level) {
    if (selectedFilters[0] == null || filterData == null) {
      return [];
    }

    dynamic currentLevel = filterData!.nestedLevels;

    if (currentLevel == null || level > filterData!.levels.length) {
      return [];
    }

    for (int i = 1; i < level; i++) {
      // Start loop from 1 since we already handled level 0
      var selectedValue = selectedFilters[i];
      if (selectedValue != null && currentLevel != null) {
        currentLevel = currentLevel[selectedValue];
      } else {
        return []; // If selected value is null or invalid, return an empty list
      }
    }

    if (currentLevel is List) {
      return currentLevel.cast<String>();
    }

    if (currentLevel is Map<dynamic, dynamic>) {
      return currentLevel.keys.toList().cast<String>();
    }

    return [];
  }
}

class CustomMultipleSelectorHorizontal2 extends StatefulWidget {
  const CustomMultipleSelectorHorizontal2({super.key});

  @override
  State<CustomMultipleSelectorHorizontal2> createState() =>
      _CustomMultipleSelectorHorizontal2State();
}

class _CustomMultipleSelectorHorizontal2State
    extends State<CustomMultipleSelectorHorizontal2> {


  @override
  Widget build(BuildContext context) {


    return Material(
      color: Provider.of<ThemeNotifier>(context).currentTheme.bgColor,
      child: Container(
        decoration: BoxDecoration(
          border: Border(
            left: BorderSide(
              color: CommonColors.yellow,
              width: 12, // Use static width here
            ),
          ),
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 12.w),
          child: Container(
            color: Colors.transparent,
            child: Row(
              children: [
                Expanded(
                  child: BreadCrumb(
                    items: _buildBreadcrumbItems(
                        context, BlocProvider.of<DashboardBloc>(context)),
                    divider: Icon(
                      Icons.chevron_right,
                      color: Provider.of<ThemeNotifier>(context).currentTheme.dialogBG,
                    ),
                    overflow: const WrapOverflow(
                      keepLastDivider: false,
                      direction: Axis.horizontal,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Mocking the breadcrumb items
  List<BreadCrumbItem> _buildBreadcrumbItems(
    BuildContext context, DashboardBloc dashboardBloc) {
    final selectedFilters = dashboardBloc.currentFilters;

    if (selectedFilters.isEmpty) {
      return [
        BreadCrumbItem(
          content: Text(
            "NO FILTER SELECTED",
            style: GoogleFonts.robotoMono(
              fontSize: ThemeNotifier.small.responsiveSp,
              color: Provider.of<ThemeNotifier>(context).currentTheme.basicAdvanceTextColor,
            ),
          ),
        ),
      ];
    }

    return selectedFilters
        .where((f) => f.isNotEmpty)
        .map((f) => BreadCrumbItem(
              content: Text(
                f.toUpperCase(),
                style: GoogleFonts.robotoMono(
                  fontSize: ThemeNotifier.small.responsiveSp,
                  color: Provider.of<ThemeNotifier>(context).currentTheme.basicAdvanceTextColor,
                ),
              ),
            ))
        .toList();
  }

}
