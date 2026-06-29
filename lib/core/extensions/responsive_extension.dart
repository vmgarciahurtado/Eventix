import 'package:eventix/core/constants/breakpoints.dart';
import 'package:flutter/material.dart';

/// Extension on [BuildContext] that provides utilities for responsive design.
///
/// Facilitates access to screen dimensions and allows adapting
/// values or building layouts depending on the screen size
/// (mobile, tablet, or desktop).
///
/// ### Properties usage example
/// ```dart
/// Widget build(BuildContext context) {
///   if (context.isMobile) {
///     return MobileView();
///   } else if (context.isTablet) {
///     return TabletView();
///   }
///   return DesktopView();
/// }
/// ```
///
/// ### `responsiveValue` usage example
/// ```dart
/// Widget build(BuildContext context) {
///   // Will return 1 on mobile, 2 on tablet, and 4 on desktop mode.
///   final gridColumns = context.responsiveValue(
///     mobile: 1,
///     tablet: 2,
///     desktop: 4,
///   );
///
///   return GridView.count(
///     crossAxisCount: gridColumns,
///     // ...
///   );
/// }
/// ```
extension ResponsiveContextX on BuildContext {
  /// Gets the current width of the screen or object containing this context.
  double get screenWidth => MediaQuery.sizeOf(this).width;

  /// Gets the current height of the screen or object containing this context.
  double get screenHeight => MediaQuery.sizeOf(this).height;

  /// Returns `true` if the screen width corresponds to a mobile device.
  bool get isMobile => screenWidth < Breakpoints.mobile;

  /// Returns `true` if the screen width corresponds to a tablet.
  bool get isTablet =>
      screenWidth >= Breakpoints.mobile && screenWidth < Breakpoints.desktop;

  /// Returns `true` if the screen width corresponds to a desktop.
  bool get isDesktop => screenWidth >= Breakpoints.desktop;

  // =========================================
  // Responsive values helper
  // =========================================

  /// Evaluates and returns the corresponding value for the current breakpoint.
  ///
  /// [desktop] is the main/base value expected (large screens).
  /// [tablet] and [mobile] are optional and will fallback to [desktop]
  /// if they are not specified.
  ///
  /// **Example:**
  /// ```dart
  /// final double paddingSize = context.responsiveValue(
  ///   mobile: 16.0,
  ///   tablet: 24.0,
  ///   desktop: 32.0,
  /// );
  /// ```
  T responsiveValue<T>({required T desktop, T? tablet, T? mobile}) {
    if (isMobile && mobile != null) return mobile;
    if (isTablet && tablet != null) return tablet;
    return desktop;
  }
}
