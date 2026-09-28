import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Controla el modo claro / oscuro de toda la app.
final ValueNotifier<ThemeMode> themeMode = ValueNotifier(ThemeMode.light);

const gold1 = Color(0xFFF7E08A);
const gold2 = Color(0xFFE0AA2B);
const gold3 = Color(0xFFA8730F);
const black = Color(0xFF17110A);
const ink = Color(0xFF2A1D05);
const goldSoft = Color(0x26E6B53A); // dorado con transparencia

// Café de la web (header / tarjetas del dashboard)
const brown = Color(0xFF4A3122);
const brown2 = Color(0xFF5E4326);
// Dorado de la barra inferior (igual que el sidebar de la web)
const navGold1 = Color(0xFFF7E18E);
const navGold2 = Color(0xFFE6B53A);

// Gris cálido para las tarjetas que antes eran negras (ya no se usa en cardTile,
// se conserva por si algo más lo referencia).
const cardDark = Color(0xFF17110A);

const metal = LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [Color(0xFFF9E79A), Color(0xFFE6B53A), Color(0xFFB98010)],
  stops: [0, .45, 1],
);

/// Paleta que cambia según el modo claro/oscuro.
class Pal {
  final bool dark;
  const Pal(this.dark);
  static Pal of(BuildContext c) => Pal(Theme.of(c).brightness == Brightness.dark);

  // Blanco hueso, igual que en la web (--bg: #f8f7f2)
  Color get bg => dark ? const Color(0xFF15100A) : const Color(0xFFF8F7F2);
  Color get card => dark ? const Color(0xFF221B0E) : const Color(0xFFFFFFFF);
  Color get tx => dark ? const Color(0xFFF8ECC4) : ink;
  Color get mu => dark ? const Color(0xFFB9A26A) : const Color(0xFF8A7648);
  Color get ln => dark ? const Color(0xFF4A3A16) : const Color(0xFFE7E2D6);
  Color get bar2 => dark ? const Color(0xFF9A7328) : brown;
  // Color de las barras/leyenda de Compras: café de las tarjetas en claro
  Color get barCompras => dark ? gold3 : gold2;
  // Tarjetas (KPI / Precios del día): café en modo oscuro, amarillo claro en modo claro
  // (en modo claro ya no llevan colores oscuros).
  // Claro: café de la web. Oscuro: mismo tono oscuro del menú lateral.
  Color get cardTile => dark ? const Color(0xFF1D1509) : const Color(0xFFF8F7F2);
  Color get cardTileLabel => dark ? Colors.white70 : mu;
  Color get cardTileValue => dark ? gold1 : gold3;
  Color get cardTilePillBg => navGold2;
  Color get cardTilePillText => ink;
  // Barra inferior de navegación: oscura solo en modo oscuro; en modo claro usa el
  // mismo dorado del header, para no llevar colores oscuros.
  Color get navBg => dark ? black : const Color(0xFFFFFFFF);
  Gradient? get navGradient => null;
  Color get navOn => dark ? gold1 : brown;
  Color get navOff => dark ? const Color(0xFFB9A26A) : const Color(0xFF8A7648);
  // Indicador dorado del módulo/pestaña activa
  Gradient get navActive => const LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [navGold1, navGold2]);
  // Amarillo fijo (sin degradado) en modo claro.
  Gradient get header => dark
      ? const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFF2A1E0A), Color(0xFF0F0B05)])
      : const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFFF8F7F2), Color(0xFFF8F7F2)]);
  // Fondo y texto del sidebar/drawer, igual que --sb / --sbt en la web
  Gradient get side => dark
      ? const LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xFF1D1509), Color(0xFF0E0A05)])
      : const LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xFFFFFFFF), Color(0xFFFFFFFF)]);
  Color get sideText => dark ? const Color(0xFFF0D98A) : brown;
  // Texto/íconos sobre el header café
  Color get onHeader => dark ? gold1 : gold3;
  // Fondo del menú lateral
  Color get drawerBg => dark ? bg : const Color(0xFFFFFFFF);
  Color get drawerTx => dark ? tx : brown;
  Color get drawerMu => dark ? mu : const Color(0xFF8A7648);
  Color get drawerIcon => dark ? gold2 : brown;
  // Logo dorado: el header y el menú ahora son oscuros en ambos modos
  String get logo => dark ? 'assets/logo_gold.png' : 'assets/logo_dark.png';
  String get logoHeader => 'assets/logo_gold.png';
}

ThemeData buildTheme(Brightness b) {
  final p = Pal(b == Brightness.dark);
  return ThemeData(
    useMaterial3: true,
    brightness: b,
    scaffoldBackgroundColor: p.bg,
    colorScheme: ColorScheme.fromSeed(seedColor: gold2, brightness: b),
    // Poppins, igual que la fuente usada en la web
    textTheme: GoogleFonts.poppinsTextTheme(
      Typography.material2021().black,
    ).apply(bodyColor: p.tx, displayColor: p.tx),
    fontFamily: GoogleFonts.poppins().fontFamily,
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: p.card,
      labelStyle: TextStyle(color: p.mu),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: p.ln)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: p.ln)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: gold2, width: 2)),
    ),
  );
}
