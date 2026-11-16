// Generates the SME content-review packet from the bundled content.
//
// Run from the project root:
//   dart run tool/generate_sme_review_packet.dart
//
// Output goes to docs/sme-review/. The packet is deterministic: regenerating
// it without changing assets/content/bundle.json produces identical files.

import 'dart:convert';
import 'dart:io';

import 'package:top_10_app/content/models.dart';

const String _bundlePath = 'assets/content/bundle.json';
const String _outputDir = 'docs/sme-review';

void main() {
  final File bundleFile = File(_bundlePath);
  if (!bundleFile.existsSync()) {
    stderr.writeln(
      'Cannot find $_bundlePath. Run this command from the project root.',
    );
    exitCode = 1;
    return;
  }

  final ContentBundle bundle = ContentBundle.fromJson(
    jsonDecode(bundleFile.readAsStringSync()) as Map<String, dynamic>,
  );
  final Directory output = Directory(_outputDir)..createSync(recursive: true);

  File('${output.path}/README.md').writeAsStringSync(_readme(bundle));
  for (final RiskList list in bundle.lists) {
    File('${output.path}/${list.id}.md')
        .writeAsStringSync(_listSheet(bundle, list));
  }
  File('${output.path}/sign-off.csv').writeAsStringSync(_signOffCsv(bundle));

  stdout.writeln(
    'Wrote ${output.path}/README.md, '
    '${bundle.lists.length} list sheets, and sign-off.csv '
    'for bundle ${bundle.bundleVersion}.',
  );
}

String _readme(ContentBundle bundle) {
  final StringBuffer out = StringBuffer()
    ..writeln('# OWASP Top 10 Pocket Guide — SME content review packet')
    ..writeln()
    ..writeln(
      'Generated from `assets/content/bundle.json` for bundle '
      '**${bundle.bundleVersion}** (schema ${bundle.schemaVersion}, '
      'status **${bundle.status}**). Do not edit the generated files by hand; '
      'change the bundle and run `dart run tool/generate_sme_review_packet.dart`.',
    )
    ..writeln()
    ..writeln('## Scope')
    ..writeln()
    ..writeln(
      'This packet covers every risk, quiz question and cheatsheet in the '
      'MVP bundle. Reviewers should confirm technical accuracy and alignment '
      'with the official OWASP edition cited for each list.',
    )
    ..writeln()
    ..writeln('## Coverage')
    ..writeln()
    ..writeln(
      '| List | Edition | Risks | Quiz questions | Cheatsheets | '
      'Risks with reviewer | License |',
    )
    ..writeln('| --- | --- | ---: | ---: | ---: | ---: | --- |');

  for (final RiskList list in bundle.lists) {
    final int reviewed = list.risks
        .where((Risk risk) => risk.reviewers.isNotEmpty)
        .length;
    out.writeln(
      '| ${_cell(list.title)} | ${_cell(list.edition)} | '
      '${list.risks.length} | ${list.quiz.length} | '
      '${list.cheatsheets.length} | $reviewed | ${_cell(list.license)} |',
    );
  }

  out
    ..writeln()
    ..writeln('## How to review')
    ..writeln()
    ..writeln(
      '1. Open the sheet for each list: '
      '${bundle.lists.map((RiskList list) => '[${list.family.toUpperCase()} '
          '${list.edition}](${list.id}.md)').join(', ')}.',
    )
    ..writeln(
      '2. For every risk, check the reviewer checklist and record a decision '
      '(approve, approve with edits, or reject).',
    )
    ..writeln(
      '3. Record decisions in `sign-off.csv` or the table below. Put the '
      'reviewer name and review date on every row you decide.',
    )
    ..writeln(
      '4. Send the completed CSV and any corrections back to the app '
      'maintainers. Corrections are applied to `bundle.json`, not to this '
      'packet.',
    )
    ..writeln();

  final bool hasLlm2026 = bundle.lists.any(
    (RiskList list) => list.family == 'llm' && list.edition == '2026',
  );
  if (hasLlm2026) {
    out
      ..writeln('## LLM 2026 source note')
      ..writeln()
      ..writeln(
        'OWASP has not yet published category pages for the 2026 LLM '
        'edition on `genai.owasp.org`. The LLM sheet therefore cites the '
        'edition landing page and gives section/page ranges from the official '
        'v1.0 PDF (August 2026). Reviewers should confirm titles and page '
        'ranges against that PDF; citations can be updated to category pages '
        'once OWASP publishes them.',
      )
      ..writeln();
  }

  out
    ..writeln('## Promotion from draft to final')
    ..writeln()
    ..writeln(
      'The bundle stays `status: "draft"` until the content validator and '
      'tests pass with these conditions:',
    )
    ..writeln()
    ..writeln('- every list has at least 10 risks and 5 quiz questions;')
    ..writeln(
      '- every risk has a non-empty `reviewers` list and a `lastReviewed` date;',
    )
    ..writeln('- every risk has at least one reference;')
    ..writeln(
      '- all code samples name a language and label, quiz answers are in '
      'range, and IDs are unique.',
    )
    ..writeln()
    ..writeln(
      'After the reviewer names and dates are added, update `status` and '
      '`bundleVersion` in `bundle.json`, then run `flutter analyze` and '
      '`flutter test`.',
    )
    ..writeln()
    ..writeln('## License and attribution')
    ..writeln()
    ..writeln(
      'Bundle content license: **${bundle.contentLicense}**. Each list '
      'records its own attribution; keep the attribution text with any '
      'reuse. The app source code is licensed under **GPL-3.0** (see '
      '`LICENSE`). OWASP marks are subject to the OWASP Foundation brand '
      'rules, separate from both licenses.',
    )
    ..writeln()
    ..writeln('## Sign-off')
    ..writeln()
    ..writeln('| List | Risk | Reviewer | Decision | Date | Comments |')
    ..writeln('| --- | --- | --- | --- | --- | --- |');

  for (final RiskList list in bundle.lists) {
    for (final Risk risk in list.risks) {
      out.writeln(
        '| ${list.family.toUpperCase()} ${_cell(list.edition)} | '
        '${_cell(risk.code)} — ${_cell(risk.title)} | | | | |',
      );
    }
  }

  return out.toString();
}

String _listSheet(ContentBundle bundle, RiskList list) {
  final StringBuffer out = StringBuffer()
    ..writeln('# ${list.title} ${list.edition} — SME review sheet')
    ..writeln()
    ..writeln('- List ID: `${list.id}`')
    ..writeln('- Year: ${list.year}')
    ..writeln('- License: ${list.license}')
    ..writeln('- Source: ${list.sourceUrl}')
    ..writeln('- Attribution: ${list.attribution}')
    ..writeln(
      '- Bundle: ${bundle.bundleVersion} (status ${bundle.status}, '
      'schema ${bundle.schemaVersion})',
    )
    ..writeln(
      '- Coverage: ${list.risks.length} risks, ${list.quiz.length} quiz '
      'questions, ${list.cheatsheets.length} cheatsheets',
    )
    ..writeln()
    ..writeln(
      'Review every section below. Record decisions in `sign-off.csv`; use '
      'the per-risk decision block for notes while reading.',
    )
    ..writeln();

  for (final Risk risk in list.risks) {
    out
      ..writeln('## ${risk.code} — ${risk.title}')
      ..writeln()
      ..writeln('- Risk ID: `${risk.id}`')
      ..writeln(
        '- Status: ${risk.reviewers.isEmpty ? '**Awaiting SME review**' : 'Reviewed by '
                  '${risk.reviewers.join(', ')}'}',
      )
      ..writeln('- Last reviewed: ${_date(risk.lastReviewed)}')
      ..writeln()
      ..writeln('### Summary')
      ..writeln()
      ..writeln(risk.summary)
      ..writeln()
      ..writeln('### Real-world example')
      ..writeln()
      ..writeln(risk.example)
      ..writeln()
      ..writeln('### Test for it')
      ..writeln()
      ..writeln(risk.testTip)
      ..writeln()
      ..writeln('### How to fix it')
      ..writeln()
      ..writeln(risk.fix)
      ..writeln();

    if (risk.codeSamples.isEmpty) {
      out
        ..writeln('### Code samples')
        ..writeln()
        ..writeln('_None in this bundle._')
        ..writeln();
    } else {
      out
        ..writeln('### Code samples')
        ..writeln();
      for (final CodeSample sample in risk.codeSamples) {
        out
          ..writeln('#### ${sample.label} (${sample.language})')
          ..writeln()
          ..writeln('````${sample.language}')
          ..writeln(sample.code.trimRight())
          ..writeln('````')
          ..writeln();
      }
    }

    final List<QuizQuestion> questions = list.quiz
        .where((QuizQuestion question) => question.riskId == risk.id)
        .toList(growable: false);
    if (questions.isNotEmpty) {
      out
        ..writeln('### Quiz')
        ..writeln();
      for (final QuizQuestion question in questions) {
        out
          ..writeln('#### ${question.id} (${question.difficulty})')
          ..writeln()
          ..writeln(question.prompt)
          ..writeln();
        for (int index = 0; index < question.options.length; index++) {
          final String marker = index == question.answerIndex
              ? ' **(correct)**'
              : '';
          out.writeln('${index + 1}. ${question.options[index]}$marker');
        }
        out
          ..writeln()
          ..writeln('Explanation: ${question.explanation}')
          ..writeln();
      }
    }

    out
      ..writeln('### References')
      ..writeln();
    for (final Reference reference in risk.references) {
      out.writeln('- [${reference.title}](${reference.url})');
    }
    out
      ..writeln()
      ..writeln('### Reviewer checklist')
      ..writeln()
      ..writeln(
        '- [ ] Category code and title match the official ${list.edition} '
        'wording.',
      )
      ..writeln(
        '- [ ] Summary, example, test tip and fix are technically accurate '
        'and current.',
      )
      ..writeln(
        '- [ ] Code samples are correct, minimal and demonstrate the '
        'described issue.',
      )
      ..writeln('- [ ] References resolve and cite the official OWASP source.')
      ..writeln(
        '- [ ] Quiz options, correct answer and explanation are correct.',
      )
      ..writeln(
        '- [ ] Wording is neutral, with no unsupported claims or sensitive data.',
      )
      ..writeln()
      ..writeln('### Decision')
      ..writeln()
      ..writeln('- [ ] Approve  - [ ] Approve with edits  - [ ] Reject')
      ..writeln()
      ..writeln('Reviewer: ____________________  Date: ____________')
      ..writeln()
      ..writeln('Comments:')
      ..writeln()
      ..writeln('---')
      ..writeln();
  }

  out
    ..writeln('## Cheatsheets')
    ..writeln();
  if (list.cheatsheets.isEmpty) {
    out.writeln('_None in this bundle._');
  } else {
    for (final Cheatsheet cheatsheet in list.cheatsheets) {
      out
        ..writeln('### ${cheatsheet.title}')
        ..writeln()
        ..writeln(
          '- ID: `${cheatsheet.id}` · last reviewed: '
          '${_date(cheatsheet.lastReviewed)}',
        )
        ..writeln();
      for (final String item in cheatsheet.items) {
        out.writeln('- $item');
      }
      out
        ..writeln()
        ..writeln('- [ ] Items are accurate and consistent with the list.')
        ..writeln('- [ ] Items are actionable and complete.')
        ..writeln();
    }
  }

  return out.toString();
}

String _signOffCsv(ContentBundle bundle) {
  final StringBuffer out = StringBuffer()
    ..writeln(
      'list_id,list_title,list_edition,risk_id,risk_code,risk_title,'
      'bundle_version,decision,reviewer,review_date,comments',
    );
  for (final RiskList list in bundle.lists) {
    for (final Risk risk in list.risks) {
      out.writeln(
        <String>[
          _csv(list.id),
          _csv(list.title),
          _csv(list.edition),
          _csv(risk.id),
          _csv(risk.code),
          _csv(risk.title),
          _csv(bundle.bundleVersion),
          '',
          '',
          '',
          '',
        ].join(','),
      );
    }
  }
  return out.toString();
}

String _date(DateTime date) {
  final String month = date.month.toString().padLeft(2, '0');
  final String day = date.day.toString().padLeft(2, '0');
  return '${date.year}-$month-$day';
}

String _cell(String value) => value.replaceAll('|', r'\|');

String _csv(String value) {
  if (value.contains(',') || value.contains('"') || value.contains('\n')) {
    return '"${value.replaceAll('"', '""')}"';
  }
  return value;
}
