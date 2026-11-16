import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:top_10_app/core/search_query.dart';

void main() {
  group('sanitizeSearchQuery', () {
    test('trims and collapses whitespace', () {
      expect(sanitizeSearchQuery('  broken \n\t access  '), 'broken access');
    });

    test('replaces control and bidi characters with spaces', () {
      expect(sanitizeSearchQuery('pass\u0000word'), 'pass word');
      expect(sanitizeSearchQuery('${String.fromCharCode(0x202E)}evil'), 'evil');
      expect(sanitizeSearchQuery('a${String.fromCharCode(0x200B)}b'), 'a b');
    });

    test('treats SQL, HTML and shell metacharacters as literal text', () {
      const String payload =
          "' OR 1=1; DROP TABLE risks; -- <script>alert(1)</script> \$(id)";
      expect(sanitizeSearchQuery(payload), payload);
    });

    test('returns an empty string for blank input', () {
      expect(sanitizeSearchQuery('   '), '');
      expect(sanitizeSearchQuery(''), '');
    });

    test('caps long input without splitting a surrogate pair', () {
      final String capped = sanitizeSearchQuery('😀' * 200);
      expect(capped.runes.length, maxSearchQueryLength);
      expect(capped, '😀' * maxSearchQueryLength);
    });
  });

  group('SearchQueryInputFormatter', () {
    const SearchQueryInputFormatter formatter = SearchQueryInputFormatter();

    TextEditingValue apply(String text, {int? offset}) {
      return formatter.formatEditUpdate(
        TextEditingValue.empty,
        TextEditingValue(
          text: text,
          selection: TextSelection.collapsed(offset: offset ?? text.length),
        ),
      );
    }

    test('keeps spaces the user types between words', () {
      final TextEditingValue result = apply('broken access ');
      expect(result.text, 'broken access ');
      expect(result.selection.baseOffset, 'broken access '.length);
    });

    test('replaces invisible characters and keeps the caret in range', () {
      final TextEditingValue result = apply('a\u0000b', offset: 3);
      expect(result.text, 'a b');
      expect(result.selection.baseOffset, lessThanOrEqualTo(3));
      expect(
        result.selection.baseOffset,
        lessThanOrEqualTo(result.text.length),
      );
    });

    test('truncates pasted text to the maximum length', () {
      final TextEditingValue result = apply('x' * 500);
      expect(result.text.length, maxSearchQueryLength);
      expect(result.selection.baseOffset, maxSearchQueryLength);
    });
  });
}
