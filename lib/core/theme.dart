import 'package:flutter/material.dart';

/// Lararium palette — ported 1:1 from the approved HTML prototype
/// (prototype/index.html), light & dark.
@immutable
class LarariumColors extends ThemeExtension<LarariumColors> {
  const LarariumColors({
    required this.bg,
    required this.surface,
    required this.surface2,
    required this.surface3,
    required this.ink,
    required this.ink2,
    required this.ink3,
    required this.ink4,
    required this.line,
    required this.line2,
    required this.brand,
    required this.brandSoft,
    required this.amber,
    required this.amberSoft,
    required this.plum,
    required this.plumSoft,
    required this.danger,
    required this.dangerSoft,
  });

  final Color bg;
  final Color surface;
  final Color surface2;
  final Color surface3;
  final Color ink;
  final Color ink2;
  final Color ink3;
  final Color ink4;
  final Color line;
  final Color line2;
  final Color brand;
  final Color brandSoft;
  final Color amber;
  final Color amberSoft;
  final Color plum;
  final Color plumSoft;
  final Color danger;
  final Color dangerSoft;

  static const light = LarariumColors(
    bg: Color(0xFFF7F5F1),
    surface: Color(0xFFFFFFFF),
    surface2: Color(0xFFF2EFEA),
    surface3: Color(0xFFEAE6DE),
    ink: Color(0xFF1A1917),
    ink2: Color(0xFF5C574F),
    ink3: Color(0xFF8B857C),
    ink4: Color(0xFFB4AEA4),
    line: Color(0xFFE6E1D9),
    line2: Color(0xFFD8D2C7),
    brand: Color(0xFF2E6B4F),
    brandSoft: Color(0xFFE7F0EB),
    amber: Color(0xFFC87A1E),
    amberSoft: Color(0xFFFBF0E1),
    plum: Color(0xFF5A4A5E),
    plumSoft: Color(0xFFF1EBF0),
    danger: Color(0xFFB4433A),
    dangerSoft: Color(0xFFFAEAE8),
  );

  static const dark = LarariumColors(
    bg: Color(0xFF111010),
    surface: Color(0xFF1B1A18),
    surface2: Color(0xFF232120),
    surface3: Color(0xFF2C2A28),
    ink: Color(0xFFF5F2ED),
    ink2: Color(0xFFB3ADA3),
    ink3: Color(0xFF847E75),
    ink4: Color(0xFF5F5A53),
    line: Color(0xFF302E2B),
    line2: Color(0xFF3C3936),
    brand: Color(0xFF5FA583),
    brandSoft: Color(0xFF1C2E26),
    amber: Color(0xFFE0A24E),
    amberSoft: Color(0xFF2E2417),
    plum: Color(0xFFB69BC0),
    plumSoft: Color(0xFF2A2330),
    danger: Color(0xFFE08378),
    dangerSoft: Color(0xFF33201E),
  );

  @override
  LarariumColors copyWith({LarariumColors? other}) => other ?? this;

  @override
  LarariumColors lerp(LarariumColors? other, double t) =>
      other == null ? this : (t < .5 ? this : other);
}

ThemeData larariumTheme(Brightness brightness) {
  final c =
      brightness == Brightness.dark ? LarariumColors.dark : LarariumColors.light;
  final scheme = ColorScheme(
    brightness: brightness,
    primary: c.brand,
    onPrimary: Colors.white,
    secondary: c.amber,
    onSecondary: Colors.white,
    error: c.danger,
    onError: Colors.white,
    surface: c.surface,
    onSurface: c.ink,
    surfaceContainerHighest: c.surface2,
    onSurfaceVariant: c.ink2,
    outline: c.line2,
    outlineVariant: c.line,
  );
  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: c.bg,
    extensions: [c],
    fontFamily: null, // system font per plan (6.6): no bundled latin font
    appBarTheme: AppBarTheme(
      backgroundColor: c.bg,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      foregroundColor: c.ink,
      centerTitle: false,
    ),
    dividerTheme: DividerThemeData(color: c.line, thickness: 1, space: 1),
    cardTheme: CardTheme(
      color: c.surface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: c.line),
      ),
      margin: EdgeInsets.zero,
    ),
    bottomSheetTheme: const BottomSheetThemeData(
      showDragHandle: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
      ),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: c.surface,
      indicatorColor: c.brandSoft,
      labelTextStyle: WidgetStatePropertyAll(
        TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: c.ink2),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: c.surface2,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(11),
        borderSide: BorderSide(color: c.line2),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(11),
        borderSide: BorderSide(color: c.line2),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(11),
        borderSide: BorderSide(color: c.brand, width: 1.4),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: brightness == Brightness.dark ? c.ink : c.ink,
      contentTextStyle: TextStyle(
        color: brightness == Brightness.dark ? c.bg : c.bg,
        fontSize: 13,
        fontWeight: FontWeight.w500,
      ),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(11)),
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith(
        (s) => s.contains(WidgetState.selected) ? Colors.white : c.ink4,
      ),
      trackColor: WidgetStateProperty.resolveWith(
        (s) => s.contains(WidgetState.selected) ? c.brand : c.surface3,
      ),
      trackOutlineColor: const WidgetStatePropertyAll(Colors.transparent),
    ),
  );
}
