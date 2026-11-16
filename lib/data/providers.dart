import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../app/settings.dart';
import 'database.dart';
import 'progress_repository.dart';
import 'settings_repository.dart';

final Provider<AppDatabase> databaseProvider = Provider<AppDatabase>((ref) {
  final database = AppDatabase();
  ref.onDispose(database.close);
  return database;
});

final Provider<ProgressRepository> progressRepositoryProvider =
    Provider<ProgressRepository>(
      (ref) => ProgressRepository(ref.watch(databaseProvider)),
    );

final Provider<SettingsRepository> settingsRepositoryProvider =
    Provider<SettingsRepository>(
      (ref) => SettingsRepository(ref.watch(databaseProvider)),
    );

final StreamProvider<AppSettings> appSettingsProvider =
    StreamProvider<AppSettings>(
      (ref) => ref.watch(settingsRepositoryProvider).watch(),
    );

final StreamProvider<Set<String>> readRiskIdsProvider =
    StreamProvider<Set<String>>(
      (ref) => ref.watch(progressRepositoryProvider).watchReadRiskIds(),
    );

final StreamProvider<Set<String>> bookmarkedRiskIdsProvider =
    StreamProvider<Set<String>>(
      (ref) => ref.watch(progressRepositoryProvider).watchBookmarkedRiskIds(),
    );

final StreamProvider<List<QuizAttemptEntry>> quizAttemptsProvider =
    StreamProvider<List<QuizAttemptEntry>>(
      (ref) => ref.watch(progressRepositoryProvider).watchQuizAttempts(),
    );
