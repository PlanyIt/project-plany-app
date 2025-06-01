import 'package:flutter/material.dart';

class ResponsiveLayout {
  static bool isSmallScreen(BuildContext context) {
    return MediaQuery.of(context).size.width < 768;
  }

  static bool isMediumScreen(BuildContext context) {
    return MediaQuery.of(context).size.width >= 768 &&
        MediaQuery.of(context).size.width < 1200;
  }

  static bool isLargeScreen(BuildContext context) {
    return MediaQuery.of(context).size.width >= 1200;
  }

  static Widget buildResponsiveLayout({
    required BuildContext context,
    required Widget smallScreen,
    required Widget mediumScreen,
    required Widget largeScreen,
  }) {
    if (isLargeScreen(context)) {
      return largeScreen;
    } else if (isMediumScreen(context)) {
      return mediumScreen;
    } else {
      return smallScreen;
    }
  }
}
