import 'package:flutter/material.dart';
import 'dart:math';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:watermeter2/utils/pok.dart';
import 'package:watermeter2/services/platform_utils.dart';
import 'package:watermeter2/constants/theme2.dart';



class UIConfig {
  
  UIConfig._();

  

  
  static double get rowHeight => 41.h;
  static double get tableRowHeight => 41.h;
  static double get headerBarHeight => 41.h;
  static double get sectionBarHeight => 41.h;
  static double get dropdownRowHeight => 50.91.h;
  static double get dropdownItemHeight => 40.h;
  static double get buttonHeight => 48.h;
  static double get bottomNavBarHeight => 69.h;

  
  static double get headerWidgetHeight =>
      46.h; 
  static EdgeInsets get headerWidgetPadding => EdgeInsets.symmetric(
      vertical: spacingSmall.h, horizontal: spacingMedium.w);
  static double get headerWidgetBorderWidth => spacingMedium.responsiveSp;

  
  static double get headerSectionHeight =>
      46.h; 

  
  static double get accentLineHeight => 3.responsiveSp;
  static double get accentLineHeightResponsive => 3.responsiveSp;
  static double get backButtonHeight => 30.h;
  static double get backButtonWidth => 35.w;
  static double get backButtonIconSize => 25.responsiveSp;
  static double get iconContainerHeight => 30.h;
  static double get iconContainerWidth => 30.w;
  static double get projectIconHeight => 30.h;
  static double get projectIconWidth => 30.w;
  static double get appBarHeight => 50.h;
  static double get loaderSize => 75.responsiveSp;
  static double get profileImageSize => 75.responsiveSp;
  static double get noEntriesIconSize => 114.responsiveSp;
  static double get successAnimationIconSize => 150.responsiveSp;
  static double get successAnimationBarWidth => 4;
  static double get successAnimationBarHeight => 20;
  static double get wifiAnimationSize => 200.responsiveSp;
  static double get dialogMaxHeight => 500.h;

  
  static double get sidebarWidth => 3.3.responsiveSp;
  static double get dividerWidth => 1.w;
  static double get borderWidth => 2;
  static double get borderWidthThin => 1.w;
  static double get gridLineWidth => 3.responsiveSp;

  
  static double get desktopDrawerWidthMin => 400.0;
  static double get desktopDrawerWidthMax => 550.0;
  static double get desktopDrawerWidthMultiplier => 2 / 3;
  static double get desktopProjectWidthMultiplier => 1 / 3;
  static double get desktopFontSizeDivisor => 30.0;
  static double get desktopDropdownWidthOffset => 30.0;
  static double get desktopDropdownPadding => 20.0;
  static double get desktopDropdownIconSpace => 30.0;

  

  
  static EdgeInsets get paddingZero => EdgeInsets.zero;
  static EdgeInsets get paddingSmall => EdgeInsets.all(8.w);
  static EdgeInsets get paddingMedium => EdgeInsets.all(16.w);
  static EdgeInsets get paddingLarge => EdgeInsets.all(24.w);

  
  static double get paddingHorizontalSmall => 8.w;
  static double get paddingHorizontalMedium => 16.w;
  static double get paddingHorizontalLarge => 24.w;
  static double get paddingHorizontalExtraLarge => 35.w;

  
  static double get paddingVerticalSmall => 8.h;
  static double get paddingVerticalMedium => 16.h;
  static double get paddingVerticalLarge => 24.h;
  static double get paddingVerticalExtraLarge => 22.h;

  
  static EdgeInsets get paddingSymmetricSmall =>
      EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.h);
  static EdgeInsets get paddingSymmetricMedium =>
      EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h);
  static EdgeInsets get paddingSymmetricLarge =>
      EdgeInsets.symmetric(horizontal: 24.w, vertical: 24.h);
  static EdgeInsets get paddingSymmetricHorizontalSmall =>
      EdgeInsets.symmetric(horizontal: 8.w);
  static EdgeInsets get paddingSymmetricHorizontalMedium =>
      EdgeInsets.symmetric(horizontal: 16.w);
  static EdgeInsets get paddingSymmetricHorizontalLarge =>
      EdgeInsets.symmetric(horizontal: 24.w);
  static EdgeInsets get paddingSymmetricVerticalSmall =>
      EdgeInsets.symmetric(vertical: 8.h);
  static EdgeInsets get paddingSymmetricVerticalMedium =>
      EdgeInsets.symmetric(vertical: 16.h);

  
  static EdgeInsets get paddingTextField => EdgeInsets.symmetric(vertical: 0.h);
  static EdgeInsets get paddingTextFieldLarger =>
      EdgeInsets.symmetric(vertical: 22.h);
  static EdgeInsets get paddingTextFieldNormal =>
      EdgeInsets.symmetric(vertical: 10.h);
  static EdgeInsets get paddingTextFieldHorizontal =>
      EdgeInsets.symmetric(horizontal: 16.w);
  static EdgeInsets get paddingButtonHorizontal =>
      EdgeInsets.symmetric(horizontal: 15.w);
  static EdgeInsets get paddingButtonVertical =>
      EdgeInsets.symmetric(vertical: 2.h);
  static EdgeInsets get paddingButtonHorizontalSmall =>
      EdgeInsets.symmetric(horizontal: 7.w);
  static EdgeInsets get paddingDropdownHorizontal =>
      EdgeInsets.symmetric(horizontal: 8.w);
  static EdgeInsets get paddingDropdownVertical =>
      EdgeInsets.symmetric(vertical: 8.h);
  static EdgeInsets get paddingDropdownItem =>
      EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.h);
  static EdgeInsets get paddingDialogBottom => EdgeInsets.only(bottom: 24.h);
  static EdgeInsets get paddingDialogHorizontal =>
      EdgeInsets.only(left: 24.w, right: 24.w);
  static EdgeInsets get paddingDialogTop =>
      EdgeInsets.only(left: 35.w, right: 35.w, bottom: 22.h);
  static EdgeInsets get paddingProfileField =>
      EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h);
  static EdgeInsets get paddingProfileFieldHorizontal =>
      EdgeInsets.symmetric(horizontal: 8.w);
  static EdgeInsets get paddingProfileFieldVertical =>
      EdgeInsets.symmetric(vertical: 8.h);
  static EdgeInsets get paddingProfileFieldLeft => EdgeInsets.only(left: 8.w);
  static EdgeInsets get paddingProfileFieldRight => EdgeInsets.only(right: 8.w);
  static EdgeInsets get paddingProfileFieldBoth =>
      EdgeInsets.only(left: 8.w, right: 8.w);
  static EdgeInsets get paddingProfileFieldTop => EdgeInsets.only(top: 8.h);
  static EdgeInsets get paddingChartHorizontal =>
      EdgeInsets.only(left: 16.w, right: 16.w);
  static EdgeInsets get paddingFromLTRBZero =>
      EdgeInsets.fromLTRB(0.w, 0.h, 0.w, 0.h);
  static EdgeInsets get paddingFromLTRBSmall =>
      EdgeInsets.fromLTRB(16.w, 0.h, 0.w, 0.h);
  static EdgeInsets get paddingFromLTRBMedium =>
      EdgeInsets.fromLTRB(24.w, 0.h, 0.w, 0.h);
  static EdgeInsets get paddingFromLTRBLarge =>
      EdgeInsets.fromLTRB(35.w, 0.h, 0.w, 0.h);
  static EdgeInsets get paddingFromLTRBWithClamp =>
      EdgeInsets.only(left: max(0.0, 16.w - 8));

  
  static double get spacingXSmall => 4.w;
  static double get spacingSmall => 8.w;
  static double get spacingMedium => 12.w;
  static double get spacingLarge => 15.h;
  static double get spacingExtraLarge => 20.w;
  static double get spacingXXLarge => 24.h;
  static double get spacingXXXLarge => 40.h;
  static double get spacingHuge => 470.h;
  static double get spacingAppBarLogo => 10.w;
  static double get spacingLoginTitle => 10.h;
  static double get spacingForgotPasswordTop => 25.h;
  static double get spacingForgotPasswordVertical => 5.h;

  
  static SizedBox get spacingSizedBoxXSmall => SizedBox(width: 4.w);
  static SizedBox get spacingSizedBoxSmall => SizedBox(width: 8.w);
  static SizedBox get spacingSizedBoxMedium => SizedBox(width: 12.w);
  static SizedBox get spacingSizedBoxLarge => SizedBox(width: 15.w);
  static SizedBox get spacingSizedBoxExtraLarge => SizedBox(height: 20.h);
  static SizedBox get spacingSizedBoxXXLarge => SizedBox(height: 24.h);
  static SizedBox get spacingSizedBoxXXXLarge => SizedBox(height: 40.h);
  static SizedBox get spacingSizedBoxVerticalSmall => SizedBox(height: 8.h);
  static SizedBox get spacingSizedBoxVerticalMedium => SizedBox(height: 12.h);
  static SizedBox get spacingSizedBoxVerticalLarge => SizedBox(height: 8.h);
  static SizedBox get spacingSizedBoxVerticalExtraLarge =>
      SizedBox(height: 20.h);

  

  static double get borderRadiusSmall => 5.r;
  static double get borderRadiusMedium => 8.r;
  static double get borderRadiusLarge => 10.r;
  static BorderRadius get borderRadiusCircularSmall =>
      BorderRadius.circular(5.r);
  static BorderRadius get borderRadiusCircularMedium =>
      BorderRadius.circular(8.r);
  static BorderRadius get borderRadiusCircularLarge =>
      BorderRadius.circular(10.r);
  static BorderRadius get borderRadiusAllSmall =>
      BorderRadius.all(Radius.circular(5.r));
  static BorderRadius get borderRadiusAllMedium =>
      BorderRadius.all(Radius.circular(8.r));
  static BorderRadius get borderRadiusAllLarge =>
      BorderRadius.all(Radius.circular(10.r));
  static BorderRadius get borderRadiusTopLeft => BorderRadius.only(
        topLeft: Radius.circular(10.r),
        bottomLeft: Radius.circular(10.r),
      );
  static BorderRadius get borderRadiusAppBarIcon => BorderRadius.circular(50.r);

  

  
  static double get fontSizeExtraSmall => 14;
  static double get fontSizeSmall => 16;
  static double get fontSizeMedium => 18;
  static double get fontSizeLarge => 20;
  static double get fontSizeExtraLarge => 24;

  
  static double get fontSizeExtraSmallResponsive => 14.responsiveSp;
  static double get fontSizeSmallResponsive => 16.responsiveSp;
  static double get fontSizeMediumResponsive => 18.responsiveSp;
  static double get fontSizeLargeResponsive => 20.responsiveSp;
  static double get fontSizeExtraLargeResponsive => 24.responsiveSp;

  
  static double get fontSizeTableMobile =>
      PlatformUtils.isMobile ? 20.responsiveSp : 18.responsiveSp;
  static double get fontSizeTableHeaderMobile =>
      PlatformUtils.isMobile ? 20.responsiveSp : 18.responsiveSp;

  
  static double get fontSizeProfileMobile =>
      PlatformUtils.isMobile ? 20.responsiveSp : 18.responsiveSp;
  static double get fontSizeProfileToggleMobile =>
      PlatformUtils.isMobile ? 12.responsiveSp : 11.5.responsiveSp;

  
  static double getDesktopFontSize(double width) =>
      width / desktopFontSizeDivisor;

  

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
  static double get iconSizeButtonArrow =>
      10; 
  static double get iconSizeAppBarLogo => 30.responsiveSp;
  static double get iconSizeAppBarIcon => 28.responsiveSp;
  static double get appBarLogoDesktopMinSize => 25.responsiveSp;
  static double get appBarLogoDesktopMaxSize => 26.responsiveSp;
  static double get appBarIconDesktopMinSize => 24.responsiveSp;
  static double get appBarIconDesktopMaxSize => 28.responsiveSp;
  static double get appBarTitleDesktopMinSize => 18.0;
  static double get appBarTitleDesktopMaxSize => 30.0;
  static double get appBarDesktopWidthMin => 400.0;
  static double get appBarDesktopWidthMax => 550.0;

  

  static double get letterSpacing => 0.5;
  static double get letterSpacingSp => 0.5.sp;
  static double get lineHeight => 1.2;
  static FontWeight get fontWeightNormal => FontWeight.normal;
  static FontWeight get fontWeightBold => FontWeight.bold;
  static FontWeight get fontWeightMedium => FontWeight.w500;

  

  static double get borderWidthDefault => 1.w;
  static double get borderWidthMedium => 2;
  static double get borderWidthThick => 3.responsiveSp;
  static double get borderWidthGradient => 2.responsiveSp;
  static double get borderWidthGrid => 3.responsiveSp;

  

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

  

  static double get opacityLow => 0.1;
  static double get opacityMedium => 0.25;
  static double get opacityHigh => 0.5;
  static double get opacityVeryHigh => 0.6;
  static double get opacityFull => 1.0;
  static double get opacityGradientStart => 0.6;
  static double get opacityBackdrop => 0.5;
  static double get opacityIcon => 0.8;

  

  static double get textFieldCursorHeight => 30.responsiveSp;
  static double get textFieldPrefixMinHeight => 16.69.h;
  static double get textFieldPrefixMinWidth => 21.w;
  static double get textFieldBorderRadius => 10.r;
  static double get textFieldHeightScale => 0.25;
  static final double _textFieldMinHeightMobile = 30.0;
  static final double _textFieldMaxHeightMobile = 60.0;
  static final double _textFieldMinHeightDesktop = 50.0;
  static final double _textFieldMaxHeightDesktop = 90.0;

  
  static double get textFieldMinHeight => PlatformUtils.isMobile
      ? _textFieldMinHeightMobile
      : _textFieldMinHeightDesktop;
  static double get textFieldMaxHeight => PlatformUtils.isMobile
      ? _textFieldMaxHeightMobile
      : _textFieldMaxHeightDesktop;
  static double get textFieldMinWidth => 200.w;
  static double get textFieldMaxWidth => double.infinity;
  static double get desktopDrawerHeightMin => 40.h;
  static double get desktopDrawerHeightMax => 100.h;
  static double get desktopDrawerHeightScale => 0.5;
  static double getDesktopDrawerHeight(BuildContext context) {
    return (MediaQuery.of(context).size.height * desktopDrawerHeightScale);
  }

  
  static double getResponsiveTextFieldHeight(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final baseDimension =
        PlatformUtils.isMobile ? size.height : getDesktopDrawerHeight(context);
    final scaledHeight = baseDimension * textFieldHeightScale;
    return scaledHeight * 0.85;
  }

  

  static double get buttonChamferDivisor => 3;
  static double get buttonDefaultWidth => 112.w;
  static double get buttonSplashRadius => 20.responsiveSp;
  static double get buttonArrowSizeOffset => 10;
  static double get buttonHeightWithOffset => buttonHeight + 2.h;
  static double get buttonWidthForgotPassword => 130.w;

  

  static double get dropdownHeight => 50.91.h;
  static double get dropdownMaxHeight => 200.h;
  static double get dropdownDividerHeight => 0.5.h;
  static double get dropdownItemPadding => 39.5.h;
  static double get dropdownSpacing => 10.w;
  static double get dropdownPaddingLeft => 12.w;
  static double get dropdownPaddingRight => 8.w;
  static double get dropdownPaddingLeftSmall => 8.w;
  static double get dropdownPaddingLeftMedium => 15.w;
  static double get dropdownCountryPickerHeight => 30.78.h;

  
  static double get dropdownLabelPaddingLeft => 10.0;
  static double get dropdownLabelPaddingRight =>
      0.0; 
  static double get dropdownLabelTextPaddingLeft => 8.0;
  static double get dropdownLabelBuffer => 5.0;
  static double get dropdownLabelTotalPadding =>
      dropdownLabelPaddingLeft +
      dropdownLabelPaddingRight +
      dropdownLabelTextPaddingLeft +
      dropdownLabelBuffer;

  
  static double get dropdownMobileWidthOffset => 187.0;
  static double get dropdownMobileWidthMultiplier => 5.0;
  static double get dropdownMobileWidthMultiplierIncreased =>
      15.5; 

  
  static double get buttonWidthExtraPadding => 8.w;

  

  static double get tableCellPaddingHorizontal => 6.w;
  static double get tableTextWidthPadding => 16;
  static double get tableTextWidthPaddingSmall => 6.responsiveSp;
  static double get tableBorderWidth => 2.responsiveSp;
  static double get tableHeaderPadding => 16;

  

  static double get chartPaddingHorizontal => 16.w;
  static double get chartPaddingVertical => 8.h;
  static double get chartBorderRadius => 8.r;
  static double get chartBorderWidth => 2.responsiveSp;

  

  static double get profileFieldBorderWidth => 3.responsiveSp;

  

  static double get dialogBorderWidth => 3.responsiveSp;
  static double get dialogElevation => 0;
  static double get dialogOverlayElevation => 4;
  static double get dialogWidthAutoLogin => 350.w;

  

  static double get blurSigmaX => 3;
  static double get blurSigmaY => 3;

  

  
  static double getDesktopDrawerWidth(BuildContext context) {
    return (MediaQuery.of(context).size.width * desktopDrawerWidthMultiplier);
  }

  
  static double getDesktopProjectWidth(BuildContext context) {
    return (MediaQuery.of(context).size.width * desktopProjectWidthMultiplier);
  }

  
  static double getResponsiveOneThirdWidth(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (PlatformUtils.isMobile) {
      return width;
    }
    return (width * desktopProjectWidthMultiplier);
  }

  static double _scaleValueForAppBar(
      double baseWidth, double minValue, double maxValue) {
    final normalized = ((baseWidth - desktopDrawerWidthMin) /
        (desktopDrawerWidthMax - desktopDrawerWidthMin));
    return max(0.0, minValue + (maxValue - minValue) * normalized);
  }

  static double getResponsiveAppBarLogoSize(BuildContext context) {
    if (PlatformUtils.isMobile) {
      return iconSizeAppBarLogo;
    }
    final baseWidth = getResponsiveOneThirdWidth(context);
    final scaled = _scaleValueForAppBar(
      baseWidth,
      appBarLogoDesktopMinSize,
      appBarLogoDesktopMaxSize,
    );
    return scaled;
  }

  static double getResponsiveAppBarIconSize(BuildContext context) {
    if (PlatformUtils.isMobile) {
      return iconSizeAppBarIcon;
    }
    final baseWidth = getResponsiveOneThirdWidth(context);
    final scaled = _scaleValueForAppBar(
      baseWidth,
      appBarIconDesktopMinSize,
      appBarIconDesktopMaxSize,
    );
    return scaled;
  }

  static double getResponsiveAppBarTitleSize(
      BuildContext context, double baseFontSize) {
    if (PlatformUtils.isMobile) {
      return baseFontSize.responsiveSp;
    }
    final width = getResponsiveOneThirdWidth(context);
    final scaledFont = getDesktopFontSizeFromWidth(width, divider: 20);
    return scaledFont;
  }

  
  
  
  static double getDesktopDialogWidth(BuildContext context) {
    if (PlatformUtils.isMobile) {
      return 350.w;
    } else {
      return (MediaQuery.of(context).size.width * (1 / 3));
    }
  }

  
  static double getDesktopFontSizeFromWidth(double width,
      {double divider = 30.0}) {
    return width / divider;
  }

  
  static double getDesktopDropdownTotalWidth(double width1, double width2) {
    return width1 + width2 + desktopDropdownIconSpace + desktopDropdownPadding;
  }

  
  static double getButtonChamferHeight() {
    return (buttonHeight) / buttonChamferDivisor;
  }

  

  
  static Color get accentColorYellow => CommonColors.yellow;
  static Color get accentColorBlue => CommonColors.blue;
  static Color get accentColorRed => CommonColors.red;
  static Color get accentColorGreen => CommonColors.green;
  static Color get accentColorBlue2 => CommonColors.blue2;

  
  static Color get color14414e => const Color(0xFF14414e);
  static Color get colorTransparent => Colors.transparent;
  static Color get colorWhite => Colors.white;
  static Color get colorGrey => Colors.grey;
  static Color get colorBlack => Colors.black;

  

  static double get textWidthBasePadding => 16;
  static double get textWidthSmallPadding => 6.responsiveSp;
  static double get textWidthHeaderPadding => 16;

  

  static double get scrollClampMin => 0.0;

  

  static Duration get transitionDurationZero => Duration.zero;
  static Duration get desktopInitDelay => const Duration(milliseconds: 100);

  

  static double get sampleSizeLimit => 100;
  static double get maxDummyRows => 1000;
  static double get textWidthMultiplier => 2;
  static double get dropdownMaxItemsVisible => 4.6;
  static double get dropdownItemHeightForMax => 50.h;

  

  
  static double getResponsiveFontSize(
      BuildContext context, double? customFontSize,
      {double? desktopWidth}) {
    if (PlatformUtils.isMobile) {
      return (customFontSize ?? fontSizeMedium).responsiveSp;
    } else {
      final width = desktopWidth ?? getDesktopDrawerWidth(context);
      return customFontSize ?? getDesktopFontSizeFromWidth(width);
    }
  }

  
  static double getResponsiveIconSize(double mobileSize,
      {double? desktopSize}) {
    if (PlatformUtils.isMobile) {
      return mobileSize;
    } else {
      return desktopSize ?? mobileSize;
    }
  }

  
  static double getResponsiveWidth(BuildContext context,
      {required double scaleFactor, double? desktopWidth}) {
    if (PlatformUtils.isMobile) {
      return MediaQuery.of(context).size.width * scaleFactor;
    } else {
      final baseWidth = desktopWidth ??
          (MediaQuery.of(context).size.width * desktopProjectWidthMultiplier);
      return baseWidth * scaleFactor;
    }
  }
}
