/// Central blur (sigma) values for glassmorphism surfaces. Keep the number
/// of on-screen blurred surfaces small — see docs/DESIGN_SYSTEM.md for when
/// to use [GlassSurface] and when a flat surface is the right call.
class AppBlur {
  const AppBlur._();

  static const double subtle = 8;
  static const double standard = 16;
  static const double strong = 24;
}
