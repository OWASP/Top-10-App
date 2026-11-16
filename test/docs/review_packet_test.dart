import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:top_10_app/content/models.dart';

void main() {
  test('SME review packet covers every risk and matches the bundle', () {
    final ContentBundle bundle = ContentBundle.fromJson(
      jsonDecode(File('assets/content/bundle.json').readAsStringSync())
          as Map<String, dynamic>,
    );

    final File readme = File('docs/sme-review/README.md');
    expect(readme.existsSync(), isTrue, reason: 'review packet README missing');
    expect(readme.readAsStringSync(), contains(bundle.bundleVersion));

    final int riskCount = bundle.lists.fold<int>(
      0,
      (int total, RiskList list) => total + list.risks.length,
    );
    final List<String> csv = File('docs/sme-review/sign-off.csv')
        .readAsLinesSync();
    expect(csv, hasLength(riskCount + 1), reason: 'header plus one row/risk');

    for (final RiskList list in bundle.lists) {
      final File sheet = File('docs/sme-review/${list.id}.md');
      expect(sheet.existsSync(), isTrue, reason: 'missing sheet ${list.id}');
      final String text = sheet.readAsStringSync();

      for (final Risk risk in list.risks) {
        expect(
          text,
          contains('## ${risk.code} — ${risk.title}'),
          reason: 'missing heading for ${risk.id}',
        );
        expect(text, contains(risk.id));
        for (final Reference reference in risk.references) {
          expect(text, contains(reference.url), reason: risk.id);
        }
      }
      for (final QuizQuestion question in list.quiz) {
        expect(text, contains(question.id));
      }
      for (final Cheatsheet cheatsheet in list.cheatsheets) {
        expect(text, contains(cheatsheet.id));
      }
    }
  });
}
