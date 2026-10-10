/// Shared responsive breakpoints for adaptive navigation and layouts.
///
/// Keep these values based on the available window width, not the device type.
abstract final class AppBreakpoints {
  /// Switch between a bottom navigation bar and a navigation rail.
  static const double compactMaxWidth = 600;

  /// Give the navigation rail room to show its labels beside the icons.
  static const double expandedMinWidth = 840;

  static bool isCompact(double width) => width < compactMaxWidth;

  static bool isExpanded(double width) => width >= expandedMinWidth;
}

/// Shared spacing scale, in logical pixels.
abstract final class AppSpacing {
  static const double extraSmall = 4;
  static const double small = 8;
  static const double medium = 16;
  static const double large = 24;
  static const double extraLarge = 32;
}
