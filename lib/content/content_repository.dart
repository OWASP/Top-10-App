import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'content_validator.dart';
import 'models.dart';

/// Raised when the bundle cannot be loaded or is not safe to display.
class ContentUnavailableException implements Exception {
  const ContentUnavailableException(this.errors);

  final List<String> errors;

  @override
  String toString() => 'ContentUnavailableException: ${errors.join(' ')}';
}

abstract interface class ContentRepository {
  Future<ContentBundle> load();
}

/// Loads the bundled JSON from Flutter assets, validates it, and fails closed
/// on malformed or unreviewed content.
class AssetContentRepository implements ContentRepository {
  AssetContentRepository({
    AssetBundle? bundle,
    this.assetPath = 'assets/content/bundle.json',
  }) : _bundle = bundle ?? rootBundle;

  final AssetBundle _bundle;
  final String assetPath;

  @override
  Future<ContentBundle> load() async {
    final raw = await _bundle.loadString(assetPath);

    if (utf8.encode(raw).length > ContentValidator.maxBundleBytes) {
      throw const ContentUnavailableException([
        'Content bundle exceeds the 2 MB budget.',
      ]);
    }

    final ContentBundle bundle;
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map<String, dynamic>) {
        throw const ContentFormatException('Bundle root must be an object.');
      }
      bundle = ContentBundle.fromJson(decoded);
    } on FormatException catch (error) {
      throw ContentUnavailableException([
        'Content bundle is not valid JSON: ${error.message}',
      ]);
    } on ContentFormatException catch (error) {
      throw ContentUnavailableException([error.message]);
    }

    final errors = ContentValidator.validate(bundle);
    if (errors.isNotEmpty) {
      throw ContentUnavailableException(errors);
    }

    // Draft content is allowed only while developing; a release build must
    // never ship unreviewed material.
    if (kReleaseMode && bundle.isDraft) {
      throw const ContentUnavailableException([
        'Draft content cannot be shown in a release build.',
      ]);
    }

    return bundle;
  }
}
