import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../content/content_repository.dart';
import '../../content/models.dart';
import '../../content/providers.dart';
import '../../core/brand_icons.dart';
import '../../core/widgets.dart';
import '../../data/database.dart';
import '../../data/providers.dart';

class ProgressScreen extends ConsumerWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<ContentBundle> bundleAsync = ref.watch(
      contentBundleProvider,
    );
    final Set<String> readIds =
        ref.watch(readRiskIdsProvider).value ?? const <String>{};
    final Set<String> bookmarkedIds =
        ref.watch(bookmarkedRiskIdsProvider).value ?? const <String>{};
    final List<QuizAttemptEntry> attempts =
        ref.watch(quizAttemptsProvider).value ?? const <QuizAttemptEntry>[];

    return Scaffold(
      appBar: AppBar(title: const Text('Progress')),
      body: bundleAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (Object error, StackTrace stackTrace) {
          final List<String> errors = error is ContentUnavailableException
              ? error.errors
              : <String>[error.toString()];
          return ContentUnavailableView(errors: errors);
        },
        data: (ContentBundle bundle) => _buildContent(
          context,
          ref,
          bundle,
          readIds,
          bookmarkedIds,
          attempts,
        ),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    WidgetRef ref,
    ContentBundle bundle,
    Set<String> readIds,
    Set<String> bookmarkedIds,
    List<QuizAttemptEntry> attempts,
  ) {
    final ThemeData theme = Theme.of(context);
    final List<Risk> allRisks = <Risk>[
      for (final RiskList list in bundle.lists) ...list.risks,
    ];
    final int readCount = allRisks
        .where((Risk risk) => readIds.contains(risk.id))
        .length;

    final List<({RiskList list, Risk risk})> bookmarkedRisks =
        <({RiskList list, Risk risk})>[
          for (final RiskList list in bundle.lists)
            for (final Risk risk in list.risks)
              if (bookmarkedIds.contains(risk.id)) (list: list, risk: risk),
        ];

    return ListView(
      padding: const EdgeInsets.only(bottom: 32),
      children: <Widget>[
        if (bundle.isDraft) const DraftContentBanner(),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          child: _SummaryCard(
            readCount: readCount,
            totalRisks: allRisks.length,
            listCount: bundle.lists.length,
            bookmarkCount: bookmarkedRisks.length,
            answeredCount: attempts.length,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: SectionHeader(
            title: 'Bookmarks',
            icon: Icons.bookmark_border,
            trailing: CountPill('${bookmarkedRisks.length} saved'),
          ),
        ),
        if (bookmarkedRisks.isEmpty)
          const _HintCard(
            icon: Icons.bookmark_border,
            message:
                'Bookmark a risk from its detail screen and it will appear '
                'here.',
          )
        else
          for (final ({RiskList list, Risk risk}) bookmark in bookmarkedRisks)
            _BookmarkCard(list: bookmark.list, risk: bookmark.risk),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: SectionHeader(
            title: 'Quiz activity',
            icon: Icons.quiz_outlined,
            trailing: CountPill(
              '${attempts.length} '
              '${attempts.length == 1 ? 'answer' : 'answers'}',
            ),
          ),
        ),
        if (attempts.isEmpty)
          const _HintCard(
            icon: Icons.quiz_outlined,
            message:
                'Take a quiz in Practice and your results will be summarised '
                'here.',
          )
        else
          for (final RiskList list in bundle.lists)
            if (attempts.any((QuizAttemptEntry a) => a.listId == list.id))
              _QuizSummaryCard(list: list, attempts: attempts),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: SectionHeader(title: 'More', icon: Icons.tune),
        ),
        _ActionCard(
          icon: Icons.info_outline,
          title: 'About & licenses',
          subtitle: 'Content sources, licenses, and privacy',
          onTap: () => context.push('/about'),
        ),
        _ActionCard(
          icon: Icons.restart_alt,
          title: 'Reset progress',
          subtitle: 'Clears read state, bookmarks, and quiz history',
          destructive: true,
          onTap: () => _confirmReset(context, ref),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
          child: Text(
            'Progress is stored on this device only.',
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }

  Future<void> _confirmReset(BuildContext context, WidgetRef ref) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Reset progress?'),
          content: const Text(
            'This removes your read state, bookmarks, and quiz history from '
            'this device.',
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Reset'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;
    await ref.read(progressRepositoryProvider).resetAll();
    if (!context.mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Progress reset')));
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.readCount,
    required this.totalRisks,
    required this.listCount,
    required this.bookmarkCount,
    required this.answeredCount,
  });

  final int readCount;
  final int totalRisks;
  final int listCount;
  final int bookmarkCount;
  final int answeredCount;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme scheme = theme.colorScheme;
    final double fraction = totalRisks == 0 ? 0 : readCount / totalRisks;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Semantics(
              label: 'Risks read',
              value: '$readCount of $totalRisks',
              excludeSemantics: true,
              child: SizedBox(
                width: 104,
                height: 104,
                child: Stack(
                  alignment: Alignment.center,
                  children: <Widget>[
                    SizedBox(
                      width: 104,
                      height: 104,
                      child: CircularProgressIndicator(
                        value: fraction,
                        strokeWidth: 10,
                        strokeCap: StrokeCap.round,
                        backgroundColor: scheme.surfaceContainerHighest,
                      ),
                    ),
                    MediaQuery.withClampedTextScaling(
                      maxScaleFactor: 2,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Text(
                            '$readCount',
                            style: theme.textTheme.headlineSmall,
                          ),
                          Text(
                            'of $totalRisks',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: scheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text('Risks read', style: theme.textTheme.titleMedium),
                  const SizedBox(height: 4),
                  Text(
                    '$readCount of $totalRisks across $listCount lists',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: <Widget>[
                      CountPill('$bookmarkCount saved'),
                      CountPill('$answeredCount answered'),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BookmarkCard extends StatelessWidget {
  const _BookmarkCard({required this.list, required this.risk});

  final RiskList list;
  final Risk risk;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme scheme = theme.colorScheme;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => context.go('/learn/${list.id}/${risk.id}'),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 10, 10, 10),
          child: Row(
            children: <Widget>[
              CodeBadge(
                code: risk.code,
                accent: listAccent(context, list.id),
                size: 40,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(risk.title, style: theme.textTheme.titleSmall),
                    const SizedBox(height: 2),
                    Text(
                      '${list.family.toUpperCase()} ${list.edition}',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: scheme.onSurfaceVariant),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuizSummaryCard extends StatelessWidget {
  const _QuizSummaryCard({required this.list, required this.attempts});

  final RiskList list;
  final List<QuizAttemptEntry> attempts;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final List<QuizAttemptEntry> listAttempts = attempts
        .where((QuizAttemptEntry attempt) => attempt.listId == list.id)
        .toList(growable: false);
    final int correct = listAttempts
        .where((QuizAttemptEntry attempt) => attempt.correct)
        .length;
    final double fraction = listAttempts.isEmpty
        ? 0
        : correct / listAttempts.length;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Icon(
                  Icons.insights_outlined,
                  color: listAccent(context, list.id),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    '${list.title} ${list.edition}',
                    style: theme.textTheme.titleSmall,
                  ),
                ),
                const SizedBox(width: 8),
                CountPill('$correct/${listAttempts.length}'),
              ],
            ),
            const SizedBox(height: 12),
            Semantics(
              label:
                  '${list.title} ${list.edition} quiz score, '
                  '$correct of ${listAttempts.length} correct',
              excludeSemantics: true,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: LinearProgressIndicator(
                  value: fraction,
                  color: listAccent(context, list.id),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '$correct of ${listAttempts.length} answers correct',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HintCard extends StatelessWidget {
  const _HintCard({required this.icon, required this.message});

  final IconData icon;
  final String message;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: <Widget>[
              Icon(icon, color: theme.colorScheme.onSurfaceVariant),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  message,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  const _ActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.destructive = false,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool destructive;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme scheme = theme.colorScheme;
    final Color accent = destructive ? scheme.error : scheme.primary;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      clipBehavior: Clip.antiAlias,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Container(
          width: 40,
          height: 40,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: accent.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: accent, size: 22),
        ),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: Icon(Icons.chevron_right, color: scheme.onSurfaceVariant),
        onTap: onTap,
      ),
    );
  }
}
