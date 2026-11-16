import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../content/content_repository.dart';
import '../../content/models.dart';
import '../../content/providers.dart';
import '../../core/brand_icons.dart';
import '../../core/widgets.dart';

const String _appVersion = '1.0.0';

class AboutScreen extends ConsumerWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<ContentBundle> bundleAsync = ref.watch(
      contentBundleProvider,
    );

    return Scaffold(
      appBar: AppBar(title: const Text('About & licenses')),
      body: bundleAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (Object error, StackTrace stackTrace) {
          final List<String> errors = error is ContentUnavailableException
              ? error.errors
              : <String>[error.toString()];
          return ContentUnavailableView(errors: errors);
        },
        data: (ContentBundle bundle) => _buildContent(context, bundle),
      ),
    );
  }

  Widget _buildContent(BuildContext context, ContentBundle bundle) {
    final ThemeData theme = Theme.of(context);

    final ColorScheme scheme = theme.colorScheme;

    return ListView(
      padding: const EdgeInsets.only(bottom: 32),
      children: <Widget>[
        if (bundle.isDraft) const DraftContentBanner(),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: <Widget>[
                  const AppMark(size: 52),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          'OWASP Top 10 Pocket Guide',
                          style: theme.textTheme.titleLarge,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Version $_appVersion',
                          style: theme.textTheme.bodyMedium?.copyWith(
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
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          child: Text(
            'A study guide for the OWASP® Top 10 lists. This app works '
            'offline and stores progress only on this device.',
            style: theme.textTheme.bodyLarge?.copyWith(height: 1.5),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: const SectionHeader(
            title: 'Trademarks',
            icon: Icons.copyright_outlined,
          ),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'OWASP® and the OWASP Top 10 are trademarks or registered '
            'trademarks of the OWASP Foundation, Inc. The OWASP name and logo '
            'are used with permission for this project. Content is derived '
            'from OWASP materials under the licenses listed below.',
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: const SectionHeader(
            title: 'Content licenses',
            icon: Icons.description_outlined,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Bundle license: ${bundle.contentLicense}',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: scheme.onSurfaceVariant,
            ),
          ),
        ),
        const SizedBox(height: 12),
        for (final RiskList list in bundle.lists) ...<Widget>[
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Container(
                          width: 9,
                          height: 9,
                          decoration: BoxDecoration(
                            color: listAccent(context, list.id),
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          '${list.title} ${list.edition}',
                          style: theme.textTheme.titleSmall,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text('License: ${list.license}'),
                  const SizedBox(height: 4),
                  SelectableText('Source: ${list.sourceUrl}'),
                  const SizedBox(height: 4),
                  Text(list.attribution),
                  const SizedBox(height: 4),
                  Text(
                    'List last reviewed ${_formatDate(list.lastReviewed)}',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: const SectionHeader(
            title: 'Content licenses',
            icon: Icons.info_outline,
          ),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Every included list is licensed CC BY-SA 4.0. Each edition has '
            'been condensed and modified for this app, and its attribution is '
            'kept with the list above.',
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: const SectionHeader(
            title: 'Source code license',
            icon: Icons.code,
          ),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'App source code is licensed under the GNU General Public License '
            'v3.0 (GPL-3.0). It is separate from the content licenses above. '
            'The full license text ships with the source in the LICENSE file.',
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: const SectionHeader(
            title: 'Privacy',
            icon: Icons.lock_outline,
          ),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'This app has no accounts, no analytics, and no network access. It '
            'requests no Android permissions. Read state, bookmarks, and quiz '
            'results are stored locally and can be erased from Progress, then '
            'Reset progress.',
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: const SectionHeader(
            title: 'Bundle',
            icon: Icons.inventory_2_outlined,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text('Schema ${bundle.schemaVersion}'),
              Text('Bundle ${bundle.bundleVersion}'),
              Text('Generated ${_formatDate(bundle.generatedAt)}'),
            ],
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
