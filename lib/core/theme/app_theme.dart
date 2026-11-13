import 'package:animations/animations.dart';
import 'package:flutter/cupertino.dart' show CupertinoPageTransitionsBuilder;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../domain/enums.dart';

/// Brand teal (logo, app icon). Never changes with the theme.
const kBrandTeal = Color(0xFF2E7D6B);

/// A soft background with a matching foreground, e.g. a quick-log tile.
@immutable
class Tone {
  const Tone(this.bg, this.fg);

  final Color bg;
  final Color fg;

  static Tone lerp(Tone a, Tone b, double t) =>
      Tone(Color.lerp(a.bg, b.bg, t)!, Color.lerp(a.fg, b.fg, t)!);
}

/// Pawdian's warm palette ("warm and cozy" style). Read it with
/// `context.paw`; it follows the light / dark theme.
@immutable
class PawColors extends ThemeExtension<PawColors> {
  const PawColors({
    required this.bg,
    required this.card,
    required this.fill,
    required this.border,
    required this.ink,
    required this.subtle,
    required this.brand,
    required this.brandSoft,
    required this.onBrand,
    required this.danger,
    required this.dangerSoft,
    required this.warning,
    required this.shadow,
    required this.peach,
    required this.sky,
    required this.lavender,
    required this.sand,
    required this.rose,
    required this.mint,
    required this.butter,
  });

  /// Page background (cream), cards, input / chip fills and hairlines.
  final Color bg, card, fill, border;

  /// Main and secondary text.
  final Color ink, subtle;

  /// Brand teal for primary actions; [brandSoft] for tinted surfaces.
  final Color brand, brandSoft, onBrand;

  final Color danger, dangerSoft, warning, shadow;

  /// Pastel tones for record types and pet avatars.
  final Tone peach, sky, lavender, sand, rose, mint, butter;

  List<Tone> get avatarTones => [peach, mint, sky, lavender, butter, rose];

  /// Stable colour for a pet, picked from its id.
  Tone petTone(String petId) {
    var h = 0;
    for (final c in petId.codeUnits) {
      h = (h * 31 + c) & 0x7fffffff;
    }
    return avatarTones[h % avatarTones.length];
  }

  /// Colour of a record type, shared by quick log, timeline and reports.
  Tone recordTone(RecordType t) => switch (t) {
    RecordType.feeding => peach,
    RecordType.water || RecordType.urine => sky,
    RecordType.poop => sand,
    RecordType.vomit ||
    RecordType.cough ||
    RecordType.lethargy ||
    RecordType.appetiteLoss => rose,
    RecordType.medication ||
    RecordType.dewormInternal ||
    RecordType.dewormExternal ||
    RecordType.heartworm => lavender,
    RecordType.vaccine || RecordType.checkup || RecordType.vetVisit => mint,
    RecordType.grooming => butter,
    RecordType.note || RecordType.custom => mint,
  };

  Tone reminderTone(ReminderType t) => switch (t) {
    ReminderType.vaccine || ReminderType.checkup => mint,
    ReminderType.medication ||
    ReminderType.dewormInternal ||
    ReminderType.dewormExternal ||
    ReminderType.heartworm => lavender,
    ReminderType.grooming => butter,
    ReminderType.custom => peach,
  };

  static const light = PawColors(
    bg: Color(0xFFFBF6EF),
    card: Color(0xFFFFFFFF),
    fill: Color(0xFFF4ECE2),
    border: Color(0xFFEEE3D6),
    ink: Color(0xFF3A2A20),
    subtle: Color(0xFF8C7768),
    brand: kBrandTeal,
    brandSoft: Color(0xFFDDEFE8),
    onBrand: Colors.white,
    danger: Color(0xFFC2553A),
    dangerSoft: Color(0xFFFBE4DC),
    warning: Color(0xFFB7791F),
    shadow: Color(0x148A4B26),
    peach: Tone(Color(0xFFFDE7D7), Color(0xFF8A4B26)),
    sky: Tone(Color(0xFFDDEFF7), Color(0xFF1E5873)),
    lavender: Tone(Color(0xFFEDE4F7), Color(0xFF5B3B87)),
    sand: Tone(Color(0xFFF1E7D6), Color(0xFF6B5330)),
    rose: Tone(Color(0xFFFBE1E4), Color(0xFF8E2F3E)),
    mint: Tone(Color(0xFFDDF1E8), Color(0xFF1F5E50)),
    butter: Tone(Color(0xFFFBF0C9), Color(0xFF7A5A0C)),
  );

  static const dark = PawColors(
    bg: Color(0xFF1A1512),
    card: Color(0xFF241D18),
    fill: Color(0xFF2E2620),
    border: Color(0xFF3A3029),
    ink: Color(0xFFF3E9DF),
    subtle: Color(0xFFB7A595),
    brand: Color(0xFF6FC7AE),
    brandSoft: Color(0xFF1F3A33),
    onBrand: Color(0xFF0E2A23),
    danger: Color(0xFFF08A6E),
    dangerSoft: Color(0xFF4A2A22),
    warning: Color(0xFFE7B45A),
    shadow: Color(0x33000000),
    peach: Tone(Color(0xFF4A3022), Color(0xFFF8C9A6)),
    sky: Tone(Color(0xFF1F3742), Color(0xFFA9D7EC)),
    lavender: Tone(Color(0xFF352B47), Color(0xFFD5C2F0)),
    sand: Tone(Color(0xFF3D3324), Color(0xFFE6D2AF)),
    rose: Tone(Color(0xFF47262C), Color(0xFFF4B5BF)),
    mint: Tone(Color(0xFF1F3A33), Color(0xFFA6E0CC)),
    butter: Tone(Color(0xFF3F3517), Color(0xFFF2D98A)),
  );

  @override
  PawColors copyWith() => this;

  @override
  PawColors lerp(PawColors? other, double t) {
    if (other == null) return this;
    Color c(Color a, Color b) => Color.lerp(a, b, t)!;
    return PawColors(
      bg: c(bg, other.bg),
      card: c(card, other.card),
      fill: c(fill, other.fill),
      border: c(border, other.border),
      ink: c(ink, other.ink),
      subtle: c(subtle, other.subtle),
      brand: c(brand, other.brand),
      brandSoft: c(brandSoft, other.brandSoft),
      onBrand: c(onBrand, other.onBrand),
      danger: c(danger, other.danger),
      dangerSoft: c(dangerSoft, other.dangerSoft),
      warning: c(warning, other.warning),
      shadow: c(shadow, other.shadow),
      peach: Tone.lerp(peach, other.peach, t),
      sky: Tone.lerp(sky, other.sky, t),
      lavender: Tone.lerp(lavender, other.lavender, t),
      sand: Tone.lerp(sand, other.sand, t),
      rose: Tone.lerp(rose, other.rose, t),
      mint: Tone.lerp(mint, other.mint, t),
      butter: Tone.lerp(butter, other.butter, t),
    );
  }
}

extension PawTheme on BuildContext {
  PawColors get paw => Theme.of(this).extension<PawColors>()!;
}

/// Corner radii used across the app.
abstract final class PawRadius {
  static const card = 20.0;
  static const tile = 16.0;
  static const field = 14.0;
  static const sheet = 28.0;
}

ThemeData buildLightTheme() => _build(PawColors.light, Brightness.light);

ThemeData buildDarkTheme() => _build(PawColors.dark, Brightness.dark);

ThemeData _build(PawColors p, Brightness brightness) {
  final dark = brightness == Brightness.dark;
  final scheme = ColorScheme.fromSeed(
    seedColor: kBrandTeal,
    brightness: brightness,
    primary: p.brand,
    onPrimary: p.onBrand,
    primaryContainer: p.brandSoft,
    surface: p.bg,
    onSurface: p.ink,
    onSurfaceVariant: p.subtle,
    surfaceContainerLowest: p.card,
    surfaceContainerLow: p.card,
    surfaceContainer: p.card,
    surfaceContainerHigh: p.card,
    surfaceContainerHighest: p.fill,
    outline: p.border,
    outlineVariant: p.border,
    error: p.danger,
    errorContainer: p.dangerSoft,
  );
  final base = ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    brightness: brightness,
  );
  // Filled fields keep the floating label inside the box; the focus colour
  // shows as a line along the bottom edge.
  final fieldBorder = UnderlineInputBorder(
    borderRadius: BorderRadius.circular(PawRadius.field),
    borderSide: BorderSide.none,
  );
  final text = base.textTheme.apply(bodyColor: p.ink, displayColor: p.ink);
  return base.copyWith(
    extensions: [p],
    scaffoldBackgroundColor: p.bg,
    canvasColor: p.card,
    dividerColor: p.border,
    dividerTheme: DividerThemeData(color: p.border, space: 1, thickness: 1),
    textTheme: text.copyWith(
      titleLarge: text.titleLarge?.copyWith(fontWeight: FontWeight.w700),
      titleMedium: text.titleMedium?.copyWith(fontWeight: FontWeight.w600),
      titleSmall: text.titleSmall?.copyWith(
        fontWeight: FontWeight.w600,
        color: p.subtle,
      ),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: p.bg,
      surfaceTintColor: Colors.transparent,
      foregroundColor: p.ink,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: dark ? Brightness.light : Brightness.dark,
        statusBarBrightness: brightness,
        systemNavigationBarColor: p.card,
        systemNavigationBarIconBrightness: dark
            ? Brightness.light
            : Brightness.dark,
      ),
      titleTextStyle: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w700,
        color: p.ink,
      ),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: p.card,
      surfaceTintColor: Colors.transparent,
      indicatorColor: p.brandSoft,
      elevation: 0,
      height: 68,
      iconTheme: WidgetStateProperty.resolveWith(
        (s) => IconThemeData(
          color: s.contains(WidgetState.selected) ? p.brand : p.subtle,
        ),
      ),
      labelTextStyle: WidgetStateProperty.resolveWith(
        (s) => TextStyle(
          fontSize: 12,
          fontWeight: s.contains(WidgetState.selected)
              ? FontWeight.w700
              : FontWeight.w500,
          color: s.contains(WidgetState.selected) ? p.brand : p.subtle,
        ),
      ),
    ),
    cardTheme: CardThemeData(
      color: p.card,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(PawRadius.card),
      ),
    ),
    listTileTheme: ListTileThemeData(
      iconColor: p.subtle,
      subtitleTextStyle: TextStyle(color: p.subtle, fontSize: 13.5),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(PawRadius.tile),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: p.fill,
      contentPadding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      border: fieldBorder,
      enabledBorder: fieldBorder,
      focusedBorder: fieldBorder.copyWith(
        borderSide: BorderSide(color: p.brand, width: 1.6),
      ),
      errorBorder: fieldBorder.copyWith(
        borderSide: BorderSide(color: p.danger, width: 1.2),
      ),
      focusedErrorBorder: fieldBorder.copyWith(
        borderSide: BorderSide(color: p.danger, width: 1.6),
      ),
      labelStyle: TextStyle(color: p.subtle),
      floatingLabelStyle: TextStyle(color: p.brand),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: p.brand,
        foregroundColor: p.onBrand,
        minimumSize: const Size(64, 52),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(PawRadius.tile),
        ),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: p.brand,
        minimumSize: const Size(64, 48),
        side: BorderSide(color: p.border, width: 1.2),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(PawRadius.tile),
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(foregroundColor: p.brand),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: p.brand,
      foregroundColor: p.onBrand,
      elevation: 2,
      highlightElevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(PawRadius.tile + 2),
      ),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: p.fill,
      selectedColor: p.brandSoft,
      side: BorderSide.none,
      labelStyle: TextStyle(color: p.ink, fontWeight: FontWeight.w500),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith(
        (s) => s.contains(WidgetState.selected) ? p.onBrand : p.subtle,
      ),
      trackColor: WidgetStateProperty.resolveWith(
        (s) => s.contains(WidgetState.selected) ? p.brand : p.fill,
      ),
      trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: dark ? const Color(0xFF3A3029) : const Color(0xFF3A2A20),
      contentTextStyle: const TextStyle(color: Colors.white),
      actionTextColor: const Color(0xFF9FE1CB),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    ),
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: p.card,
      surfaceTintColor: Colors.transparent,
      showDragHandle: true,
      dragHandleColor: p.border,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(PawRadius.sheet),
        ),
      ),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: p.card,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
    ),
    popupMenuTheme: PopupMenuThemeData(
      color: p.card,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    ),
    datePickerTheme: DatePickerThemeData(
      backgroundColor: p.card,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
    ),
    timePickerTheme: TimePickerThemeData(
      backgroundColor: p.card,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
    ),
    pageTransitionsTheme: const PageTransitionsTheme(
      builders: {
        TargetPlatform.android: SharedAxisPageTransitionsBuilder(
          transitionType: SharedAxisTransitionType.horizontal,
        ),
        TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        TargetPlatform.windows: SharedAxisPageTransitionsBuilder(
          transitionType: SharedAxisTransitionType.horizontal,
        ),
      },
    ),
  );
}

/// Soft card decoration: white (or [color]) with a warm shadow.
BoxDecoration softCard(PawColors p, {Color? color, double? radius}) =>
    BoxDecoration(
      color: color ?? p.card,
      borderRadius: BorderRadius.circular(radius ?? PawRadius.card),
      border: p.card.computeLuminance() < 0.2
          ? Border.all(color: p.border.withValues(alpha: 0.7))
          : null,
      boxShadow: [
        BoxShadow(color: p.shadow, blurRadius: 20, offset: const Offset(0, 6)),
      ],
    );
