import 'package:flutter_test/flutter_test.dart';
import 'package:top_10_app/content/content_validator.dart';
import 'package:top_10_app/content/models.dart';

import '../fixtures/test_bundle.dart';

void main() {
  test('accepts a well-formed bundle', () {
    final ContentBundle bundle = buildTestBundle();
    expect(ContentValidator.validate(bundle), isEmpty);
  });

  test('rejects duplicate risk ids', () {
    final ContentBundle bundle = ContentBundle(
      schemaVersion: '1.0.0',
      bundleVersion: 'test',
      generatedAt: testDate,
      contentLicense: 'CC-BY-SA-4.0',
      status: 'draft',
      lists: <RiskList>[
        buildList(risks: <Risk>[buildRisk(), buildRisk()]),
      ],
    );

    expect(
      ContentValidator.validate(bundle),
      contains('Duplicate risk id "web-2025-A01".'),
    );
  });

  test('rejects an out-of-range answer index', () {
    final ContentBundle bundle = ContentBundle(
      schemaVersion: '1.0.0',
      bundleVersion: 'test',
      generatedAt: testDate,
      contentLicense: 'CC-BY-SA-4.0',
      status: 'draft',
      lists: <RiskList>[
        buildList(quiz: <QuizQuestion>[buildQuestion(answerIndex: 5)]),
      ],
    );

    expect(
      ContentValidator.validate(bundle).join(' '),
      contains('answerIndex out of range'),
    );
  });

  test('rejects a quiz that links to an unknown risk', () {
    final ContentBundle bundle = ContentBundle(
      schemaVersion: '1.0.0',
      bundleVersion: 'test',
      generatedAt: testDate,
      contentLicense: 'CC-BY-SA-4.0',
      status: 'draft',
      lists: <RiskList>[
        buildList(quiz: <QuizQuestion>[buildQuestion(riskId: 'missing-risk')]),
      ],
    );

    expect(
      ContentValidator.validate(bundle).join(' '),
      contains('links to unknown risk "missing-risk"'),
    );
  });

  test('rejects a risk without references', () {
    final ContentBundle bundle = ContentBundle(
      schemaVersion: '1.0.0',
      bundleVersion: 'test',
      generatedAt: testDate,
      contentLicense: 'CC-BY-SA-4.0',
      status: 'draft',
      lists: <RiskList>[
        buildList(risks: <Risk>[buildRisk(references: const <Reference>[])]),
      ],
    );

    expect(
      ContentValidator.validate(bundle).join(' '),
      contains('has no references'),
    );
  });

  test('rejects HTML in prose', () {
    final ContentBundle bundle = ContentBundle(
      schemaVersion: '1.0.0',
      bundleVersion: 'test',
      generatedAt: testDate,
      contentLicense: 'CC-BY-SA-4.0',
      status: 'draft',
      lists: <RiskList>[
        buildList(
          risks: <Risk>[buildRisk(summary: '<script>alert(1)</script>')],
        ),
      ],
    );

    expect(
      ContentValidator.validate(bundle).join(' '),
      contains('has HTML in "summary"'),
    );
  });

  test('final bundles may not ship empty lists', () {
    final ContentBundle bundle = ContentBundle(
      schemaVersion: '1.0.0',
      bundleVersion: 'test',
      generatedAt: testDate,
      contentLicense: 'CC-BY-SA-4.0',
      status: 'final',
      lists: <RiskList>[buildList(risks: <Risk>[])],
    );

    expect(
      ContentValidator.validate(bundle).join(' '),
      contains('has no risks in a final bundle'),
    );
  });

  test('rejects an unsupported schema version', () {
    final ContentBundle bundle = ContentBundle(
      schemaVersion: '2.0.0',
      bundleVersion: 'test',
      generatedAt: testDate,
      contentLicense: 'CC-BY-SA-4.0',
      status: 'draft',
      lists: <RiskList>[buildList()],
    );

    expect(
      ContentValidator.validate(bundle).join(' '),
      contains('Unsupported schemaVersion "2.0.0"'),
    );
  });
}
