
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
import '../../utils/pok.dart';
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
                  padding: EdgeInsets.symmetric(horizontal: UIConfig.spacingMedium.w),
                  child: Container(
                    color: Colors.transparent,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
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
                        Center(
                          child: Icon(
                            Icons.arrow_drop_down,
                            color: Provider.of<ThemeNotifier>(context)
                                .currentTheme
                                .basicAdvanceTextColor,
                            size: 35.responsiveSp,
                          ),
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

    // Calculate the maximum width needed for all field names (labels)
    double maxLabelWidth = 0;
    
    // For desktop: make font size responsive to actual available width to prevent overflow
    final double fontSize = UIConfig.fontSizeSmallResponsive;
    
    final textStyle = GoogleFonts.robotoMono(fontSize: fontSize);
    
    // Measure all labels to find the maximum width
    for (int index = 1; index < levels.length; index++) {
      final textPainter = TextPainter(
        text: TextSpan(text: levels[index], style: textStyle),
        textDirection: TextDirection.ltr,
        maxLines: 1,
      );
      // Layout with no width constraint to get the full text width
      textPainter.layout(maxWidth: double.infinity);
      final labelWidth = textPainter.width;
      if (labelWidth > maxLabelWidth) {
        maxLabelWidth = labelWidth;
      }
      textPainter.dispose();
    }
    
    // Add padding for the label area using UIConfig constants
    final labelPadding = UIConfig.dropdownLabelTotalPadding;
    final dividerWidth = UIConfig.borderWidthThin;
    
    // CustomDropdownButton2 applies .w to width1 (line 425: widget.width1.w)
    // .w converts from design units to screen units based on design size
    // Mobile design size: 430, Desktop design size: 1920
    // So we need to pass width1 in design units
    
    // For mobile: convert logical pixels to design units (divide by scaleWidth)
    // For desktop: convert logical pixels to design units (divide by scaleWidth, which scales to 1920)
    final maxLabelWidthInDesignUnits = maxLabelWidth / ScreenUtil().scaleWidth;
    
    final calculatedWidth1 = maxLabelWidthInDesignUnits + labelPadding;
    
    // Calculate width2 as remaining width after width1, divider, and icon space
    // CustomDropdownButton2 uses width2 differently:
    // - Mobile: applies .w (line 454: widget.width2.w), so needs design units
    // - Desktop: uses directly (line 454: widget.width2), so needs logical pixels
    
    // For mobile: get actual available screen width and constrain to it
    // Account for horizontal padding that will be applied to the dropdown container
    final totalAvailableWidth = PlatformUtils.isMobile 
        ? MediaQuery.of(context).size.width - (UIConfig.spacingMedium.w * 2) // Subtract left and right padding
        : width;
    
    // Convert everything to the appropriate units for width2
    final double calculatedWidth2;
    if (PlatformUtils.isMobile) {
      // For mobile: convert to design units since CustomDropdownButton2 will apply .w
      // Account for all spacing: left padding (10.w), width1, right padding (3.w), divider (1.w), icon space (30.responsiveSp)
      // Add a small buffer (8 design units) to prevent overflow from rounding errors
      final totalInDesignUnits = totalAvailableWidth / ScreenUtil().scaleWidth;
      final width1InDesignUnits = calculatedWidth1; // already in design units
      final leftPaddingInDesignUnits = 10.0 / ScreenUtil().scaleWidth;
      final rightPaddingInDesignUnits = UIConfig.dropdownLabelPaddingRight / ScreenUtil().scaleWidth;
      final dividerInDesignUnits = dividerWidth / ScreenUtil().scaleWidth;
      final iconSpaceInDesignUnits = UIConfig.desktopDropdownIconSpace / ScreenUtil().scaleWidth;
      final safetyBuffer = 8.0 / ScreenUtil().scaleWidth; // Buffer to prevent overflow
      // Subtract all spacing elements and buffer from total width
      calculatedWidth2 = totalInDesignUnits - width1InDesignUnits - leftPaddingInDesignUnits - rightPaddingInDesignUnits - dividerInDesignUnits - iconSpaceInDesignUnits - safetyBuffer;
    } else {
      // For desktop: use logical pixels directly (CustomDropdownButton2 doesn't apply .w)
      // But width1 was converted to design units, so we need to convert it back to logical pixels
      final width1InLogicalPixels = calculatedWidth1 * ScreenUtil().scaleWidth;
      calculatedWidth2 = totalAvailableWidth - width1InLogicalPixels - dividerWidth - UIConfig.desktopDropdownIconSpace;
    }

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

                return Padding(
                  padding: EdgeInsets.symmetric(vertical: UIConfig.paddingSymmetricVerticalSmall.vertical),
                  child: CustomDropdownButton2(
                    width1: calculatedWidth1,
                    width2: calculatedWidth2,
                    // desktopDropdownWidth: PlatformUtils.isMobile ? null : width,
                    // desktopDropdownWidth: width - 30,
                    
                    
                    fieldName: levels[index],
                    value: selectedFilters[index],
                    items: items,
                    onChanged: (value) => _onFilterChanged(index, value),
                    fieldNameVisible: true,
                    customFontSize: fontSize, // Pass responsive font size for desktop
                  ),
                );
              }
            ),
          SizedBox(height: UIConfig.spacingExtraLarge),
          // Calculate the exact dropdown width to align buttons
          Builder(
            builder: (context) {
              // Calculate the total dropdown width (same as the dropdown itself)
              final dropdownTotalWidth = PlatformUtils.isMobile
                  ? (calculatedWidth1.w + calculatedWidth2.w + dividerWidth + UIConfig.desktopDropdownIconSpace.responsiveSp)
                  : (calculatedWidth1 * ScreenUtil().scaleWidth + calculatedWidth2 + dividerWidth + UIConfig.desktopDropdownIconSpace);
              
              return SizedBox(
                width: dropdownTotalWidth,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CustomButton(
                      text: 'CANCEL',
                      isRed: true,
                      dynamicWidth: true,
                      onPressed: widget.onClose,
                      // width: UIConfig.buttonDefaultWidth + UIConfig.buttonWidthExtraPadding,
                      fontSize: ThemeNotifier.large.w,
                    ),
                    CustomButton(
                      text: 'CONFIRM',
                      dynamicWidth: true,
                      onPressed: _onConfirm,
                      // width: UIConfig.buttonDefaultWidth + UIConfig.buttonWidthExtraPadding,
                      fontSize: ThemeNotifier.large.w,
                    ),
                  ],
                ),
              );
            }
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
