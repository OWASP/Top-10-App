import 'package:flutter/services.dart';

/// Longest search string accepted from the field.
///
/// Searching is an in-memory substring scan over the bundled list, so a cap
/// keeps a pasted wall of text from wasting work on every keystroke.
const int maxSearchQueryLength = 120;

/// Control characters and invisible format marks that have no place in a
/// search string. They are replaced with a space so words stay separated.
///
/// This covers C0/C1 controls, zero-width space, bidi marks and embeddings,
/// invisible operators, bidi isolates and the byte-order mark. Zero-width
/// non-joiner and joiner are deliberately kept because they are meaningful in
/// some scripts and emoji sequences.
final RegExp _invisibleCharacters = _buildInvisiblePattern();

RegExp _buildInvisiblePattern() {
  const List<(int, int)> ranges = <(int, int)>[
    (0x0000, 0x001F),
    (0x007F, 0x009F),
    (0x200B, 0x200B),
    (0x200E, 0x200F),
    (0x202A, 0x202E),
    (0x2060, 0x2064),
    (0x2066, 0x206F),
    (0xFEFF, 0xFEFF),
  ];
  final StringBuffer buffer = StringBuffer('[');
  for (final (int start, int end) in ranges) {
    buffer.write(String.fromCharCode(start));
    if (end != start) {
      buffer
        ..write('-')
        ..write(String.fromCharCode(end));
    }
  }
  buffer.write(']');
  return RegExp(buffer.toString());
}

/// Normalises search input before it is matched.
///
/// Search text is only ever compared with [String.contains] against bundled
/// content, so there is no query language to escape: SQL, HTML and shell
/// metacharacters stay literal text. The work here is input hygiene, not
/// escaping:
///
/// * control and invisible characters are replaced with spaces;
/// * repeated whitespace is collapsed and the result is trimmed;
/// * the string is capped at [maxSearchQueryLength] code points without
///   splitting a surrogate pair.
String sanitizeSearchQuery(String raw) {
  final String cleaned = raw
      .replaceAll(_invisibleCharacters, ' ')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();
  if (cleaned.runes.length <= maxSearchQueryLength) return cleaned;
  return String.fromCharCodes(cleaned.runes.take(maxSearchQueryLength));
}

/// Applies input hygiene while the user types or pastes.
///
/// This deliberately does not trim or collapse spaces: doing that on every
/// keystroke would swallow the space the user types between words. The query
/// used for matching is normalised separately by [sanitizeSearchQuery].
class SearchQueryInputFormatter extends TextInputFormatter {
  const SearchQueryInputFormatter();

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final String cleaned = _cleanFieldText(newValue.text);
    if (cleaned == newValue.text) return newValue;

    final int rawOffset = newValue.selection.baseOffset;
    int offset = cleaned.length;
    if (rawOffset >= 0) {
      final int clamped = rawOffset.clamp(0, newValue.text.length);
      offset = _cleanFieldText(newValue.text.substring(0, clamped)).length;
    }

    return TextEditingValue(
      text: cleaned,
      selection: TextSelection.collapsed(
        offset: offset.clamp(0, cleaned.length),
      ),
    );
  }
}

String _cleanFieldText(String raw) {
  final String cleaned = raw.replaceAll(_invisibleCharacters, ' ');
  if (cleaned.runes.length <= maxSearchQueryLength) return cleaned;
  return String.fromCharCodes(cleaned.runes.take(maxSearchQueryLength));
}
