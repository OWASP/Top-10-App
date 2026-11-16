import 'package:drift/drift.dart';

import 'database.dart';

/// Owns all local user state: read progress, bookmarks, and quiz attempts.
class ProgressRepository {
  ProgressRepository(this._db);

  final AppDatabase _db;

  Stream<Set<String>> watchReadRiskIds() {
    return _db
        .select(_db.readProgress)
        .watch()
        .map((rows) => rows.map((row) => row.riskId).toSet());
  }

  Future<void> markRead(String riskId) {
    return _db
        .into(_db.readProgress)
        .insertOnConflictUpdate(
          ReadProgressCompanion.insert(riskId: riskId, readAt: DateTime.now()),
        );
  }

  Stream<Set<String>> watchBookmarkedRiskIds() {
    return _db
        .select(_db.bookmarkEntries)
        .watch()
        .map((rows) => rows.map((row) => row.riskId).toSet());
  }

  Future<void> toggleBookmark(String riskId) async {
    final existing = await (_db.select(
      _db.bookmarkEntries,
    )..where((table) => table.riskId.equals(riskId))).getSingleOrNull();

    if (existing != null) {
      await (_db.delete(
        _db.bookmarkEntries,
      )..where((table) => table.riskId.equals(riskId))).go();
      return;
    }

    await _db
        .into(_db.bookmarkEntries)
        .insert(
          BookmarkEntriesCompanion.insert(
            riskId: riskId,
            createdAt: DateTime.now(),
          ),
        );
  }

  Stream<List<QuizAttemptEntry>> watchQuizAttempts() {
    return (_db.select(
      _db.quizAttemptEntries,
    )..orderBy([(table) => OrderingTerm.desc(table.attemptedAt)])).watch();
  }

  Future<void> recordQuizAttempt({
    required String listId,
    required String questionId,
    required int selectedIndex,
    required bool correct,
  }) {
    return _db
        .into(_db.quizAttemptEntries)
        .insert(
          QuizAttemptEntriesCompanion.insert(
            listId: listId,
            questionId: questionId,
            selectedIndex: selectedIndex,
            correct: correct,
            attemptedAt: DateTime.now(),
          ),
        );
  }

  Future<void> resetAll() {
    return _db.transaction(() async {
      await _db.delete(_db.readProgress).go();
      await _db.delete(_db.bookmarkEntries).go();
      await _db.delete(_db.quizAttemptEntries).go();
    });
  }
}
