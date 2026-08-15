/// Central spacing scale. Prefer these over magic numbers in
/// `EdgeInsets`/`SizedBox` whenever a value represents layout rhythm rather
/// than a one-off visual nudge.
class AppSpacing {
  const AppSpacing._();

  static const double xxs = 4;
  static const double xs = 8;
  static const double sm = 12;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
  static const double xxl = 48;

  /// Standard horizontal margin for screen content.
  static const double screenHorizontal = 20;

  /// Standard vertical margin for screen content.
  static const double screenVertical = 16;
}
