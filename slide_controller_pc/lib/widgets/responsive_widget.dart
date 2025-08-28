import 'package:flutter/material.dart';

class ResponsiveBreakpoints {
  static const double mobile = 768;
  static const double tablet = 1024;
  static const double desktop = 1200;
}

class ResponsiveWidget extends StatelessWidget {
  final Widget mobile;
  final Widget? tablet;
  final Widget desktop;

  const ResponsiveWidget({
    super.key,
    required this.mobile,
    this.tablet,
    required this.desktop,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= ResponsiveBreakpoints.desktop) {
          return desktop;
        } else if (constraints.maxWidth >= ResponsiveBreakpoints.tablet) {
          return tablet ?? desktop;
        } else {
          return mobile;
        }
      },
    );
  }
}

class ResponsiveHelper {
  static bool isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width < ResponsiveBreakpoints.mobile;
  }

  static bool isTablet(BuildContext context) {
    return MediaQuery.of(context).size.width >= ResponsiveBreakpoints.mobile &&
           MediaQuery.of(context).size.width < ResponsiveBreakpoints.desktop;
  }

  static bool isDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= ResponsiveBreakpoints.desktop;
  }

  static double getResponsivePadding(BuildContext context) {
    if (isMobile(context)) {
      return 16.0;
    } else if (isTablet(context)) {
      return 24.0;
    } else {
      return 32.0;
    }
  }

  static double getMaxWidth(BuildContext context) {
    if (isMobile(context)) {
      return double.infinity;
    } else if (isTablet(context)) {
      return 900.0;
    } else {
      return 1200.0;
    }
  }

  static int getGridCrossAxisCount(BuildContext context) {
    if (isMobile(context)) {
      return 1;
    } else if (isTablet(context)) {
      return 2;
    } else {
      return 3;
    }
  }

  static double getCardAspectRatio(BuildContext context) {
    if (isMobile(context)) {
      return 1.2;
    } else if (isTablet(context)) {
      return 1.4;
    } else {
      return 1.6;
    }
  }
}
