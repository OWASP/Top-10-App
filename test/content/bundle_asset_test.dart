import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:top_10_app/content/content_validator.dart';
import 'package:top_10_app/content/models.dart';

void main() {
  test('bundled content parses, validates, and covers every shipped list', () {
    final File file = File('assets/content/bundle.json');
    expect(file.existsSync(), isTrue, reason: 'bundle asset is missing');

    final ContentBundle bundle = ContentBundle.fromJson(
      jsonDecode(file.readAsStringSync()) as Map<String, dynamic>,
    );

    expect(ContentValidator.validate(bundle), isEmpty);

    final RiskList web = bundle.listById('web-2025')!;
    expect(web.risks, hasLength(10));
    expect(web.quiz, hasLength(5));
    expect(web.cheatsheets, isNotEmpty);
    expect(web.risks.map((Risk risk) => risk.code).toSet(), <String>{
      for (int i = 1; i <= 10; i++) 'A${i.toString().padLeft(2, '0')}',
    });
    for (final Risk risk in web.risks) {
      expect(risk.references, isNotEmpty, reason: risk.id);
    }

    final RiskList api = bundle.listById('api-2023')!;
    expect(api.risks, hasLength(10));
    expect(api.quiz, hasLength(5));
    expect(api.cheatsheets, isNotEmpty);
    expect(api.risks.map((Risk risk) => risk.code).toSet(), <String>{
      for (int i = 1; i <= 10; i++) 'API$i',
    });
    for (final Risk risk in api.risks) {
      expect(risk.references, isNotEmpty, reason: risk.id);
      expect(risk.codeSamples, hasLength(2), reason: risk.id);
    }

    final RiskList llm = bundle.listById('llm-2026')!;
    expect(llm.risks, hasLength(10));
    expect(llm.quiz, hasLength(5));
    expect(llm.cheatsheets, isNotEmpty);
    expect(llm.risks.map((Risk risk) => risk.code).toSet(), <String>{
      for (int i = 1; i <= 10; i++) 'LLM${i.toString().padLeft(2, '0')}',
    });
    for (final Risk risk in llm.risks) {
      expect(risk.references, isNotEmpty, reason: risk.id);
      expect(risk.codeSamples, hasLength(2), reason: risk.id);
    }

    final RiskList agentic = bundle.listById('agentic-skills-2026')!;
    expect(agentic.risks, hasLength(10));
    expect(agentic.quiz, hasLength(5));
    expect(agentic.cheatsheets, isNotEmpty);
    expect(agentic.risks.map((Risk risk) => risk.code).toSet(), <String>{
      for (int i = 1; i <= 10; i++) 'AST${i.toString().padLeft(2, '0')}',
    });
    for (final Risk risk in agentic.risks) {
      expect(risk.references, isNotEmpty, reason: risk.id);
      expect(risk.codeSamples, hasLength(2), reason: risk.id);
    }

    final RiskList mcp = bundle.listById('mcp-2025')!;
    expect(mcp.risks, hasLength(10));
    expect(mcp.quiz, hasLength(5));
    expect(mcp.cheatsheets, isNotEmpty);
    expect(mcp.risks.map((Risk risk) => risk.code).toSet(), <String>{
      for (int i = 1; i <= 10; i++) 'MCP${i.toString().padLeft(2, '0')}',
    });
    for (final Risk risk in mcp.risks) {
      expect(risk.references, isNotEmpty, reason: risk.id);
      expect(risk.codeSamples, hasLength(2), reason: risk.id);
    }

    final RiskList agenticApps = bundle.listById('agentic-applications-2026')!;
    expect(agenticApps.risks, hasLength(10));
    expect(agenticApps.quiz, hasLength(5));
    expect(agenticApps.cheatsheets, isNotEmpty);
    expect(agenticApps.risks.map((Risk risk) => risk.code).toSet(), <String>{
      for (int i = 1; i <= 10; i++) 'ASI${i.toString().padLeft(2, '0')}',
    });
    for (final Risk risk in agenticApps.risks) {
      expect(risk.references, isNotEmpty, reason: risk.id);
      expect(risk.codeSamples, hasLength(2), reason: risk.id);
    }

    final List<String> listIds = bundle.lists
        .map((RiskList list) => list.id)
        .toList();
    expect(
      listIds.sublist(listIds.length - 2),
      <String>['agentic-skills-2026', 'agentic-applications-2026'],
      reason:
          'The two agentic chips must stay last so they share a row in both '
          'the 2-column and 3-column filter layouts.',
    );
  });
}
