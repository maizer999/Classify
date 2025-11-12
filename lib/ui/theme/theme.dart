import 'package:eClassify/utils/ui_utils.dart';
import 'package:flutter/material.dart';

///Light Theme Colors
///This color format is different, isn't it? .You can use hex colors here also but you have to remove '#' symbol and add 0xff instead.
const Color primaryColor_ = Color(0xFFF6F5FA);
const Color secondaryColor_ = Color(0xFFFFFFFF);
const Color territoryColor_ = Color(0xFF00B2CA);
const Color forthColor_ = Color(0xffFA6E53);
const Color _backgroundColor = primaryColor_; //here you can change if you need
const Color textDarkColor = Color(0xFF000000);
Color lightTextColor = const Color(0xFF000000).withValues(alpha: 0.5);
Color widgetsBorderColorLight = const Color(0xffEEEEEE).withValues(alpha: 0.6);

///Dark Theme Colors
Color primaryColorDark = const Color(0xff121212);
Color secondaryColorDark = const Color(0xff1C1C1C);
const Color territoryColorDark = Color(0xff00B2CA);
Color deactivateColorLight = const Color(0xff7F7F7F);

const Color forthColorDark = Color(0xffFA6E53);
Color backgroundColorDark = primaryColorDark; //here you can change if you need
const Color textColorDarkTheme = Color(0xffFDFDFD);
Color lightTextColorDarkTheme = const Color(0xffFDFDFD).withValues(alpha: 0.3);
Color widgetsBorderColorDark = const Color(0x1aFDFDFD);

Color orangeColor = Colors.orange;

///Messages Color
const Color errorMessageColor = Color.fromARGB(255, 166, 4, 4);
const Color successMessageColor = Color(0xff00B2CA);
const Color warningMessageColor = Color(0xFFC2AF6F);

//status button color
const Color pendingButtonColor = Color(0xff0C5D9C);
const Color soldOutButtonColor = Color(0xffFFBB33);
const Color deactivateButtonColor = Color(0xffFE0000);
const Color activateButtonColor = Color(0xFF02AD11);

//Button text color
const Color buttonTextColor = Colors.white;

/// Modern Orange & Red Colors
const Color modernOrangeLight = Color(0xFFFFA726);
const Color modernOrangeDark = Color(0xFFFF7043);

const Color modernRedLight = Color(0xFFEF5350);
const Color modernRedDark = Color(0xFFD32F2F);

const Color modernOrangeAccent = Color(0xFFFFCC80);
const Color modernRedAccent = Color(0xFFFF8A80);

///Advance
//Theme settings
extension ColorPrefs on ColorScheme {
  Color get primaryColor => _getColor(
    brightness,
    lightColor: primaryColor_,
    darkColor: primaryColorDark,
  );

  Color get secondaryColor => _getColor(
    brightness,
    lightColor: secondaryColor_,
    darkColor: secondaryColorDark,
  );

  Color get secondaryDetailsColor => _getColor(
    brightness,
    lightColor: secondaryColor_,
    darkColor: primaryColorDark,
  );

  Color get territoryColor => _getColor(
    brightness,
    lightColor: forthColor_,
    darkColor: forthColorDark,
  );

  Color get deactivateColor => _getColor(
    brightness,
    lightColor: deactivateColorLight,
    darkColor: deactivateColorLight,
  );

  Color get forthColor =>
      _getColor(brightness, lightColor: forthColor_, darkColor: forthColorDark);

  Color get backgroundColor => _getColor(
    brightness,
    lightColor: _backgroundColor,
    darkColor: backgroundColorDark,
  );

  Color get buttonColor => buttonTextColor;

  Color get textColorDark => _getColor(
    brightness,
    lightColor: textDarkColor,
    darkColor: textColorDarkTheme,
  );

  Color get textDefaultColor => _getColor(
    brightness,
    lightColor: textDarkColor,
    darkColor: textColorDarkTheme,
  );

  Color get textLightColor => _getColor(
    brightness,
    lightColor: lightTextColor,
    darkColor: lightTextColorDarkTheme,
  );

  Color get borderColor => _getColor(
    brightness,
    lightColor: widgetsBorderColorLight,
    darkColor: secondaryColorDark.withValues(alpha: 0.2),
  );

  Color get inverseThemeColor => _getColor(
    brightness,
    lightColor: secondaryColorDark,
    darkColor: secondaryColor_,
  );

  Color textAutoAdapt(Color backgroundColor) =>
      UiUtils.getAdaptiveTextColor(backgroundColor);

  Color get blackColor => Colors.black;

  Color get shimmerBaseColor => brightness == Brightness.light
      ? const Color.fromARGB(255, 225, 225, 225)
      : const Color.fromARGB(255, 150, 150, 150);

  Color get shimmerHighlightColor => brightness == Brightness.light
      ? Colors.grey.shade100
      : Colors.grey.shade300;

  Color get shimmerContentColor => brightness == Brightness.light
      ? Colors.white.withValues(alpha: 0.85)
      : Colors.white.withValues(alpha: 0.7);

  /// Modern Colors
  Color get modernOrange =>
      _getColor(brightness, lightColor: modernOrangeLight, darkColor: modernOrangeDark);

  Color get modernRed =>
      _getColor(brightness, lightColor: modernRedLight, darkColor: modernRedDark);

  Color get modernOrangeAccent =>
      _getColor(brightness, lightColor: modernOrangeAccent, darkColor: modernOrangeDark);

  Color get modernRedAccent =>
      _getColor(brightness, lightColor: modernRedAccent, darkColor: modernRedDark);
}

// 10pt: Smaller
// 12pt: Small
// 16pt: Large
// 18pt: Larger
// 24pt: Extra large
extension TextThemeForFont on TextTheme {
  Font get font => Font();
}

/// i made this to access font easily from theme like, Theme.of(context).textTheme.font.small
class Font {
  ///10
  double get smaller => 10;

  ///12
  double get small => 12;

  ///14
  double get normal => 14;

  ///16
  double get large => 16;

  ///18
  double get larger => 18;

  ///24
  double get extraLarge => 24;

  ///28
  double get xxLarge => 28;
}

Color _getColor(
    Brightness brightness, {
      required Color lightColor,
      required Color darkColor,
    }) {
  if (Brightness.light == brightness) {
    return lightColor;
  } else {
    return darkColor;
  }
}
