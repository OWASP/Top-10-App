import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:top_10_app/app/theme.dart';
import 'package:top_10_app/core/brand_icons.dart';

double _contrastRatio(Color foreground, Color background) {
  final double a = foreground.computeLuminance();
  final double b = background.computeLuminance();
  final double lighter = a > b ? a : b;
  final double darker = a > b ? b : a;
  return (lighter + 0.05) / (darker + 0.05);
}

void main() {
  for (final Brightness brightness in Brightness.values) {
    for (final bool highContrast in <bool>[false, true]) {
      test('${brightness.name} theme meets WCAG 2.2 AA '
          '(highContrast: $highContrast)', () {
        final ColorScheme scheme = buildAppTheme(
          brightness: brightness,
          highContrast: highContrast,
        ).colorScheme;

        void expectTextContrast(Color foreground, Color background) {
          expect(
            _contrastRatio(foreground, background),
            greaterThanOrEqualTo(4.5),
            reason: 'Text needs at least 4.5:1 contrast.',
          );
        }

        void expectUiContrast(Color foreground, Color background) {
          expect(
            _contrastRatio(foreground, background),
            greaterThanOrEqualTo(3.0),
            reason: 'Icons and UI components need at least 3:1 contrast.',
          );
        }

        expectTextContrast(scheme.onSurface, scheme.surface);
        expectTextContrast(scheme.onSurface, scheme.surfaceContainer);
        expectTextContrast(scheme.onSurface, scheme.surfaceContainerLow);
        expectTextContrast(scheme.onSurface, scheme.surfaceContainerHigh);
        expectTextContrast(scheme.onSurfaceVariant, scheme.surface);
        expectTextContrast(scheme.onSurfaceVariant, scheme.surfaceContainer);
        expectTextContrast(scheme.onSurfaceVariant, scheme.surfaceContainerLow);
        expectTextContrast(
          scheme.onSurfaceVariant,
          scheme.surfaceContainerHigh,
        );
        expectTextContrast(
          scheme.onSurfaceVariant,
          scheme.surfaceContainerHighest,
        );
        expectTextContrast(
          scheme.onSecondaryContainer,
          scheme.secondaryContainer,
        );
        expectTextContrast(scheme.onPrimary, scheme.primary);
        expectTextContrast(scheme.onError, scheme.error);
        expectTextContrast(scheme.onErrorContainer, scheme.errorContainer);
        expectTextContrast(scheme.onPrimaryContainer, scheme.primaryContainer);
        expectUiContrast(scheme.primary, scheme.surface);
        expectUiContrast(scheme.error, scheme.surface);
        expectUiContrast(scheme.outline, scheme.surface);

        // Per-list accents are used as text on a tinted badge and as icons on
        // cards, so check both pairs in every theme variant.
        for (final String listId in <String>[
          'web-2025',
          'api-2023',
          'llm-2026',
          'agentic-skills-2026',
          'agentic-applications-2026',
          'mcp-2025',
        ]) {
          final Color accent = listAccentFor(scheme, listId);
          // AI editions keep their accent as chip label colour when unselected.
          if (isAiList(listId)) {
            expectTextContrast(accent, scheme.surfaceContainerLow);
          }
          final Color badgeBackground = Color.alphaBlend(
            accent.withValues(alpha: 0.14),
            scheme.surfaceContainerLow,
          );
          expectTextContrast(accent, badgeBackground);
          expectUiContrast(accent, scheme.surfaceContainerLow);

          // Accents also act as filled surfaces (Practice buttons), as text on
          // the tinted list header, and as the selected chip checkmark.
          expectTextContrast(onColorFor(accent), accent);

          final Color headerBackground = Color.alphaBlend(
            accent.withValues(alpha: 0.10),
            scheme.surface,
          );
          expectTextContrast(accent, headerBackground);
          expectTextContrast(scheme.onSurface, headerBackground);
          expectTextContrast(scheme.onSurfaceVariant, headerBackground);

          final Color chipBackground = Color.alphaBlend(
            accent.withValues(alpha: 0.16),
            scheme.surfaceContainerLow,
          );
          expectUiContrast(accent, chipBackground);
        }

        // Each bottom-navigation glyph keeps its own colour, on the bar itself
        // and inside the selected indicator.
        for (final BrandGlyph glyph in BrandGlyph.values) {
          final Color accent = navAccentFor(scheme, glyph);
          expectUiContrast(accent, scheme.surfaceContainer);
          expectUiContrast(accent, scheme.surfaceContainerHighest);
        }
      });
    }
  }
}
