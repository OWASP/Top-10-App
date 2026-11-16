import 'package:flutter/material.dart';

/// Distinctive, hand-drawn navigation marks used by the app shell.
///
/// They share a 24×24 grid and a single stroke weight so the five tabs read as
/// one family. Colour comes from the surrounding [IconTheme], which is how
/// [NavigationBar] tints selected and unselected destinations.
enum BrandGlyph { learn, practice, sheets, progress, access }

class BrandIcon extends StatelessWidget {
  const BrandIcon(
    this.glyph, {
    this.size = 24,
    this.color,
    this.filled = false,
    super.key,
  });

  final BrandGlyph glyph;
  final double size;
  final Color? color;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    final Color resolved =
        color ??
        IconTheme.of(context).color ??
        Theme.of(context).colorScheme.onSurfaceVariant;
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _BrandIconPainter(
          glyph: glyph,
          color: resolved,
          filled: filled,
        ),
      ),
    );
  }
}

class _BrandIconPainter extends CustomPainter {
  const _BrandIconPainter({
    required this.glyph,
    required this.color,
    required this.filled,
  });

  final BrandGlyph glyph;
  final Color color;
  final bool filled;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.scale(size.shortestSide / 24);

    final Paint stroke = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = filled ? 2.3 : 1.9
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final Paint fill = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    final Paint tint = Paint()
      ..color = color.withValues(alpha: 0.16)
      ..style = PaintingStyle.fill;

    switch (glyph) {
      case BrandGlyph.learn:
        final Path book = Path()
          ..moveTo(12, 6.6)
          ..cubicTo(9.4, 5.2, 6.4, 5.1, 3.4, 5.9)
          ..lineTo(3.4, 18.1)
          ..cubicTo(6.4, 17.3, 9.4, 17.4, 12, 18.8)
          ..cubicTo(14.6, 17.4, 17.6, 17.3, 20.6, 18.1)
          ..lineTo(20.6, 5.9)
          ..cubicTo(17.6, 5.1, 14.6, 5.2, 12, 6.6)
          ..close();
        if (filled) canvas.drawPath(book, tint);
        canvas.drawPath(book, stroke);
        canvas.drawLine(const Offset(12, 6.6), const Offset(12, 18.8), stroke);
      case BrandGlyph.practice:
        if (filled) canvas.drawCircle(const Offset(12, 12), 8.5, tint);
        canvas.drawCircle(const Offset(12, 12), 8.5, stroke);
        canvas.drawCircle(const Offset(12, 12), 4.7, stroke);
        final Path check = Path()
          ..moveTo(9.5, 12.1)
          ..lineTo(11.3, 13.9)
          ..lineTo(14.8, 10.3);
        canvas.drawPath(check, stroke);
      case BrandGlyph.sheets:
        final RRect body = RRect.fromRectAndRadius(
          const Rect.fromLTRB(4.9, 4.8, 19.1, 20),
          const Radius.circular(3.4),
        );
        if (filled) canvas.drawRRect(body, tint);
        canvas.drawRRect(body, stroke);
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            const Rect.fromLTRB(9.2, 2.6, 14.8, 6),
            const Radius.circular(1.6),
          ),
          fill,
        );
        final Paint detail = Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = filled ? 1.9 : 1.6
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round;
        final Path checkTop = Path()
          ..moveTo(8.3, 11.1)
          ..lineTo(9.8, 12.6)
          ..lineTo(12.1, 9.9);
        final Path checkBottom = Path()
          ..moveTo(8.3, 15.9)
          ..lineTo(9.8, 17.4)
          ..lineTo(12.1, 14.7);
        canvas.drawPath(checkTop, detail);
        canvas.drawPath(checkBottom, detail);
        canvas.drawLine(
          const Offset(13.5, 11.2),
          const Offset(16.3, 11.2),
          detail,
        );
        canvas.drawLine(const Offset(13.5, 16), const Offset(16.3, 16), detail);
      case BrandGlyph.progress:
        final List<RRect> bars = <RRect>[
          RRect.fromRectAndRadius(
            const Rect.fromLTRB(4.4, 13.6, 8.4, 20.2),
            const Radius.circular(2),
          ),
          RRect.fromRectAndRadius(
            const Rect.fromLTRB(10, 9.4, 14, 20.2),
            const Radius.circular(2),
          ),
          RRect.fromRectAndRadius(
            const Rect.fromLTRB(15.6, 4.8, 19.6, 20.2),
            const Radius.circular(2),
          ),
        ];
        for (final RRect bar in bars) {
          canvas.drawRRect(bar, filled ? fill : stroke);
        }
      case BrandGlyph.access:
        final Paint limb = Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = filled ? 2.5 : 2.1
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round;
        canvas.drawCircle(const Offset(12, 4.6), 2.2, fill);
        canvas.drawLine(
          const Offset(4.9, 10.2),
          const Offset(19.1, 10.2),
          limb,
        );
        canvas.drawLine(const Offset(12, 10.2), const Offset(12, 14.6), limb);
        canvas.drawLine(const Offset(12, 14.6), const Offset(8.7, 20.8), limb);
        canvas.drawLine(const Offset(12, 14.6), const Offset(15.3, 20.8), limb);
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(_BrandIconPainter oldDelegate) {
    return oldDelegate.glyph != glyph ||
        oldDelegate.color != color ||
        oldDelegate.filled != filled;
  }
}

/// Compact app mark: the OWASP logo on a rounded white tile.
///
/// The logo keeps its official blue artwork on white so it stays legible in
/// both light and dark themes. Decorative by default; pass [semanticLabel]
/// when it stands alone.
class AppMark extends StatelessWidget {
  const AppMark({this.size = 32, this.semanticLabel, super.key});

  final double size;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final BorderRadius radius = BorderRadius.circular(size * 0.26);
    final Widget mark = SizedBox(
      width: size,
      height: size,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: radius,
          border: Border.all(color: scheme.outlineVariant),
        ),
        child: ClipRRect(
          borderRadius: radius,
          child: Image.asset(
            'assets/images/owasp_logo.png',
            fit: BoxFit.cover,
            filterQuality: FilterQuality.high,
            gaplessPlayback: true,
          ),
        ),
      ),
    );

    if (semanticLabel == null) return ExcludeSemantics(child: mark);
    return Semantics(label: semanticLabel, excludeSemantics: true, child: mark);
  }
}

/// Whether a list belongs to the AI group shown together in the filters.
bool isAiList(String listId) {
  return switch (listId) {
    'llm-2026' ||
    'agentic-skills-2026' ||
    'agentic-applications-2026' ||
    'mcp-2025' => true,
    _ => false,
  };
}

/// An icon that identifies a Top 10 list at a glance.
IconData listIconFor(String listId) {
  return switch (listId) {
    'web-2025' => Icons.public,
    'api-2023' => Icons.api,
    'llm-2026' => Icons.smart_toy_outlined,
    'agentic-skills-2026' => Icons.extension_outlined,
    'agentic-applications-2026' => Icons.hub_outlined,
    'mcp-2025' => Icons.account_tree_outlined,
    _ => Icons.security,
  };
}

/// Black or white, whichever reads better on [background].
///
/// Used when a list accent becomes a filled surface, such as the primary
/// action button in Practice.
Color onColorFor(Color background) {
  return ThemeData.estimateBrightnessForColor(background) == Brightness.dark
      ? Colors.white
      : Colors.black;
}

/// A stable accent colour per Top 10 list.
///
/// The lightness is chosen so the colour stays readable as text on a tinted
/// badge in both light and dark themes.
Color listAccent(BuildContext context, String listId) {
  return listAccentFor(Theme.of(context).colorScheme, listId);
}

Color listAccentFor(ColorScheme scheme, String listId) {
  final int hue = switch (listId) {
    'web-2025' => 174,
    'api-2023' => 217,
    'llm-2026' => 268,
    'agentic-skills-2026' => 320,
    'agentic-applications-2026' => 12,
    'mcp-2025' => 152,
    _ => 174,
  };
  return _accentForHue(scheme, hue);
}

/// A distinct colour for each bottom-navigation destination.
///
/// Learn is blue, Practice teal, Sheets purple, Progress amber and Access
/// green. The same luminance search as the list accents keeps every icon
/// readable against the navigation bar in both themes.
Color navAccentFor(ColorScheme scheme, BrandGlyph glyph) {
  final int hue = switch (glyph) {
    BrandGlyph.learn => 220,
    BrandGlyph.practice => 174,
    BrandGlyph.sheets => 268,
    BrandGlyph.progress => 28,
    BrandGlyph.access => 145,
  };
  return _accentForHue(scheme, hue);
}

Color _accentForHue(ColorScheme scheme, int hue) {
  final bool dark = scheme.brightness == Brightness.dark;
  final double saturation = dark ? 0.45 : 0.55;
  // Aim for a relative luminance that keeps the accent readable on the tinted
  // badge backgrounds in each theme. Luminance rises monotonically with HSL
  // lightness, so a short binary search lands on the target for every hue.
  final double target = dark ? 0.62 : 0.1;
  double low = 0;
  double high = 1;
  for (int i = 0; i < 14; i++) {
    final double mid = (low + high) / 2;
    final double luminance = HSLColor.fromAHSL(
      1,
      hue.toDouble(),
      saturation,
      mid,
    ).toColor().computeLuminance();
    if (luminance < target) {
      low = mid;
    } else {
      high = mid;
    }
  }
  return HSLColor.fromAHSL(
    1,
    hue.toDouble(),
    saturation,
    (low + high) / 2,
  ).toColor();
}
