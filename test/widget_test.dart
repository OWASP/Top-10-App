import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:top_10_app/content/models.dart';
import 'package:top_10_app/content/providers.dart';
import 'package:top_10_app/core/search_query.dart';
import 'package:top_10_app/core/widgets.dart';
import 'package:top_10_app/data/providers.dart';
import 'package:top_10_app/features/learn/learn_screen.dart';

import 'fixtures/test_bundle.dart';

void main() {
  testWidgets('Learn screen lists risks and filters them', (
    WidgetTester tester,
  ) async {
    final ContentBundle bundle = buildTestBundle();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          contentBundleProvider.overrideWith((Ref ref) async => bundle),
          readRiskIdsProvider.overrideWith(
            (Ref ref) => Stream<Set<String>>.value(<String>{}),
          ),
        ],
        child: const MaterialApp(home: LearnScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Broken Access Control'), findsOneWidget);
    expect(find.text('API'), findsOneWidget);
    expect(find.text('2023'), findsOneWidget);
    expect(find.byType(DraftContentBanner), findsOneWidget);
    expect(find.byType(EmptyState), findsNothing);

    await tester.enterText(find.byType(TextField), 'zzz-no-match');
    await tester.pump();

    expect(find.byType(EmptyState), findsOneWidget);
    expect(find.textContaining('No risks match'), findsOneWidget);
  });

  testWidgets('search treats metacharacters literally and caps pasted text', (
    WidgetTester tester,
  ) async {
    final ContentBundle bundle = buildTestBundle();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          contentBundleProvider.overrideWith((Ref ref) async => bundle),
          readRiskIdsProvider.overrideWith(
            (Ref ref) => Stream<Set<String>>.value(<String>{}),
          ),
        ],
        child: const MaterialApp(home: LearnScreen()),
      ),
    );
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byType(TextField),
      "' OR 1=1; DROP TABLE risks; -- <script>alert(1)</script>",
    );
    await tester.pump();
    expect(find.byType(EmptyState), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'res.json');
    await tester.pump();
    expect(find.text('Broken Access Control'), findsOneWidget);
    expect(find.byType(EmptyState), findsNothing);

    await tester.enterText(find.byType(TextField), 'x' * 500);
    await tester.pump();
    final TextField field = tester.widget<TextField>(find.byType(TextField));
    expect(field.controller!.text.length, maxSearchQueryLength);
    expect(find.byType(EmptyState), findsOneWidget);
  });
}
