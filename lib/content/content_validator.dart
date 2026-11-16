import 'models.dart';

/// Validates a parsed content bundle before it is shown to users.
///
/// Rules come from the hardened plan (Appendix A): unique IDs, quiz answers in
/// range, quiz links resolve, every risk has a citation and review date, code
/// samples name their language and label, and no HTML in prose fields.
class ContentValidator {
  const ContentValidator._();

  static const String supportedSchemaVersion = '1.0.0';
  static const int maxBundleBytes = 2 * 1024 * 1024;

  static final RegExp _htmlTag = RegExp(r'<[a-zA-Z!/]');

  static List<String> validate(ContentBundle bundle) {
    final errors = <String>[];

    if (bundle.schemaVersion != supportedSchemaVersion) {
      errors.add(
        'Unsupported schemaVersion "${bundle.schemaVersion}" '
        '(expected $supportedSchemaVersion).',
      );
    }
    if (bundle.lists.isEmpty) {
      errors.add('Bundle contains no lists.');
    }

    final listIds = <String>{};
    final riskIds = <String>{};
    final questionIds = <String>{};
    final cheatsheetIds = <String>{};

    for (final list in bundle.lists) {
      final prefix = 'list ${list.id}';
      if (!listIds.add(list.id)) {
        errors.add('Duplicate list id "${list.id}".');
      }
      if (list.license.trim().isEmpty) {
        errors.add('$prefix has no license.');
      }
      if (list.attribution.trim().isEmpty) {
        errors.add('$prefix has no attribution.');
      }
      if (bundle.status == 'final' && list.risks.isEmpty) {
        errors.add('$prefix has no risks in a final bundle.');
      }
      if (bundle.status == 'final' && list.risks.length < 10) {
        errors.add('$prefix has fewer than 10 risks in a final bundle.');
      }
      if (bundle.status == 'final' && list.quiz.length < 5) {
        errors.add(
          '$prefix has fewer than five quiz questions in a final bundle.',
        );
      }

      final listRiskIds = <String>{};
      for (final risk in list.risks) {
        final riskPrefix = '$prefix / risk ${risk.id}';
        if (!riskIds.add(risk.id)) {
          errors.add('Duplicate risk id "${risk.id}".');
        }
        listRiskIds.add(risk.id);

        if (risk.references.isEmpty) {
          errors.add('$riskPrefix has no references.');
        }
        if (bundle.status == 'final' && risk.reviewers.isEmpty) {
          errors.add('$riskPrefix has no reviewer in a final bundle.');
        }
        for (final sample in risk.codeSamples) {
          if (sample.language.trim().isEmpty || sample.label.trim().isEmpty) {
            errors.add('$riskPrefix has a code sample without language/label.');
          }
        }
        for (final entry in <String, String>{
          'title': risk.title,
          'summary': risk.summary,
          'example': risk.example,
          'testTip': risk.testTip,
          'fix': risk.fix,
        }.entries) {
          if (_htmlTag.hasMatch(entry.value)) {
            errors.add('$riskPrefix has HTML in "${entry.key}".');
          }
        }
      }

      for (final question in list.quiz) {
        final questionPrefix = '$prefix / quiz ${question.id}';
        if (!questionIds.add(question.id)) {
          errors.add('Duplicate quiz question id "${question.id}".');
        }
        if (question.options.length < 2) {
          errors.add('$questionPrefix has fewer than two options.');
        }
        if (question.answerIndex < 0 ||
            question.answerIndex >= question.options.length) {
          errors.add('$questionPrefix has answerIndex out of range.');
        }
        if (!listRiskIds.contains(question.riskId)) {
          errors.add(
            '$questionPrefix links to unknown risk "${question.riskId}".',
          );
        }
        if (_htmlTag.hasMatch(question.prompt) ||
            _htmlTag.hasMatch(question.explanation)) {
          errors.add('$questionPrefix has HTML in its text.');
        }
      }

      for (final cheatsheet in list.cheatsheets) {
        if (!cheatsheetIds.add(cheatsheet.id)) {
          errors.add('Duplicate cheatsheet id "${cheatsheet.id}".');
        }
        if (cheatsheet.items.isEmpty) {
          errors.add('$prefix / cheatsheet ${cheatsheet.id} has no items.');
        }
      }
    }

    return errors;
  }
}
