import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../content/content_repository.dart';
import '../../content/models.dart';
import '../../content/providers.dart';
import '../../core/brand_icons.dart';
import '../../core/search_query.dart';
import '../../core/widgets.dart';
import '../../data/providers.dart';

class LearnScreen extends ConsumerStatefulWidget {
  const LearnScreen({super.key});

  @override
  ConsumerState<LearnScreen> createState() => _LearnScreenState();
}

class _LearnScreenState extends ConsumerState<LearnScreen> {
  final TextEditingController _searchController = TextEditingController();
  String? _selectedListId;
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AsyncValue<ContentBundle> bundleAsync = ref.watch(
      contentBundleProvider,
    );

    return Scaffold(
      appBar: AppBar(
        leadingWidth: 68,
        leading: const Padding(
          padding: EdgeInsets.only(left: 20),
          child: Center(child: AppMark(size: 30)),
        ),
        titleSpacing: 0,
        title: const Text('OWASP Top 10'),
      ),
      body: bundleAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (Object error, StackTrace stackTrace) {
          final List<String> errors = error is ContentUnavailableException
              ? error.errors
              : <String>[error.toString()];
          return ContentUnavailableView(errors: errors);
        },
        data: (ContentBundle bundle) => _buildContent(bundle),
      ),
    );
  }

  Widget _buildContent(ContentBundle bundle) {
    final ThemeData theme = Theme.of(context);
    final Set<String> readIds =
        ref.watch(readRiskIdsProvider).value ?? const <String>{};

    final String selectedListId =
        _selectedListId ?? (bundle.lists.isEmpty ? '' : bundle.lists.first.id);
    final RiskList? selectedList = bundle.listById(selectedListId);

    final List<({RiskList list, Risk risk})> rows =
        <({RiskList list, Risk risk})>[
          for (final RiskList list in bundle.lists)
            if (list.id == selectedListId)
              for (final Risk risk in list.risks) (list: list, risk: risk),
        ];

    final List<({RiskList list, Risk risk})> visible = _query.isEmpty
        ? rows
        : rows
              .where(
                (({RiskList list, Risk risk}) row) =>
                    _matches(row.list, row.risk, _query),
              )
              .toList(growable: false);

    final int listReadCount = selectedList == null
        ? 0
        : selectedList.risks
              .where((Risk risk) => readIds.contains(risk.id))
              .length;

    return Column(
      children: <Widget>[
        if (bundle.isDraft) const DraftContentBanner(),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.only(bottom: 24),
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 4),
                child: TextField(
                  controller: _searchController,
                  textInputAction: TextInputAction.search,
                  inputFormatters: const <TextInputFormatter>[
                    SearchQueryInputFormatter(),
                  ],
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.search),
                    hintText: 'Search this list',
                    suffixIcon: _query.isEmpty
                        ? null
                        : IconButton(
                            tooltip: 'Clear search',
                            icon: const Icon(Icons.close),
                            onPressed: () {
                              _searchController.clear();
                              setState(() => _query = '');
                            },
                          ),
                  ),
                  onChanged: (String value) {
                    setState(() => _query = sanitizeSearchQuery(value));
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 4),
                child: EvenFilterChips(
                  chips:
                      <
                        ({
                          String label,
                          bool selected,
                          VoidCallback onSelected,
                          Color accent,
                          bool emphasized,
                        })
                      >[
                        for (final RiskList list in bundle.lists)
                          (
                            label:
                                '${list.family.toUpperCase()} '
                                '${list.edition}',
                            selected: selectedListId == list.id,
                            accent: listAccent(context, list.id),
                            emphasized: isAiList(list.id),
                            onSelected: () =>
                                setState(() => _selectedListId = list.id),
                          ),
                      ],
                ),
              ),
              if (selectedList != null)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 6),
                  child: _ListSummaryHeader(
                    list: selectedList,
                    readCount: listReadCount,
                    accent: listAccent(context, selectedList.id),
                  ),
                ),
              if (_query.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 6,
                  ),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      '${visible.length} '
                      'result${visible.length == 1 ? '' : 's'}',
                      style: theme.textTheme.labelMedium,
                    ),
                  ),
                ),
              if (visible.isEmpty)
                const Padding(
                  padding: EdgeInsets.only(top: 40),
                  child: EmptyState(
                    message:
                        'No risks match this view yet. Content for this '
                        'list is still under review.',
                    icon: Icons.search_off,
                  ),
                )
              else
                for (final ({RiskList list, Risk risk}) row in visible)
                  _RiskCard(
                    list: row.list,
                    risk: row.risk,
                    read: readIds.contains(row.risk.id),
                  ),
            ],
          ),
        ),
      ],
    );
  }

  bool _matches(RiskList list, Risk risk, String rawQuery) {
    // Belt and braces: even if a caller skips the input formatter, the string
    // only ever reaches a literal substring comparison.
    final String query = sanitizeSearchQuery(rawQuery).toLowerCase();
    if (query.isEmpty) return true;
    final Iterable<String> haystack = <String>[
      list.title,
      list.edition,
      risk.code,
      risk.title,
      risk.summary,
      risk.example,
      risk.testTip,
      risk.fix,
      for (final CodeSample sample in risk.codeSamples) ...<String>[
        sample.label,
        sample.language,
        sample.code,
      ],
    ];
    return haystack.any((String value) => value.toLowerCase().contains(query));
  }
}

/// The selected list's identity: icon, title, read count and a progress bar,
/// all in that list's accent colour.
class _ListSummaryHeader extends StatelessWidget {
  const _ListSummaryHeader({
    required this.list,
    required this.readCount,
    required this.accent,
  });

  final RiskList list;
  final int readCount;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final int total = list.risks.length;
    final double fraction = total == 0 ? 0 : readCount / total;

    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: accent.withValues(alpha: 0.24)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(listIconFor(list.id), size: 19, color: accent),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      '${list.title} ${list.edition}',
                      style: theme.textTheme.titleSmall,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '$readCount of $total risks read',
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Semantics(
            label: 'List progress',
            value: '$readCount of $total risks read',
            child: ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: LinearProgressIndicator(
                value: fraction,
                minHeight: 6,
                color: accent,
                backgroundColor: accent.withValues(alpha: 0.18),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RiskCard extends StatelessWidget {
  const _RiskCard({required this.list, required this.risk, required this.read});

  final RiskList list;
  final Risk risk;
  final bool read;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme scheme = theme.colorScheme;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => context.go('/learn/${list.id}/${risk.id}'),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 12, 10, 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              CodeBadge(code: risk.code, accent: listAccent(context, list.id)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(risk.title, style: theme.textTheme.titleMedium),
                    const SizedBox(height: 4),
                    Text(
                      risk.summary,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: <Widget>[
                        ExcludeSemantics(
                          child: Icon(
                            read
                                ? Icons.check_circle
                                : Icons.radio_button_unchecked,
                            size: 16,
                            color: read ? scheme.primary : scheme.outline,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          read ? 'Read' : 'Not read',
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: read
                                ? scheme.primary
                                : scheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 4),
              Icon(
                Icons.chevron_right,
                color: scheme.onSurfaceVariant,
                semanticLabel: 'Open risk',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
