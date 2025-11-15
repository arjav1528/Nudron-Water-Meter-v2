
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_breadcrumb/flutter_breadcrumb.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../bloc/dashboard_bloc.dart';
import '../../models/filterAndSummaryForProject.dart';
import '../../constants/theme2.dart';
import '../../constants/ui_config.dart';
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
        : UIConfig.getDesktopProjectWidth(context);
    
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
                height: UIConfig.headerWidgetHeight,
                decoration: BoxDecoration(
                    border: Border(
                      left: BorderSide(
                        color: UIConfig.accentColorYellow,
                        width: UIConfig.headerWidgetBorderWidth,
                      ),
                    )
                ),
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: UIConfig.spacingSmall.h, horizontal: UIConfig.spacingMedium.w),
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
                          size: UIConfig.iconSizeLarge,
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
              offset: Offset(0, size.height + UIConfig.accentLineHeightResponsive),
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Material(
                  elevation: 4,
                  
                  child: Container(
                    constraints: BoxConstraints(
                      minHeight: UIConfig.spacingXXXLarge * 2.5,
                      maxHeight: MediaQuery.of(context).size.height * UIConfig.opacityVeryHigh,
                    ),
                    decoration: BoxDecoration(
                      color: Provider.of<ThemeNotifier>(context)
                          .currentTheme
                          .dialogBG,
                      
                      border: Border.all(
                      color: Provider.of<ThemeNotifier>(context).currentTheme.gridLineColor, 
                      width: UIConfig.dialogBorderWidth, 
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
    final fontSize = UIConfig.fontSizeMediumResponsive;

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
    final width = UIConfig.getDesktopProjectWidth(context);

    // Calculate the actual width1 and width2 used in dropdowns
    final dropdownWidth1 = PlatformUtils.isMobile ? UIConfig.spacingExtraLarge * 5.w : width * UIConfig.desktopProjectWidthMultiplier;
    final dropdownWidth2 = PlatformUtils.isMobile ? UIConfig.desktopDrawerWidthMin - 187.w : width * (1 - UIConfig.desktopProjectWidthMultiplier);

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: PlatformUtils.isMobile ? UIConfig.spacingMedium.w : 0,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(height: UIConfig.spacingMedium.h),
          for (int index = 1; index < levels.length; index++)
            Builder(
              builder: (context) {
                var items = _getItemsForLevel(index, projects);

                final width1 = PlatformUtils.isMobile ? UIConfig.spacingExtraLarge * 5.w : width * UIConfig.desktopProjectWidthMultiplier;
                final width2 = PlatformUtils.isMobile ? UIConfig.desktopDrawerWidthMin - 187.w : width * (1 - UIConfig.desktopProjectWidthMultiplier);

                return Padding(
                  padding: EdgeInsets.symmetric(vertical: UIConfig.paddingSymmetricVerticalSmall.vertical),
                  child: CustomDropdownButton2(
                    width1: width1,
                    width2: width2,
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
          SizedBox(height: UIConfig.spacingExtraLarge),
          SizedBox(
            width: PlatformUtils.isMobile 
                ? dropdownWidth1 + dropdownWidth2 + UIConfig.spacingXXXLarge * 0.4.w
                : dropdownWidth1 + dropdownWidth2 - UIConfig.spacingXXXLarge * 0.5,
           
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                
                CustomButton(
                  text: 'CANCEL',
                  isRed: true,
                  dynamicWidth: true,
                  onPressed: widget.onClose,
                  width: UIConfig.buttonDefaultWidth + 8.w, 
                ),
                // SizedBox(width: UIConfig.spacingXXXLarge * 4.w),
                CustomButton(
                  text: 'CONFIRM',
                  dynamicWidth: true,
                  onPressed: _onConfirm,
                  width: UIConfig.buttonDefaultWidth + 8.w, 
                ),
              ],
            ),
          ),
          SizedBox(height: UIConfig.spacingExtraLarge),
          
        ],
      ),
    );
  }

  void _onFilterChanged(int index, String? value) async {
  if (index == 0) {
    // Only fetch filterData for UI purposes, don't update bloc state yet
    // This is needed to populate nested dropdowns
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

  void _onConfirm() async {
    final parentContext = widget.context;
    
    // Check if project changed and needs to be selected first
    final currentProject = dashboardBloc.currentFilters.firstOrNull;
    final selectedProject = selectedFilters.first;
    
    try {
      // If project changed, select it first (this fetches filterData if needed)
      if (selectedProject != null && selectedProject != currentProject) {
        final projectIndex = dashboardBloc.projects.indexOf(selectedProject);
        if (projectIndex >= 0) {
          filterData = await LoaderUtility.showLoader(
            parentContext,
            dashboardBloc.selectProject(projectIndex),
          );
        }
      }
      
      // Now update the selected filters - this will trigger all API calls
      widget.onClose();
      widget.onProjectSelected(selectedFilters.first, selectedFilters);
      
      await LoaderUtility.showLoader(
        parentContext,
        dashboardBloc.updateSelectedFilters(selectedFilters, filterData),
      );
    } catch (e) {
      if (mounted) {
        CustomAlert.showCustomScaffoldMessenger(
          parentContext,
          e.toString(),
          AlertType.error,
        );
      }
      throw e;
    }
  }

  List<String> _getItemsForLevel(int level, List<String> projects) {
    if (level == 0) {
      return projects;
    } else {
      var items = _getFilterItems(level);

      if (items.isNotEmpty) {
        items = ["-", ...items];

        // Only update local state, don't trigger API calls
        // API calls will only happen when confirm button is clicked
        if (items.length == 2 && selectedFilters[level] == null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              setState(() {
                selectedFilters[level] = items[1]; 
              });
              // Removed: dashboardBloc.updateSelectedFilters(selectedFilters, filterData);
              // This was causing premature API calls
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
        : UIConfig.getDesktopProjectWidth(context);

    return Material(
      color: Provider.of<ThemeNotifier>(context).currentTheme.bgColor,
      child: Container(
        height: UIConfig.headerWidgetHeight,
        decoration: BoxDecoration(
          border: Border(
            left: BorderSide(
              color: UIConfig.accentColorYellow,
              width: UIConfig.headerWidgetBorderWidth, 
            ),
          ),
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: UIConfig.spacingSmall.h, horizontal: UIConfig.spacingMedium.w),
          child: Container(
            color: Colors.transparent,
            child: Row(
              children: [
                Expanded(
                  child: BreadCrumb(
                    items: _buildBreadcrumbItems(
                        context, BlocProvider.of<DashboardBloc>(context), width),
                    divider: Center(
                      child: Icon(
                        Icons.chevron_right,
                        color: Provider.of<ThemeNotifier>(context).currentTheme.dialogBG,
                      ),
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
    final fontSize = UIConfig.fontSizeMediumResponsive;

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
