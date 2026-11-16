import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../content/content_repository.dart';
import '../../content/models.dart';
import '../../content/providers.dart';
import '../../core/brand_icons.dart';
import '../../core/widgets.dart';
import '../../data/providers.dart';

class RiskDetailScreen extends ConsumerStatefulWidget {
  const RiskDetailScreen({
    required this.listId,
    required this.riskId,
    super.key,
  });

  final String listId;
  final String riskId;

  @override
  ConsumerState<RiskDetailScreen> createState() => _RiskDetailScreenState();
}

class _RiskDetailScreenState extends ConsumerState<RiskDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(progressRepositoryProvider).markRead(widget.riskId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final AsyncValue<ContentBundle> bundleAsync = ref.watch(
      contentBundleProvider,
    );

    return bundleAsync.when(
      loading: () => Scaffold(
        appBar: AppBar(),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (Object error, StackTrace stackTrace) {
        final List<String> errors = error is ContentUnavailableException
            ? error.errors
            : <String>[error.toString()];
        return Scaffold(
          appBar: AppBar(),
          body: ContentUnavailableView(errors: errors),
        );
      },
      data: (ContentBundle bundle) {
        final RiskList? list = bundle.listById(widget.listId);
        final Risk? risk = list?.riskById(widget.riskId);
        if (list == null || risk == null) {
          return Scaffold(
            appBar: AppBar(),
            body: const EmptyState(
              message: 'This risk is not in the bundled content.',
              icon: Icons.search_off,
            ),
          );
        }
        return _buildDetail(bundle, list, risk);
      },
    );
  }

  Widget _buildDetail(ContentBundle bundle, RiskList list, Risk risk) {
    final Set<String> bookmarks =
        ref.watch(bookmarkedRiskIdsProvider).value ?? const <String>{};
    final bool bookmarked = bookmarks.contains(risk.id);

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text('${risk.code}: ${risk.title}'),
          actions: <Widget>[
            IconButton(
              tooltip: bookmarked ? 'Remove bookmark' : 'Bookmark risk',
              isSelected: bookmarked,
              icon: const Icon(Icons.bookmark_border),
              selectedIcon: Icon(
                Icons.bookmark,
                color: listAccent(context, list.id),
              ),
              onPressed: () {
                ref.read(progressRepositoryProvider).toggleBookmark(risk.id);
              },
            ),
          ],
          bottom: const TabBar(
            tabs: <Widget>[
              Tab(text: 'Overview'),
              Tab(text: 'Code'),
              Tab(text: 'Defend'),
            ],
          ),
        ),
        body: TabBarView(
          children: <Widget>[
            _OverviewTab(bundle: bundle, list: list, risk: risk),
            _CodeTab(risk: risk),
            _DefendTab(bundle: bundle, list: list, risk: risk),
          ],
        ),
      ),
    );
  }
}

class _OverviewTab extends StatelessWidget {
  const _OverviewTab({
    required this.bundle,
    required this.list,
    required this.risk,
  });

  final ContentBundle bundle;
  final RiskList list;
  final Risk risk;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme scheme = theme.colorScheme;
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      children: <Widget>[
        if (bundle.isDraft) const DraftContentBanner(),
        if (bundle.isDraft) const SizedBox(height: 8),
        const SectionHeader(title: 'Summary', icon: Icons.subject),
        Text(
          risk.summary,
          style: theme.textTheme.bodyLarge?.copyWith(height: 1.5),
        ),
        const SectionHeader(
          title: 'Real-world example',
          icon: Icons.travel_explore,
        ),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                ExcludeSemantics(
                  child: Icon(
                    Icons.format_quote,
                    color: scheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(risk.example, style: theme.textTheme.bodyLarge),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
        Text(
          '${list.title} ${list.edition}',
          style: theme.textTheme.labelLarge,
        ),
        const SizedBox(height: 4),
        Text(
          'Last reviewed ${_formatDate(risk.lastReviewed)}',
          style: theme.textTheme.labelSmall?.copyWith(
            color: scheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class _CodeTab extends StatelessWidget {
  const _CodeTab({required this.risk});

  final Risk risk;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    if (risk.codeSamples.isEmpty) {
      return const EmptyState(
        message: 'Code samples for this risk are still under review.',
        icon: Icons.code_off,
      );
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      children: <Widget>[
        for (final CodeSample sample in risk.codeSamples) ...<Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Text(sample.label, style: theme.textTheme.titleMedium),
              ),
              Chip(
                label: Text(sample.language),
                visualDensity: VisualDensity.compact,
              ),
            ],
          ),
          const SizedBox(height: 8),
          _CodeBlock(sample: sample),
          const SizedBox(height: 20),
        ],
      ],
    );
  }
}

class _CodeBlock extends StatelessWidget {
  const _CodeBlock({required this.sample});

  final CodeSample sample;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme scheme = theme.colorScheme;
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 6, 6, 0),
            child: Row(
              children: <Widget>[
                ExcludeSemantics(
                  child: Icon(
                    Icons.terminal,
                    size: 18,
                    color: scheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '${sample.language} sample',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ),
                IconButton(
                  tooltip: 'Copy code',
                  icon: const Icon(Icons.copy, size: 18),
                  onPressed: () => _copyCode(context),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Semantics(
              label: '${sample.label} ${sample.language} code sample',
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: SelectableText(
                  sample.code,
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 13,
                    height: 1.5,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _copyCode(BuildContext context) async {
    await Clipboard.setData(ClipboardData(text: sample.code));
    if (!context.mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Code copied')));
  }
}

class _DefendTab extends StatelessWidget {
  const _DefendTab({
    required this.bundle,
    required this.list,
    required this.risk,
  });

  final ContentBundle bundle;
  final RiskList list;
  final Risk risk;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final int index = list.risks.indexWhere((Risk item) => item.id == risk.id);
    final Risk? next = index >= 0 && index + 1 < list.risks.length
        ? list.risks[index + 1]
        : null;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      children: <Widget>[
        const SectionHeader(title: 'Test for it', icon: Icons.science_outlined),
        Text(
          risk.testTip,
          style: theme.textTheme.bodyLarge?.copyWith(height: 1.5),
        ),
        const SectionHeader(
          title: 'How to fix it',
          icon: Icons.build_circle_outlined,
        ),
        Text(risk.fix, style: theme.textTheme.bodyLarge?.copyWith(height: 1.5)),
        const SectionHeader(title: 'Sources', icon: Icons.link),
        for (final Reference reference in risk.references)
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(
              Icons.open_in_new,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            title: Text(reference.title),
            subtitle: SelectableText(reference.url),
          ),
        const SizedBox(height: 8),
        Text(
          risk.reviewers.isEmpty
              ? 'Awaiting SME review · last updated '
                    '${_formatDate(risk.lastReviewed)}'
              : 'Reviewed by ${risk.reviewers.join(', ')} on '
                    '${_formatDate(risk.lastReviewed)}',
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          child: FilledButton.tonalIcon(
            onPressed: next == null
                ? null
                : () => context.go('/learn/${list.id}/${next.id}'),
            icon: const Icon(Icons.arrow_forward),
            label: Text(next == null ? 'End of list' : 'Next risk'),
          ),
        ),
      ],
    );
  }
}

String _formatDate(DateTime date) {
  final String month = date.month.toString().padLeft(2, '0');
  final String day = date.day.toString().padLeft(2, '0');
  return '${date.year}-$month-$day';
}
