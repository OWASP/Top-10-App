import 'package:flutter/material.dart';

/// OWASP blue, taken from the logo artwork, so the app chrome matches the mark.
const Color _seedColor = Color(0xFF1B4388);

/// Material 3 theme for the app.
///
/// Colours come from one seed so light, dark and high-contrast variants stay
/// consistent. Contrast for the text and UI pairs the app relies on is checked
/// in `test/app/theme_contrast_test.dart`.
ThemeData buildAppTheme({
  Brightness brightness = Brightness.dark,
  bool highContrast = false,
  bool readableText = false,
}) {
  final ColorScheme scheme = ColorScheme.fromSeed(
    seedColor: _seedColor,
    brightness: brightness,
    contrastLevel: highContrast ? 1.0 : 0.0,
  );

  final ThemeData base = ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: scheme.surface,
    appBarTheme: AppBarTheme(
      backgroundColor: scheme.surface,
      foregroundColor: scheme.onSurface,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
    ),
    cardTheme: CardThemeData(
      elevation: 0,
      margin: EdgeInsets.zero,
      color: scheme.surfaceContainerLow,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: scheme.outlineVariant),
      ),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: scheme.surfaceContainerLow,
      selectedColor: scheme.secondaryContainer,
      disabledColor: scheme.surfaceContainerLow,
      side: BorderSide(color: scheme.outlineVariant),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
    ),
    inputDecorationTheme: InputDecorationThemeData(
      filled: true,
      fillColor: scheme.surfaceContainerHigh,
      hintStyle: TextStyle(color: scheme.onSurfaceVariant),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: scheme.outlineVariant),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: scheme.primary, width: 2),
      ),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: scheme.surfaceContainer,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      // A neutral pill keeps every per-tab glyph readable, including in the
      // high-contrast schemes where the container roles reverse.
      indicatorColor: scheme.surfaceContainerHighest,
      indicatorShape: const StadiumBorder(),
      labelTextStyle: WidgetStateProperty.resolveWith((
        Set<WidgetState> states,
      ) {
        final bool selected = states.contains(WidgetState.selected);
        return TextStyle(
          fontSize: 12,
          fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
          color: selected ? scheme.onSurface : scheme.onSurfaceVariant,
        );
      }),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size(0, 48),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        textStyle: const TextStyle(fontWeight: FontWeight.w600),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(0, 48),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        side: BorderSide(color: scheme.outline),
        textStyle: const TextStyle(fontWeight: FontWeight.w600),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        minimumSize: const Size(0, 48),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: const TextStyle(fontWeight: FontWeight.w600),
      ),
    ),
    tabBarTheme: TabBarThemeData(
      indicatorSize: TabBarIndicatorSize.tab,
      dividerColor: scheme.outlineVariant,
      labelStyle: const TextStyle(fontWeight: FontWeight.w700),
      unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500),
    ),
    expansionTileTheme: ExpansionTileThemeData(
      shape: const Border(),
      collapsedShape: const Border(),
      iconColor: scheme.onSurfaceVariant,
      collapsedIconColor: scheme.onSurfaceVariant,
      textColor: scheme.onSurface,
      collapsedTextColor: scheme.onSurface,
    ),
    listTileTheme: ListTileThemeData(iconColor: scheme.onSurfaceVariant),
    dividerTheme: DividerThemeData(color: scheme.outlineVariant, thickness: 1),
    progressIndicatorTheme: ProgressIndicatorThemeData(
      color: scheme.primary,
      linearTrackColor: scheme.surfaceContainerHighest,
      linearMinHeight: 8,
      borderRadius: BorderRadius.circular(999),
      strokeCap: StrokeCap.round,
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: scheme.surfaceContainerHigh,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
  );

  final ThemeData emphasized = base.copyWith(
    textTheme: _emphasizedTextTheme(base.textTheme),
  );
  return readableText
      ? emphasized.copyWith(textTheme: _readableTextTheme(emphasized.textTheme))
      : emphasized;
}

TextTheme _emphasizedTextTheme(TextTheme base) {
  return base.copyWith(
    headlineMedium: base.headlineMedium?.copyWith(
      fontWeight: FontWeight.w700,
      letterSpacing: -0.4,
    ),
    headlineSmall: base.headlineSmall?.copyWith(
      fontWeight: FontWeight.w700,
      letterSpacing: -0.3,
    ),
    titleLarge: base.titleLarge?.copyWith(fontWeight: FontWeight.w700),
    titleMedium: base.titleMedium?.copyWith(fontWeight: FontWeight.w600),
    titleSmall: base.titleSmall?.copyWith(fontWeight: FontWeight.w600),
    labelLarge: base.labelLarge?.copyWith(fontWeight: FontWeight.w600),
  );
}

TextTheme _readableTextTheme(TextTheme base) {
  TextStyle? spaced(TextStyle? style) {
    if (style == null) return null;
    final double size = style.fontSize ?? 14;
    return style.copyWith(
      letterSpacing: size * 0.03,
      wordSpacing: size * 0.08,
      height: 1.7,
    );
  }

  return TextTheme(
    displayLarge: spaced(base.displayLarge),
    displayMedium: spaced(base.displayMedium),
    displaySmall: spaced(base.displaySmall),
    headlineLarge: spaced(base.headlineLarge),
    headlineMedium: spaced(base.headlineMedium),
    headlineSmall: spaced(base.headlineSmall),
    titleLarge: spaced(base.titleLarge),
    titleMedium: spaced(base.titleMedium),
    titleSmall: spaced(base.titleSmall),
    bodyLarge: spaced(base.bodyLarge),
    bodyMedium: spaced(base.bodyMedium),
    bodySmall: spaced(base.bodySmall),
    labelLarge: spaced(base.labelLarge),
    labelMedium: spaced(base.labelMedium),
    labelSmall: spaced(base.labelSmall),
  );
}
