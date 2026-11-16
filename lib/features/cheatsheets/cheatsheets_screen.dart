import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../content/content_repository.dart';
import '../../content/models.dart';
import '../../content/providers.dart';
import '../../core/brand_icons.dart';
import '../../core/widgets.dart';

class CheatsheetsScreen extends ConsumerWidget {
  const CheatsheetsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<ContentBundle> bundleAsync = ref.watch(
      contentBundleProvider,
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Cheatsheets')),
      body: bundleAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (Object error, StackTrace stackTrace) {
          final List<String> errors = error is ContentUnavailableException
              ? error.errors
              : <String>[error.toString()];
          return ContentUnavailableView(errors: errors);
        },
        data: (ContentBundle bundle) {
          final List<RiskList> withCheatsheets = bundle.lists
              .where((RiskList list) => list.cheatsheets.isNotEmpty)
              .toList(growable: false);

          if (withCheatsheets.isEmpty) {
            return const EmptyState(
              message: 'Cheatsheets are still under review.',
              icon: Icons.checklist_outlined,
            );
          }

          final ThemeData theme = Theme.of(context);
          return ListView(
            padding: const EdgeInsets.only(bottom: 32),
            children: <Widget>[
              if (bundle.isDraft) const DraftContentBanner(),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                child: Text(
                  'Short checklists to run through during design, code review, '
                  'or testing.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
              for (final RiskList list in withCheatsheets) ...<Widget>[
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
                  child: _ListSectionHeader(list: list),
                ),
                for (final Cheatsheet cheatsheet in list.cheatsheets)
                  Card(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 4,
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: ExpansionTile(
                      key: PageStorageKey<String>(cheatsheet.id),
                      leading: Icon(
                        Icons.sticky_note_2_outlined,
                        color: listAccent(context, list.id),
                      ),
                      title: Text(cheatsheet.title),
                      subtitle: Text(
                        '${cheatsheet.items.length} '
                        '${cheatsheet.items.length == 1 ? 'item' : 'items'} · '
                        'reviewed ${_formatDate(cheatsheet.lastReviewed)}',
                      ),
                      childrenPadding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
                      children: <Widget>[
                        for (final String item in cheatsheet.items)
                          ListTile(
                            leading: Icon(
                              Icons.check_circle_outline,
                              color: theme.colorScheme.primary,
                            ),
                            title: Text(item),
                          ),
                      ],
                    ),
                  ),
              ],
            ],
          );
        },
      ),
    );
  }
}

class _ListSectionHeader extends StatelessWidget {
  const _ListSectionHeader({required this.list});

  final RiskList list;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final Color accent = listAccent(context, list.id);

    return Row(
      children: <Widget>[
        Container(
          width: 36,
          height: 36,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: accent.withValues(alpha: 0.14),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(Icons.sticky_note_2_outlined, size: 20, color: accent),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            '${list.title} ${list.edition}',
            style: theme.textTheme.titleSmall,
          ),
        ),
        const SizedBox(width: 8),
        CountPill(
          '${list.cheatsheets.length} '
          '${list.cheatsheets.length == 1 ? 'sheet' : 'sheets'}',
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
