import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

part 'database.g.dart';

/// Read state is keyed by stable content IDs, never by list position.
@DataClassName('ReadProgressEntry')
class ReadProgress extends Table {
  TextColumn get riskId => text()();
  DateTimeColumn get readAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{riskId};
}

@DataClassName('BookmarkEntry')
class BookmarkEntries extends Table {
  TextColumn get riskId => text()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{riskId};
}

@DataClassName('QuizAttemptEntry')
class QuizAttemptEntries extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get listId => text()();
  TextColumn get questionId => text()();
  IntColumn get selectedIndex => integer()();
  BoolColumn get correct => boolean()();
  DateTimeColumn get attemptedAt => dateTime()();
}

/// Device-local accessibility and appearance preferences.
@DataClassName('SettingEntry')
class SettingEntries extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{key};
}

@DriftDatabase(
  tables: [ReadProgress, BookmarkEntries, QuizAttemptEntries, SettingEntries],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(driftDatabase(name: 'top_10_app'));

  /// Used by tests with an in-memory executor.
  AppDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (Migrator migrator) => migrator.createAll(),
    onUpgrade: (Migrator migrator, int from, int to) async {
      if (from < 2) {
        await migrator.createTable(settingEntries);
      }
    },
  );
}
