
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
import '../../services/platform_utils.dart';

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
    _overlayEntry?.remove();
    _overlayEntry = null;
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final width = PlatformUtils.isMobile 
        ? null 
        : (MediaQuery.of(context).size.width * 1/3).clamp(400.0, 550.0);
    final iconSize = PlatformUtils.isMobile ? 35.responsiveSp : width! / 15.7;
    
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
                                BlocProvider.of<DashboardBloc>(context), width),
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
                          size: iconSize,
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
    if (!mounted) return;
    final overlay = Overlay.of(context);
    _overlayEntry = _createOverlayEntry();
    overlay.insert(_overlayEntry!);
    _animationController.forward();
    if (mounted) {
      setState(() {
        _isDropdownOpen = true;
      });
    }
  }

  void _closeDropdown() {
    _animationController.reverse().then((_) {
      _overlayEntry?.remove();
      _overlayEntry = null;
      if (mounted) {
        setState(() {
          _isDropdownOpen = false;
        });
      }
    });
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
              offset: Offset(0, size.height + 3.responsiveSp),
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
                          .dialogBG,
                      
                      border: Border.all(
                      color: Provider.of<ThemeNotifier>(context).currentTheme.gridLineColor, 
                      width: 3.responsiveSp, 
                ),
                    ),
                    child: GestureDetector(
                      onTap: () {},
                      child: DropdownContent(
                        context: context,
                        onProjectSelected: (project, filters) {
                          
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
    BuildContext context, DashboardBloc dashboardBloc, double? width) {
    final selectedFilters = dashboardBloc.currentFilters;
    final fontSize = PlatformUtils.isMobile 
        ? ThemeNotifier.small.responsiveSp 
        : (width ?? 400) / 30;

    List<BreadCrumbItem> breadcrumbItems = [];

    for (int index = 1; index < selectedFilters.length; index++) {
      final filter = selectedFilters[index];
      if (filter.isNotEmpty) {
        breadcrumbItems.add(
          BreadCrumbItem(
            content: Text(
              filter.toUpperCase(),
              style: GoogleFonts.robotoMono(
                fontSize: fontSize,
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
                fontSize: fontSize,
                color: Provider.of<ThemeNotifier>(context)
                    .currentTheme
                    .basicAdvanceTextColor,
              ),
            ),
          ),
        );
      }
    }

    if (breadcrumbItems.isEmpty) {
      breadcrumbItems.add(
        BreadCrumbItem(
          content: Text(
            "NO FILTER SELECTED",
            style: GoogleFonts.robotoMono(
              fontSize: fontSize,
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
    final width = (MediaQuery.of(context).size.width * 1/3).clamp(400.0, 550.0);

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: PlatformUtils.isMobile ? 12.w : 0,
      ),
      child: Column(
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
                    width1: PlatformUtils.isMobile ? 60.w : 0.33 * width,
                    width2: PlatformUtils.isMobile ? 273.w : 0.66 * width,
                    // desktopDropdownWidth: PlatformUtils.isMobile ? null : width,
                    // desktopDropdownWidth: width - 30,
                    fieldName: levels[index],
                    value: selectedFilters[index],
                    items: items,
                    onChanged: (value) => _onFilterChanged(index, value),
                    fieldNameVisible: true,
                  ),
                );
              }
            ),
          SizedBox(height: 20.h),
          SizedBox(
            // width: PlatformUtils.isMobile ? null : width,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                
                CustomButton(
                  text: 'CANCEL',
                  isRed: true,
                  dynamicWidth: true,
                  onPressed: widget.onClose,
                  width: 120.w, 
                ),
                SizedBox(width: 160.w),
                CustomButton(
                  text: 'CONFIRM',
                  dynamicWidth: true,
                  onPressed: _onConfirm,
                  width: 120.w, 
                ),
              ],
            ),
          ),
          SizedBox(height: 20.h),
          
        ],
      ),
    );
  }

  void _onFilterChanged(int index, String? value) async {
  if (index == 0) {
    try {
      filterData = await LoaderUtility.showLoader(
        context,
        dashboardBloc.selectProject(dashboardBloc.projects.indexOf(value!)),
      );

      if (mounted) {
        setState(() {
          levels = ['Project', ...?filterData?.levels];
          selectedFilters = [value, ...List.filled(levels.length - 1, null)];

          final items = _getFilterItems(1);
          if (items.length == 1) {
            selectedFilters[1] = items.first;
          }
        });
      }
    } catch (e) {
      if (mounted) {
        CustomAlert.showCustomScaffoldMessenger(
          context,
          e.toString(),
          AlertType.error,
        );
      }
    }
  } else {
    if (value == "-") value = null;

    if (mounted) {
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
}

  void _onConfirm() {
    
    final parentContext = widget.context;
    
    widget.onClose();
    
    widget.onProjectSelected(selectedFilters.first, selectedFilters);
    LoaderUtility.showLoader(
      parentContext,
      dashboardBloc.updateSelectedFilters(selectedFilters, filterData),
    ).catchError((e) {
      if (mounted) {
        CustomAlert.showCustomScaffoldMessenger(
          parentContext,
          e.toString(),
          AlertType.error,
        );
      }
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

        if (items.length == 2 && selectedFilters[level] == null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              setState(() {
                selectedFilters[level] = items[1]; 
              });

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
      
      var selectedValue = selectedFilters[i];
      if (selectedValue != null && currentLevel != null) {
        currentLevel = currentLevel[selectedValue];
      } else {
        return []; 
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
    final width = PlatformUtils.isMobile 
        ? null 
        : (MediaQuery.of(context).size.width * 1/3).clamp(400.0, 550.0);

    return Material(
      color: Provider.of<ThemeNotifier>(context).currentTheme.bgColor,
      child: Container(
        decoration: BoxDecoration(
          border: Border(
            left: BorderSide(
              color: CommonColors.yellow,
              width: 12, 
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
                        context, BlocProvider.of<DashboardBloc>(context), width),
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

  List<BreadCrumbItem> _buildBreadcrumbItems(
    BuildContext context, DashboardBloc dashboardBloc, double? width) {
    final selectedFilters = dashboardBloc.currentFilters;
    final fontSize = PlatformUtils.isMobile 
        ? ThemeNotifier.small.responsiveSp 
        : (width ?? 400) / 30;

    if (selectedFilters.isEmpty) {
      return [
        BreadCrumbItem(
          content: Text(
            "NO FILTER SELECTED",
            style: GoogleFonts.robotoMono(
              fontSize: fontSize,
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
                  fontSize: fontSize,
                  color: Provider.of<ThemeNotifier>(context).currentTheme.basicAdvanceTextColor,
                ),
              ),
            ))
        .toList();
  }

}
