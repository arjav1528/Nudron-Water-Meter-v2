import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:watermeter2/utils/pok.dart';
import 'package:watermeter2/services/platform_utils.dart';
import 'package:watermeter2/constants/theme2.dart';

/// Comprehensive UI Configuration File
/// All hardcoded values should be referenced from this file
class UIConfig {
  // Prevent instantiation
  UIConfig._();

  // ==================== DIMENSIONS ====================
  
  /// Row heights
  static double get rowHeight => 41.h;
  static double get tableRowHeight => 41.h;
  static double get headerBarHeight => 41.h;
  static double get sectionBarHeight => 41.h;
  static double get dropdownRowHeight => 50.91.h;
  static double get dropdownItemHeight => 40.h;
  static double get buttonHeight => 44.h;
  static double get bottomNavBarHeight => 69.h;
  
  /// Container heights
  static double get accentLineHeight => 3.h;
  static double get accentLineHeightResponsive => 3.responsiveSp;
  static double get backButtonHeight => 35.h;
  static double get backButtonWidth => 45.w;
  static double get backButtonIconSize => 30.responsiveSp;
  static double get iconContainerHeight => 30.h;
  static double get iconContainerWidth => 30.w;
  static double get projectIconHeight => 30.h;
  static double get projectIconWidth => 30.w;
  static double get loaderSize => 75.responsiveSp;
  static double get profileImageSize => 75.responsiveSp;
  static double get noEntriesIconSize => 114.responsiveSp;
  static double get successAnimationIconSize => 150.responsiveSp;
  static double get successAnimationBarWidth => 4;
  static double get successAnimationBarHeight => 20;
  static double get wifiAnimationSize => 200.responsiveSp;
  static double get dialogMaxHeight => 500.h;
  
  /// Widths
  static double get sidebarWidth => 3.responsiveSp;
  static double get dividerWidth => 1.w;
  static double get borderWidth => 2;
  static double get borderWidthThin => 1.w;
  static double get gridLineWidth => 3.responsiveSp;
  
  /// Desktop gradient/clamp values
  static double get desktopDrawerWidthMin => 400.0;
  static double get desktopDrawerWidthMax => 550.0;
  static double get desktopDrawerWidthMultiplier => 2/3;
  static double get desktopProjectWidthMultiplier => 1/3;
  static double get desktopFontSizeDivisor => 30.0;
  static double get desktopDropdownWidthOffset => 30.0;
  static double get desktopDropdownPadding => 20.0;
  static double get desktopDropdownIconSpace => 30.0;
  
  // ==================== SPACING ====================
  
  /// Padding values
  static EdgeInsets get paddingZero => EdgeInsets.zero;
  static EdgeInsets get paddingSmall => EdgeInsets.all(8.w);
  static EdgeInsets get paddingMedium => EdgeInsets.all(16.w);
  static EdgeInsets get paddingLarge => EdgeInsets.all(24.w);
  
  /// Horizontal padding
  static double get paddingHorizontalSmall => 8.w;
  static double get paddingHorizontalMedium => 16.w;
  static double get paddingHorizontalLarge => 24.w;
  static double get paddingHorizontalExtraLarge => 35.w;
  
  /// Vertical padding
  static double get paddingVerticalSmall => 8.h;
  static double get paddingVerticalMedium => 16.h;
  static double get paddingVerticalLarge => 24.h;
  static double get paddingVerticalExtraLarge => 22.h;
  
  /// Symmetric padding
  static EdgeInsets get paddingSymmetricSmall => EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.h);
  static EdgeInsets get paddingSymmetricMedium => EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h);
  static EdgeInsets get paddingSymmetricLarge => EdgeInsets.symmetric(horizontal: 24.w, vertical: 24.h);
  static EdgeInsets get paddingSymmetricHorizontalSmall => EdgeInsets.symmetric(horizontal: 8.w);
  static EdgeInsets get paddingSymmetricHorizontalMedium => EdgeInsets.symmetric(horizontal: 16.w);
  static EdgeInsets get paddingSymmetricHorizontalLarge => EdgeInsets.symmetric(horizontal: 24.w);
  static EdgeInsets get paddingSymmetricVerticalSmall => EdgeInsets.symmetric(vertical: 8.h);
  static EdgeInsets get paddingSymmetricVerticalMedium => EdgeInsets.symmetric(vertical: 16.h);
  
  /// Specific padding combinations
  static EdgeInsets get paddingTextField => EdgeInsets.symmetric(vertical: 0.h);
  static EdgeInsets get paddingTextFieldLarger => EdgeInsets.symmetric(vertical: 22.h);
  static EdgeInsets get paddingTextFieldNormal => EdgeInsets.symmetric(vertical: 10.h);
  static EdgeInsets get paddingTextFieldHorizontal => EdgeInsets.symmetric(horizontal: 16.w);
  static EdgeInsets get paddingButtonHorizontal => EdgeInsets.symmetric(horizontal: 20.w);
  static EdgeInsets get paddingButtonVertical => EdgeInsets.symmetric(vertical: 2.h);
  static EdgeInsets get paddingButtonHorizontalSmall => EdgeInsets.symmetric(horizontal: 7.w);
  static EdgeInsets get paddingDropdownHorizontal => EdgeInsets.symmetric(horizontal: 8.w);
  static EdgeInsets get paddingDropdownVertical => EdgeInsets.symmetric(vertical: 8.h);
  static EdgeInsets get paddingDropdownItem => EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.h);
  static EdgeInsets get paddingDialogBottom => EdgeInsets.only(bottom: 24.h);
  static EdgeInsets get paddingDialogHorizontal => EdgeInsets.only(left: 24.w, right: 24.w);
  static EdgeInsets get paddingDialogTop => EdgeInsets.only(left: 35.w, right: 35.w, bottom: 22.h);
  static EdgeInsets get paddingProfileField => EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.h);
  static EdgeInsets get paddingProfileFieldHorizontal => EdgeInsets.symmetric(horizontal: 8.w);
  static EdgeInsets get paddingProfileFieldVertical => EdgeInsets.symmetric(vertical: 8.h);
  static EdgeInsets get paddingProfileFieldLeft => EdgeInsets.only(left: 8.w);
  static EdgeInsets get paddingProfileFieldRight => EdgeInsets.only(right: 8.w);
  static EdgeInsets get paddingProfileFieldBoth => EdgeInsets.only(left: 8.w, right: 8.w);
  static EdgeInsets get paddingProfileFieldTop => EdgeInsets.only(top: 8.h);
  static EdgeInsets get paddingChartHorizontal => EdgeInsets.only(left: 16.w, right: 16.w, top: 8.h, bottom: 8.h);
  static EdgeInsets get paddingFromLTRBZero => EdgeInsets.fromLTRB(0.w, 0.h, 0.w, 0.h);
  static EdgeInsets get paddingFromLTRBSmall => EdgeInsets.fromLTRB(16.w, 0.h, 0.w, 0.h);
  static EdgeInsets get paddingFromLTRBMedium => EdgeInsets.fromLTRB(24.w, 0.h, 0.w, 0.h);
  static EdgeInsets get paddingFromLTRBLarge => EdgeInsets.fromLTRB(35.w, 0.h, 0.w, 0.h);
  static EdgeInsets get paddingFromLTRBWithClamp => EdgeInsets.only(left: (16.w - 8).clamp(0.0, double.infinity));
  
  /// Margin/Spacing values
  static double get spacingXSmall => 4.w;
  static double get spacingSmall => 8.w;
  static double get spacingMedium => 12.w;
  static double get spacingLarge => 15.h;
  static double get spacingExtraLarge => 20.h;
  static double get spacingXXLarge => 24.h;
  static double get spacingXXXLarge => 40.h;
  static double get spacingHuge => 470.h;
  
  /// SizedBox spacing
  static SizedBox get spacingSizedBoxXSmall => SizedBox(width: 4.w);
  static SizedBox get spacingSizedBoxSmall => SizedBox(width: 8.w);
  static SizedBox get spacingSizedBoxMedium => SizedBox(width: 12.w);
  static SizedBox get spacingSizedBoxLarge => SizedBox(height: 15.h);
  static SizedBox get spacingSizedBoxExtraLarge => SizedBox(height: 20.h);
  static SizedBox get spacingSizedBoxXXLarge => SizedBox(height: 24.h);
  static SizedBox get spacingSizedBoxXXXLarge => SizedBox(height: 40.h);
  static SizedBox get spacingSizedBoxVerticalSmall => SizedBox(height: 8.h);
  static SizedBox get spacingSizedBoxVerticalMedium => SizedBox(height: 12.h);
  static SizedBox get spacingSizedBoxVerticalLarge => SizedBox(height: 16.h);
  static SizedBox get spacingSizedBoxVerticalExtraLarge => SizedBox(height: 20.h);
  
  // ==================== BORDER RADIUS ====================
  
  static double get borderRadiusSmall => 5.r;
  static double get borderRadiusMedium => 8.r;
  static double get borderRadiusLarge => 10.r;
  static BorderRadius get borderRadiusCircularSmall => BorderRadius.circular(5.r);
  static BorderRadius get borderRadiusCircularMedium => BorderRadius.circular(8.r);
  static BorderRadius get borderRadiusCircularLarge => BorderRadius.circular(10.r);
  static BorderRadius get borderRadiusAllSmall => BorderRadius.all(Radius.circular(5.r));
  static BorderRadius get borderRadiusAllMedium => BorderRadius.all(Radius.circular(8.r));
  static BorderRadius get borderRadiusAllLarge => BorderRadius.all(Radius.circular(10.r));
  static BorderRadius get borderRadiusTopLeft => BorderRadius.only(
    topLeft: Radius.circular(10.r),
    bottomLeft: Radius.circular(10.r),
  );
  
  // ==================== FONT SIZES ====================
  
  /// Base font sizes (from ThemeNotifier)
  static double get fontSizeExtraSmall => 14;
  static double get fontSizeSmall => 16;
  static double get fontSizeMedium => 18;
  static double get fontSizeLarge => 20;
  
  /// Responsive font sizes
  static double get fontSizeExtraSmallResponsive => 14.responsiveSp;
  static double get fontSizeSmallResponsive => 16.responsiveSp;
  static double get fontSizeMediumResponsive => 18.responsiveSp;
  static double get fontSizeLargeResponsive => 20.responsiveSp;
  
  /// Mobile-specific table font sizes (larger for better readability)
  static double get fontSizeTableMobile => PlatformUtils.isMobile ? 20.responsiveSp : 18.responsiveSp;
  static double get fontSizeTableHeaderMobile => PlatformUtils.isMobile ? 20.responsiveSp : 18.responsiveSp;
  
  /// Profile-specific font sizes (larger for better readability on mobile)
  static double get fontSizeProfileMobile => PlatformUtils.isMobile ? 20.responsiveSp : 18.responsiveSp;
  static double get fontSizeProfileToggleMobile => PlatformUtils.isMobile ? 12.responsiveSp : 11.5.responsiveSp;
  
  /// Desktop font size calculation
  static double getDesktopFontSize(double width) => width / desktopFontSizeDivisor;
  
  // ==================== ICON SIZES ====================
  
  static double get iconSizeXSmall => 16.69.h;
  static double get iconSizeSmall => 24.h;
  static double get iconSizeMedium => 25.responsiveSp;
  static double get iconSizeLarge => 30.responsiveSp;
  static double get iconSizeExtraLarge => 35.responsiveSp;
  static double get iconSizeDownload => 30.responsiveSp;
  static double get iconSizeArrow => 25.responsiveSp;
  static double get iconSizeDropdown => 30.responsiveSp;
  static double get iconSizeProject => 30.h;
  static double get iconSizeAdd => 24.h;
  static double get iconSizePrefix => 16.69.h;
  static double get iconSizePrefixWidth => 21.w;
  static double get iconSizeButtonArrow => 10; // Additional size for button arrow
  
  // ==================== TEXT STYLING ====================
  
  static double get letterSpacing => 0.5;
  static double get letterSpacingSp => 0.5.sp;
  static double get lineHeight => 1.2;
  static FontWeight get fontWeightNormal => FontWeight.normal;
  static FontWeight get fontWeightBold => FontWeight.bold;
  static FontWeight get fontWeightMedium => FontWeight.w500;
  
  // ==================== BORDER WIDTHS ====================
  
  static double get borderWidthDefault => 1.w;
  static double get borderWidthMedium => 2;
  static double get borderWidthThick => 3.responsiveSp;
  static double get borderWidthGradient => 2.responsiveSp;
  static double get borderWidthGrid => 3.responsiveSp;
  
  // ==================== SHADOW VALUES ====================
  
  static BoxShadow get shadowSmall => BoxShadow(
    color: Colors.black.withOpacity(0.25),
    spreadRadius: 0,
    blurRadius: 4,
    offset: const Offset(0, 4),
  );
  
  static BoxShadow getShadowMedium(BuildContext context) => BoxShadow(
    color: Provider.of<ThemeNotifier>(context).currentTheme.shadowColor,
    blurRadius: 1.r,
    offset: Offset(3.w, 4.h),
  );
  
  static double get shadowBlurRadius => 4;
  static double get shadowSpreadRadius => 0;
  static Offset get shadowOffset => const Offset(0, 4);
  static double get shadowOpacity => 0.25;
  
  // ==================== OPACITY VALUES ====================
  
  static double get opacityLow => 0.1;
  static double get opacityMedium => 0.25;
  static double get opacityHigh => 0.5;
  static double get opacityVeryHigh => 0.6;
  static double get opacityFull => 1.0;
  static double get opacityGradientStart => 0.6;
  static double get opacityBackdrop => 0.5;
  static double get opacityIcon => 0.8;
  
  // ==================== TEXT FIELD VALUES ====================
  
  static double get textFieldCursorHeight => 30.responsiveSp;
  static double get textFieldPrefixMinHeight => 16.69.h;
  static double get textFieldPrefixMinWidth => 21.w;
  static double get textFieldBorderRadius => 10.r;
  
  // Text field constraints
  static double get textFieldMinHeight => 40.h;
  static double get textFieldMaxHeight => 100.h;
  static double get textFieldMinWidth => 200.w;
  static double get textFieldMaxWidth => double.infinity;
  
  // ==================== BUTTON VALUES ====================
  
  static double get buttonChamferDivisor => 3;
  static double get buttonDefaultWidth => 112.w;
  static double get buttonSplashRadius => 20.responsiveSp;
  static double get buttonArrowSizeOffset => 10;
  static double get buttonHeightWithOffset => buttonHeight + 2.h;
  
  // ==================== DROPDOWN VALUES ====================
  
  static double get dropdownHeight => 50.91.h;
  static double get dropdownMaxHeight => 200.h;
  static double get dropdownDividerHeight => 0.5.h;
  static double get dropdownItemPadding => 39.5.h;
  static double get dropdownSpacing => 10.w;
  static double get dropdownPaddingLeft => 12.w;
  static double get dropdownPaddingRight => 8.w;
  static double get dropdownPaddingLeftSmall => 8.w;
  static double get dropdownPaddingLeftMedium => 15.w;
  
  // ==================== TABLE/GRID VALUES ====================
  
  static double get tableCellPaddingHorizontal => 4.w;
  static double get tableTextWidthPadding => 16;
  static double get tableTextWidthPaddingSmall => 6.responsiveSp;
  static double get tableBorderWidth => 3.responsiveSp;
  static double get tableHeaderPadding => 16;
  
  // ==================== CHART VALUES ====================
  
  static double get chartPaddingHorizontal => 16.w;
  static double get chartPaddingVertical => 8.h;
  static double get chartBorderRadius => 8.r;
  static double get chartBorderWidth => 2.responsiveSp;
  
  // ==================== PROFILE VALUES ====================
  
  static double get profileFieldBorderWidth => 3.responsiveSp;
  
  // ==================== DIALOG VALUES ====================
  
  static double get dialogBorderWidth => 3.responsiveSp;
  static double get dialogElevation => 0;
  static double get dialogOverlayElevation => 4;
  
  // ==================== BLUR VALUES ====================
  
  static double get blurSigmaX => 3;
  static double get blurSigmaY => 3;
  
  // ==================== CALCULATIONS ====================
  
  /// Calculate desktop drawer width with clamp
  static double getDesktopDrawerWidth(BuildContext context) {
    return (MediaQuery.of(context).size.width * desktopDrawerWidthMultiplier)
        .clamp(desktopDrawerWidthMin, desktopDrawerWidthMax);
  }
  
  /// Calculate desktop project width with clamp
  static double getDesktopProjectWidth(BuildContext context) {
    return (MediaQuery.of(context).size.width * desktopProjectWidthMultiplier)
        .clamp(desktopDrawerWidthMin, desktopDrawerWidthMax);
  }
  
  /// Calculate desktop font size based on width
  static double getDesktopFontSizeFromWidth(double width) {
    return width / desktopFontSizeDivisor;
  }
  
  /// Calculate desktop dropdown total width
  static double getDesktopDropdownTotalWidth(double width1, double width2) {
    return width1 + width2 + desktopDropdownIconSpace + desktopDropdownPadding;
  }
  
  /// Calculate button chamfer height
  static double getButtonChamferHeight() {
    return (buttonHeight) / buttonChamferDivisor;
  }
  
  // ==================== COLOR VALUES ====================
  
  /// Accent colors (from CommonColors)
  static Color get accentColorYellow => CommonColors.yellow;
  static Color get accentColorBlue => CommonColors.blue;
  static Color get accentColorRed => CommonColors.red;
  static Color get accentColorGreen => CommonColors.green;
  static Color get accentColorBlue2 => CommonColors.blue2;
  
  /// Special color values
  static Color get color14414e => const Color(0xFF14414e);
  static Color get colorTransparent => Colors.transparent;
  static Color get colorWhite => Colors.white;
  static Color get colorGrey => Colors.grey;
  static Color get colorBlack => Colors.black;
  
  // ==================== TEXT CALCULATION VALUES ====================
  
  static double get textWidthBasePadding => 16;
  static double get textWidthSmallPadding => 6.responsiveSp;
  static double get textWidthHeaderPadding => 16;
  
  // ==================== SCROLL VALUES ====================
  
  static double get scrollClampMin => 0.0;
  
  // ==================== DURATION VALUES ====================
  
  static Duration get transitionDurationZero => Duration.zero;
  static Duration get desktopInitDelay => const Duration(milliseconds: 100);
  
  // ==================== OTHER CONSTANTS ====================
  
  static double get sampleSizeLimit => 100;
  static double get maxDummyRows => 1000;
  static double get textWidthMultiplier => 2;
  static double get dropdownMaxItemsVisible => 4.6;
  static double get dropdownItemHeightForMax => 50.h;
  
  // ==================== RESPONSIVE HELPERS ====================
  
  /// Get responsive font size based on platform
  static double getResponsiveFontSize(BuildContext context, double? customFontSize, {double? desktopWidth}) {
    if (PlatformUtils.isMobile) {
      return (customFontSize ?? fontSizeMedium).responsiveSp;
    } else {
      final width = desktopWidth ?? getDesktopDrawerWidth(context);
      return customFontSize ?? getDesktopFontSizeFromWidth(width);
    }
  }
  
  /// Get responsive icon size
  static double getResponsiveIconSize(double mobileSize, {double? desktopSize}) {
    if (PlatformUtils.isMobile) {
      return mobileSize;
    } else {
      return desktopSize ?? mobileSize;
    }
  }
}

