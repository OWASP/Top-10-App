import 'package:top_10_app/content/models.dart';

final DateTime testDate = DateTime.utc(2026, 10, 21);

ContentBundle buildTestBundle() {
  return ContentBundle(
    schemaVersion: '1.0.0',
    bundleVersion: 'test-1',
    generatedAt: testDate,
    contentLicense: 'CC-BY-SA-4.0',
    status: 'draft',
    lists: <RiskList>[
      buildList(
        id: 'web-2025',
        risks: <Risk>[buildRisk()],
        quiz: <QuizQuestion>[buildQuestion()],
        cheatsheets: <Cheatsheet>[
          Cheatsheet(
            id: 'web-2025-cheat-01',
            title: 'Access control checks',
            items: const <String>['Check ownership on every request'],
            lastReviewed: testDate,
          ),
        ],
      ),
      buildList(
        id: 'api-2023',
        family: 'api',
        title: 'OWASP API Security Top 10',
        edition: '2023',
        risks: <Risk>[],
        quiz: <QuizQuestion>[],
        cheatsheets: <Cheatsheet>[],
      ),
    ],
  );
}

RiskList buildList({
  String id = 'web-2025',
  String family = 'web',
  String title = 'OWASP Top 10',
  String edition = '2025',
  List<Risk>? risks,
  List<QuizQuestion>? quiz,
  List<Cheatsheet>? cheatsheets,
}) {
  return RiskList(
    id: id,
    family: family,
    title: title,
    edition: edition,
    year: 2025,
    sourceUrl: 'https://owasp.org/Top10/2025/',
    license: 'CC-BY-SA-4.0',
    attribution: 'OWASP Top 10:2025, OWASP Foundation, CC BY-SA 4.0.',
    lastReviewed: testDate,
    risks: risks ?? <Risk>[buildRisk()],
    quiz: quiz ?? <QuizQuestion>[],
    cheatsheets: cheatsheets ?? <Cheatsheet>[],
  );
}

Risk buildRisk({
  String id = 'web-2025-A01',
  String summary = 'Users act outside their intended permissions.',
  List<Reference>? references,
}) {
  return Risk(
    id: id,
    code: 'A01',
    title: 'Broken Access Control',
    summary: summary,
    example: 'Changing an object ID shows another customer record.',
    codeSamples: const <CodeSample>[
      CodeSample(
        language: 'javascript',
        label: 'Vulnerable',
        code: 'res.json(db.invoice(req.params.id));',
      ),
    ],
    testTip: 'Swap object IDs between two accounts.',
    fix: 'Deny by default and enforce ownership on the server.',
    references:
        references ??
        const <Reference>[
          Reference(
            title: 'OWASP Top 10:2025 — A01',
            url: 'https://owasp.org/Top10/2025/A01_2025-Broken_Access_Control/',
          ),
        ],
    reviewers: const <String>['security-sme'],
    lastReviewed: testDate,
  );
}

QuizQuestion buildQuestion({
  String id = 'web-2025-q01',
  List<String> options = const <String>['Injection', 'Broken Access Control'],
  int answerIndex = 1,
  String riskId = 'web-2025-A01',
}) {
  return QuizQuestion(
    id: id,
    prompt: 'Changing an object ID exposes another user data. Which category?',
    options: options,
    answerIndex: answerIndex,
    explanation: 'The server did not check object ownership.',
    riskId: riskId,
    difficulty: 'easy',
  );
}
