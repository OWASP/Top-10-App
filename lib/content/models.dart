/// Immutable models for the bundled OWASP content.
///
/// The JSON shape is documented in
/// `~/projects/OWASP/Top10Plan/Top10-Pocket-Guide-Plan-v2.md` (Appendix A).
library;

/// Thrown when a content field is missing or has the wrong type.
class ContentFormatException implements Exception {
  const ContentFormatException(this.message);

  final String message;

  @override
  String toString() => 'ContentFormatException: $message';
}

class ContentBundle {
  const ContentBundle({
    required this.schemaVersion,
    required this.bundleVersion,
    required this.generatedAt,
    required this.contentLicense,
    required this.status,
    required this.lists,
  });

  factory ContentBundle.fromJson(Map<String, dynamic> json) {
    return ContentBundle(
      schemaVersion: _string(json, 'schemaVersion'),
      bundleVersion: _string(json, 'bundleVersion'),
      generatedAt: _date(json, 'generatedAt'),
      contentLicense: _string(json, 'contentLicense'),
      status: _string(json, 'status'),
      lists: _objectList(json, 'lists', RiskList.fromJson),
    );
  }

  final String schemaVersion;
  final String bundleVersion;
  final DateTime generatedAt;
  final String contentLicense;

  /// `draft` while content is under review; `final` for release bundles.
  final String status;
  final List<RiskList> lists;

  bool get isDraft => status != 'final';

  RiskList? listById(String id) {
    for (final list in lists) {
      if (list.id == id) return list;
    }
    return null;
  }
}

class RiskList {
  const RiskList({
    required this.id,
    required this.family,
    required this.title,
    required this.edition,
    required this.year,
    required this.sourceUrl,
    required this.license,
    required this.attribution,
    required this.lastReviewed,
    required this.risks,
    required this.quiz,
    required this.cheatsheets,
  });

  factory RiskList.fromJson(Map<String, dynamic> json) {
    return RiskList(
      id: _string(json, 'id'),
      family: _string(json, 'family'),
      title: _string(json, 'title'),
      edition: _string(json, 'edition'),
      year: _int(json, 'year'),
      sourceUrl: _string(json, 'sourceUrl'),
      license: _string(json, 'license'),
      attribution: _string(json, 'attribution'),
      lastReviewed: _date(json, 'lastReviewed'),
      risks: _objectList(json, 'risks', Risk.fromJson),
      quiz: _objectList(json, 'quiz', QuizQuestion.fromJson),
      cheatsheets: _objectList(json, 'cheatsheets', Cheatsheet.fromJson),
    );
  }

  final String id;
  final String family;
  final String title;
  final String edition;
  final int year;
  final String sourceUrl;
  final String license;
  final String attribution;
  final DateTime lastReviewed;
  final List<Risk> risks;
  final List<QuizQuestion> quiz;
  final List<Cheatsheet> cheatsheets;

  Risk? riskById(String id) {
    for (final risk in risks) {
      if (risk.id == id) return risk;
    }
    return null;
  }
}

class Risk {
  const Risk({
    required this.id,
    required this.code,
    required this.title,
    required this.summary,
    required this.example,
    required this.codeSamples,
    required this.testTip,
    required this.fix,
    required this.references,
    required this.reviewers,
    required this.lastReviewed,
  });

  factory Risk.fromJson(Map<String, dynamic> json) {
    return Risk(
      id: _string(json, 'id'),
      code: _string(json, 'code'),
      title: _string(json, 'title'),
      summary: _string(json, 'summary'),
      example: _string(json, 'example'),
      codeSamples: _objectList(json, 'codeSamples', CodeSample.fromJson),
      testTip: _string(json, 'testTip'),
      fix: _string(json, 'fix'),
      references: _objectList(json, 'references', Reference.fromJson),
      reviewers: _stringList(json, 'reviewers'),
      lastReviewed: _date(json, 'lastReviewed'),
    );
  }

  final String id;
  final String code;
  final String title;
  final String summary;
  final String example;
  final List<CodeSample> codeSamples;
  final String testTip;
  final String fix;
  final List<Reference> references;
  final List<String> reviewers;
  final DateTime lastReviewed;
}

class CodeSample {
  const CodeSample({
    required this.language,
    required this.label,
    required this.code,
  });

  factory CodeSample.fromJson(Map<String, dynamic> json) {
    return CodeSample(
      language: _string(json, 'language'),
      label: _string(json, 'label'),
      code: _string(json, 'code'),
    );
  }

  final String language;
  final String label;
  final String code;
}

class Reference {
  const Reference({required this.title, required this.url});

  factory Reference.fromJson(Map<String, dynamic> json) {
    return Reference(title: _string(json, 'title'), url: _string(json, 'url'));
  }

  final String title;
  final String url;
}

class QuizQuestion {
  const QuizQuestion({
    required this.id,
    required this.prompt,
    required this.options,
    required this.answerIndex,
    required this.explanation,
    required this.riskId,
    required this.difficulty,
  });

  factory QuizQuestion.fromJson(Map<String, dynamic> json) {
    return QuizQuestion(
      id: _string(json, 'id'),
      prompt: _string(json, 'prompt'),
      options: _stringList(json, 'options'),
      answerIndex: _int(json, 'answerIndex'),
      explanation: _string(json, 'explanation'),
      riskId: _string(json, 'riskId'),
      difficulty: _string(json, 'difficulty'),
    );
  }

  final String id;
  final String prompt;
  final List<String> options;
  final int answerIndex;
  final String explanation;
  final String riskId;
  final String difficulty;
}

class Cheatsheet {
  const Cheatsheet({
    required this.id,
    required this.title,
    required this.items,
    required this.lastReviewed,
  });

  factory Cheatsheet.fromJson(Map<String, dynamic> json) {
    return Cheatsheet(
      id: _string(json, 'id'),
      title: _string(json, 'title'),
      items: _stringList(json, 'items'),
      lastReviewed: _date(json, 'lastReviewed'),
    );
  }

  final String id;
  final String title;
  final List<String> items;
  final DateTime lastReviewed;
}

String _string(Map<String, dynamic> json, String key) {
  final value = json[key];
  if (value is! String || value.trim().isEmpty) {
    throw ContentFormatException('Expected a non-empty string for "$key"');
  }
  return value;
}

int _int(Map<String, dynamic> json, String key) {
  final value = json[key];
  if (value is! int) {
    throw ContentFormatException('Expected an integer for "$key"');
  }
  return value;
}

DateTime _date(Map<String, dynamic> json, String key) {
  final raw = _string(json, key);
  final parsed = DateTime.tryParse(raw);
  if (parsed == null) {
    throw ContentFormatException('Expected an ISO-8601 date for "$key"');
  }
  return parsed;
}

List<String> _stringList(Map<String, dynamic> json, String key) {
  final value = json[key];
  if (value is! List) {
    throw ContentFormatException('Expected a list for "$key"');
  }
  return value
      .map((item) {
        if (item is! String || item.trim().isEmpty) {
          throw ContentFormatException('Expected non-empty strings in "$key"');
        }
        return item;
      })
      .toList(growable: false);
}

List<T> _objectList<T>(
  Map<String, dynamic> json,
  String key,
  T Function(Map<String, dynamic>) parse,
) {
  final value = json[key];
  if (value is! List) {
    throw ContentFormatException('Expected a list for "$key"');
  }
  return value
      .map((item) {
        if (item is! Map<String, dynamic>) {
          throw ContentFormatException('Expected objects in "$key"');
        }
        return parse(item);
      })
      .toList(growable: false);
}
