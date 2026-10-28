import 'package:flutter/material.dart';

/// Fixed spacing constants (same on every screen size).
class AppDimensions {
  AppDimensions._();

  static const double paddingXS = 4;
  static const double paddingS = 8;
  static const double paddingM = 16;
  static const double paddingL = 24;
  static const double paddingXL = 32;

  static const double radiusM = 12;
  static const double radiusL = 20;
}

/// Centralized Responsiveness utility class accessible across the entire application.
class Responsive extends StatelessWidget {
  final Widget mobile;
  final Widget? tablet;
  final Widget? desktop;

  const Responsive({
    super.key,
    required this.mobile,
    this.tablet,
    this.desktop,
  });

  // Breakpoints
  static const double mobileMax = 600;
  static const double tabletMax = 1100;
  static const double narrowMobileMax = 360;

  // Screen device type checks
  static bool isNarrowMobile(BuildContext context) =>
      MediaQuery.sizeOf(context).width < narrowMobileMax;

  static bool isMobile(BuildContext context) =>
      MediaQuery.sizeOf(context).width < mobileMax;

  static bool isTablet(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    return width >= mobileMax && width < tabletMax;
  }

  static bool isDesktop(BuildContext context) =>
      MediaQuery.sizeOf(context).width >= tabletMax;

  // Screen dimensions
  static double widthOf(BuildContext context) =>
      MediaQuery.sizeOf(context).width;

  static double heightOf(BuildContext context) =>
      MediaQuery.sizeOf(context).height;

  // Generic responsive value selector
  static T value<T>(
      BuildContext context, {
        required T mobile,
        T? tablet,
        T? desktop,
      }) {
    final width = MediaQuery.sizeOf(context).width;
    if (width >= tabletMax && desktop != null) return desktop;
    if (width >= mobileMax && tablet != null) return tablet;
    return mobile;
  }

  // Scaling helpers
  static double scaleFont(BuildContext context, double baseFontSize) {
    final width = MediaQuery.sizeOf(context).width;
    if (width < narrowMobileMax) return baseFontSize * 0.86;
    if (width >= tabletMax) return baseFontSize * 1.25;
    if (width >= mobileMax) return baseFontSize * 1.10;
    return baseFontSize;
  }

  static double scalePadding(BuildContext context, double basePadding) {
    final width = MediaQuery.sizeOf(context).width;
    if (width < narrowMobileMax) return basePadding * 0.75;
    if (width >= tabletMax) return basePadding * 1.4;
    if (width >= mobileMax) return basePadding * 1.15;
    return basePadding;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= tabletMax) {
          return desktop ?? tablet ?? mobile;
        }
        if (constraints.maxWidth >= mobileMax) {
          return tablet ?? mobile;
        }
        return mobile;
      },
    );
  }
}

/// Global Responsive Widget that switches between Row and Column to prevent overflow
class ResponsiveRowColumn extends StatelessWidget {
  final List<Widget> children;
  final MainAxisAlignment mainAxisAlignment;
  final CrossAxisAlignment crossAxisAlignment;
  final double spacing;

  const ResponsiveRowColumn({
    super.key,
    required this.children,
    this.mainAxisAlignment = MainAxisAlignment.start,
    this.crossAxisAlignment = CrossAxisAlignment.center,
    this.spacing = 10.0,
  });

  @override
  Widget build(BuildContext context) {
    if (context.isNarrowMobile) {
      return Column(
        crossAxisAlignment: crossAxisAlignment,
        children: children
            .map((c) => Padding(
          padding: EdgeInsets.only(bottom: spacing),
          child: c,
        ))
            .toList(),
      );
    }

    return Row(
      mainAxisAlignment: mainAxisAlignment,
      crossAxisAlignment: crossAxisAlignment,
      children: children
          .map((c) => Padding(
        padding: EdgeInsets.only(right: spacing),
        child: c,
      ))
          .toList(),
    );
  }
}

/// BuildContext extension for effortless access to responsiveness methods anywhere in the app.
extension ResponsiveContextX on BuildContext {
  /// Checks if the screen width is very narrow (< 360)
  bool get isNarrowMobile => Responsive.isNarrowMobile(this);

  /// Checks if the device is mobile (< 600)
  bool get isMobile => Responsive.isMobile(this);

  /// Checks if the device is tablet (600 <= width < 1100)
  bool get isTablet => Responsive.isTablet(this);

  /// Checks if the device is desktop (>= 1100)
  bool get isDesktop => Responsive.isDesktop(this);

  /// Screen Width
  double get screenWidth => Responsive.widthOf(this);

  /// Screen Height
  double get screenHeight => Responsive.heightOf(this);

  /// Returns percentage of screen width (e.g. context.percentWidth(50))
  double percentWidth(double percent) => (screenWidth * percent) / 100;

  /// Returns percentage of screen height (e.g. context.percentHeight(30))
  double percentHeight(double percent) => (screenHeight * percent) / 100;

  /// Scaled font size
  double scaleFont(double baseFontSize) =>
      Responsive.scaleFont(this, baseFontSize);

  /// Scaled padding
  double scalePadding(double basePadding) =>
      Responsive.scalePadding(this, basePadding);

  /// Value based on device type
  T responsiveValue<T>({
    required T mobile,
    T? tablet,
    T? desktop,
  }) =>
      Responsive.value<T>(
        this,
        mobile: mobile,
        tablet: tablet,
        desktop: desktop,
      );

  // ---- Spacing (scales with screen size) ----
  double get spaceXS => scalePadding(4);
  double get spaceS => scalePadding(8);
  double get spaceM => scalePadding(16);
  double get spaceL => scalePadding(24);
  double get spaceXL => scalePadding(32);

  // ---- Font sizes (scales with screen size) ----
  double get fontSizeCaption => scaleFont(12);
  double get fontSizeBody => scaleFont(14);
  double get fontSizeSubTitle => scaleFont(16);
  double get fontSizeTitle => scaleFont(20);
  double get fontSizeHeading => scaleFont(24);
}