import 'package:flutter/material.dart';

class ResponsiveHelper {
  static bool isTablet(BuildContext context) {
    return MediaQuery.of(context).size.width > 600;
  }
  
  static bool isLandscape(BuildContext context) {
    return MediaQuery.of(context).orientation == Orientation.landscape;
  }
  
  static double getResponsiveWidth(BuildContext context, {
    double mobileWidth = 1.0,
    double tabletWidth = 0.8,
  }) {
    return isTablet(context) 
        ? tabletWidth * MediaQuery.of(context).size.width
        : mobileWidth * MediaQuery.of(context).size.width;
  }
  
  static double getResponsiveFontSize(BuildContext context, double baseFontSize, double scale) {
    final multiplier = isTablet(context) ? 1.2 : 1.0;
    return baseFontSize * multiplier * scale;
  }
  
  static EdgeInsets getResponsivePadding(BuildContext context, double scale) {
    final basePadding = isTablet(context) ? 24.0 : 16.0;
    return EdgeInsets.all(basePadding * scale);
  }
  
  static double getResponsiveIconSize(BuildContext context, double baseSize, double scale) {
    final multiplier = isTablet(context) ? 1.3 : 1.0;
    return baseSize * multiplier * scale;
  }
  
  static int getGridCrossAxisCount(BuildContext context) {
    if (isTablet(context)) {
      return isLandscape(context) ? 4 : 3;
    } else {
      return isLandscape(context) ? 3 : 2;
    }
  }
  
  static double getButtonHeight(BuildContext context, double scale) {
    final baseHeight = isTablet(context) ? 64.0 : 56.0;
    return baseHeight * scale;
  }
  
  static double getButtonWidth(BuildContext context, double scale) {
    final baseWidth = isTablet(context) ? 100.0 : 80.0;
    return baseWidth * scale;
  }
  
  static BorderRadius getResponsiveBorderRadius(BuildContext context, double scale) {
    final baseRadius = isTablet(context) ? 16.0 : 12.0;
    return BorderRadius.circular(baseRadius * scale);
  }
}
