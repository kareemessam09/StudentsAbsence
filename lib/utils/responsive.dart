import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:responsive_framework/responsive_framework.dart';

/// Responsive utility class for adaptive sizing and spacing
/// Note: Use .w, .h, .sp, .r extensions directly from flutter_screenutil package
class Responsive {
  /// Check if device is mobile (< 450dp)
  static bool isMobile(BuildContext context) =>
      ResponsiveBreakpoints.of(context).isMobile;

  /// Check if device is tablet (451dp - 800dp)
  static bool isTablet(BuildContext context) =>
      ResponsiveBreakpoints.of(context).isTablet;

  /// Check if device is desktop (> 800dp)
  static bool isDesktop(BuildContext context) =>
      ResponsiveBreakpoints.of(context).isDesktop;

  /// Get screen width
  static double screenWidth(BuildContext context) =>
      MediaQuery.of(context).size.width;

  /// Get screen height
  static double screenHeight(BuildContext context) =>
      MediaQuery.of(context).size.height;

  /// Get safe area padding
  static EdgeInsets safeAreaPadding(BuildContext context) =>
      MediaQuery.of(context).padding;

  /// Responsive horizontal padding based on device type
  static double horizontalPadding(BuildContext context) {
    if (isDesktop(context)) return 48.0.w;
    if (isTablet(context)) return 32.0.w;
    return 24.0.w;
  }

  /// Responsive vertical padding based on device type
  static double verticalPadding(BuildContext context) {
    if (isDesktop(context)) return 32.0.h;
    if (isTablet(context)) return 24.0.h;
    return 16.0.h;
  }

  /// Maximum content width for large screens
  static double maxContentWidth(BuildContext context) {
    if (isDesktop(context)) return 1200.0.w;
    if (isTablet(context)) return 800.0.w;
    return double.infinity;
  }

  /// Get responsive card elevation
  static double cardElevation(BuildContext context) {
    if (isDesktop(context)) return 4.0;
    return 2.0;
  }

  /// Get responsive button height
  static double buttonHeight(BuildContext context) {
    if (isDesktop(context)) return 60.0.h;
    if (isTablet(context)) return 56.0.h;
    return 52.0.h;
  }

  /// Get responsive icon size
  static double iconSize(BuildContext context, {double base = 24}) {
    if (isDesktop(context)) return (base * 1.2).r;
    if (isTablet(context)) return (base * 1.1).r;
    return base.r;
  }

  /// Get responsive app bar height
  static double appBarHeight(BuildContext context) {
    if (isDesktop(context)) return 64.0.h;
    return 56.0.h;
  }

  /// Get number of grid columns based on screen size
  static int gridColumns(BuildContext context) {
    if (isDesktop(context)) return 4;
    if (isTablet(context)) return 3;
    return 2;
  }

  /// Responsive spacing
  static SizedBox verticalSpace(double size) => SizedBox(height: size.h);
  static SizedBox horizontalSpace(double size) => SizedBox(width: size.w);

  /// Responsive padding
  static EdgeInsets padding({
    double? all,
    double? horizontal,
    double? vertical,
    double? top,
    double? bottom,
    double? left,
    double? right,
  }) {
    if (all != null) return EdgeInsets.all(all.r);
    return EdgeInsets.only(
      top: (top ?? vertical ?? 0).h,
      bottom: (bottom ?? vertical ?? 0).h,
      left: (left ?? horizontal ?? 0).w,
      right: (right ?? horizontal ?? 0).w,
    );
  }

  /// Responsive margin
  static EdgeInsets margin({
    double? all,
    double? horizontal,
    double? vertical,
    double? top,
    double? bottom,
    double? left,
    double? right,
  }) {
    return padding(
      all: all,
      horizontal: horizontal,
      vertical: vertical,
      top: top,
      bottom: bottom,
      left: left,
      right: right,
    );
  }

  /// Responsive border radius
  static BorderRadius borderRadius(double radius) =>
      BorderRadius.circular(radius.r);

  /// Get adaptive font size based on text style
  static double adaptiveFontSize(BuildContext context, double baseSize) {
    final scale = MediaQuery.of(context).textScaleFactor;
    final clampedScale = scale.clamp(0.8, 1.2);
    return (baseSize * clampedScale).sp;
  }

  /// Center content on large screens
  static Widget centerContent({
    required BuildContext context,
    required Widget child,
  }) {
    if (isDesktop(context) || isTablet(context)) {
      return Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxContentWidth(context)),
          child: child,
        ),
      );
    }
    return child;
  }

  /// Responsive grid view
  static int crossAxisCount(
    BuildContext context, {
    int mobile = 2,
    int tablet = 3,
    int desktop = 4,
  }) {
    if (isDesktop(context)) return desktop;
    if (isTablet(context)) return tablet;
    return mobile;
  }

  /// Responsive aspect ratio
  static double aspectRatio(
    BuildContext context, {
    double mobile = 1.0,
    double tablet = 1.2,
    double desktop = 1.5,
  }) {
    if (isDesktop(context)) return desktop;
    if (isTablet(context)) return tablet;
    return mobile;
  }
}
