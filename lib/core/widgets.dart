import 'package:flutter/material.dart';

/// Fail-closed screen shown when the content bundle cannot be trusted.
class ContentUnavailableView extends StatelessWidget {
  const ContentUnavailableView({required this.errors, super.key});

  final List<String> errors;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(
              Icons.report_outlined,
              size: 48,
              color: theme.colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Content unavailable',
              style: theme.textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'The bundled content could not be validated, so it is not being '
              'shown. Reinstall the app or contact the maintainers.',
              style: theme.textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            if (errors.isNotEmpty) ...<Widget>[
              const SizedBox(height: 16),
              ExpansionTile(
                title: const Text('Technical details'),
                children: <Widget>[
                  for (final String error in errors)
                    ListTile(dense: true, title: Text(error)),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Marks unreviewed content so it cannot be mistaken for release material.
class DraftContentBanner extends StatelessWidget {
  const DraftContentBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      color: scheme.errorContainer,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: <Widget>[
          Icon(Icons.edit_note, color: scheme.onErrorContainer),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Draft content. Under review, not for release.',
              style: TextStyle(color: scheme.onErrorContainer),
            ),
          ),
        ],
      ),
    );
  }
}

/// A wrapping row of filter chips with equal widths.
///
/// Three chips per row at normal text size, two when text is enlarged and one
/// at very large sizes, so every chip stays the same size. Labels that end in
/// a year are stacked as a family name over the edition, which keeps every
/// label readable inside the shared width.
class EvenFilterChips extends StatelessWidget {
  const EvenFilterChips({required this.chips, super.key});

  final List<
    ({
      String label,
      bool selected,
      VoidCallback onSelected,
      Color accent,
      bool emphasized,
    })
  >
  chips;

  @override
  Widget build(BuildContext context) {
    if (chips.isEmpty) return const SizedBox.shrink();

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        const double spacing = 8;
        final TextScaler textScaler = MediaQuery.textScalerOf(context);
        final double textScale = textScaler.scale(14) / 14;

        // Measure the family line (everything before the year) so long
        // edition names such as AGENTIC-SKILLS widen the chips instead of
        // being truncated. The family line is the bold, 12sp part.
        double widestFamily = 0;
        for (final ({
              String label,
              bool selected,
              VoidCallback onSelected,
              Color accent,
              bool emphasized,
            })
            chip
            in chips) {
          final int split = chip.label.lastIndexOf(' ');
          final String family = split > 0
              ? chip.label.substring(0, split)
              : chip.label;
          final TextPainter painter = TextPainter(
            text: TextSpan(
              text: family,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
            ),
            textDirection: TextDirection.ltr,
            textScaler: textScaler,
            maxLines: 1,
          )..layout();
          if (painter.width > widestFamily) widestFamily = painter.width;
          painter.dispose();
        }

        final double minChipWidth = widestFamily + 52;
        int columns =
            ((constraints.maxWidth + spacing) / (minChipWidth + spacing))
                .floor()
                .clamp(1, 3)
                .toInt();
        if (textScale > 1.15 && columns > 2) columns = 2;
        if (textScale > 1.6) columns = 1;
        final double width =
            (constraints.maxWidth - spacing * (columns - 1)) / columns;
        final double labelWidth = (width - 52).clamp(0.0, width);

        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: <Widget>[
            for (final ({
                  String label,
                  bool selected,
                  VoidCallback onSelected,
                  Color accent,
                  bool emphasized,
                })
                chip
                in chips)
              SizedBox(
                width: width,
                child: FilterChip(
                  label: SizedBox(
                    width: labelWidth,
                    child: Semantics(
                      label: chip.label,
                      excludeSemantics: true,
                      child: _ChipLabel(
                        chip.label,
                        color: chip.emphasized ? chip.accent : null,
                        emphasized: chip.emphasized,
                      ),
                    ),
                  ),
                  selected: chip.selected,
                  selectedColor: chip.accent.withValues(alpha: 0.16),
                  checkmarkColor: chip.accent,
                  side: chip.selected
                      ? BorderSide(color: chip.accent.withValues(alpha: 0.45))
                      : null,
                  onSelected: (_) => chip.onSelected(),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _ChipLabel extends StatelessWidget {
  const _ChipLabel(this.label, {this.color, this.emphasized = false});

  final String label;
  final Color? color;
  final bool emphasized;

  @override
  Widget build(BuildContext context) {
    final int split = label.lastIndexOf(' ');
    final String tail = split > 0 ? label.substring(split + 1) : '';
    final bool hasYear = split > 0 && RegExp(r'^\d{4}$').hasMatch(tail);

    if (!hasYear) {
      return Text(
        label,
        textAlign: TextAlign.center,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: color,
          fontWeight: emphasized ? FontWeight.w700 : null,
        ),
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Text(
          label.substring(0, split),
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 12,
            height: 1.2,
            fontWeight: emphasized ? FontWeight.w700 : FontWeight.w600,
            color: color,
          ),
        ),
        Text(
          tail,
          textAlign: TextAlign.center,
          maxLines: 1,
          style: TextStyle(
            fontSize: 11,
            height: 1.2,
            fontWeight: emphasized ? FontWeight.w600 : FontWeight.w400,
            color: color,
          ),
        ),
      ],
    );
  }
}

/// Simple empty state used by list-based screens.
class EmptyState extends StatelessWidget {
  const EmptyState({
    required this.message,
    this.icon = Icons.inbox_outlined,
    super.key,
  });

  final String message;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 28,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 14),
            Text(
              message,
              style: theme.textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

/// A section title with an optional leading icon and trailing widget.
class SectionHeader extends StatelessWidget {
  const SectionHeader({
    required this.title,
    this.icon,
    this.trailing,
    super.key,
  });

  final String title;
  final IconData? icon;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 10),
      child: Row(
        children: <Widget>[
          if (icon != null) ...<Widget>[
            Icon(icon, size: 20, color: theme.colorScheme.primary),
            const SizedBox(width: 8),
          ],
          Expanded(
            child: Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          ?trailing,
        ],
      ),
    );
  }
}

/// Small rounded label used for counts and statuses.
class CountPill extends StatelessWidget {
  const CountPill(this.label, {super.key});

  final String label;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: theme.textTheme.labelSmall?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

/// Short risk code in a tinted rounded badge.
class CodeBadge extends StatelessWidget {
  const CodeBadge({
    required this.code,
    required this.accent,
    this.size = 44,
    super.key,
  });

  final String code;
  final Color accent;
  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: accent.withValues(alpha: 0.14),
          borderRadius: BorderRadius.circular(size * 0.32),
        ),
        child: Center(
          child: MediaQuery.withNoTextScaling(
            child: Text(
              code,
              style: TextStyle(
                color: accent,
                fontSize: code.length > 4 ? 10 : 13,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.2,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
