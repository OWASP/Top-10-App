import 'package:flutter/material.dart';

import '../app/settings.dart';
import 'database.dart';

/// Stores accessibility and appearance preferences in the local database.
class SettingsRepository {
  SettingsRepository(this._db);

  final AppDatabase _db;

  Stream<AppSettings> watch() {
    return _db
        .select(_db.settingEntries)
        .watch()
        .map(
          (List<SettingEntry> rows) => AppSettings.fromMap(<String, String>{
            for (final SettingEntry row in rows) row.key: row.value,
          }),
        );
  }

  Future<void> setThemeMode(ThemeMode mode) {
    return _set(AppSettings.themeModeKey, mode.name);
  }

  Future<void> setTextSize(AppTextSize size) {
    return _set(AppSettings.textSizeKey, size.name);
  }

  Future<void> setHighContrast(bool enabled) {
    return _set(AppSettings.highContrastKey, '$enabled');
  }

  Future<void> setReadableText(bool enabled) {
    return _set(AppSettings.readableTextKey, '$enabled');
  }

  Future<void> setReduceMotion(bool enabled) {
    return _set(AppSettings.reduceMotionKey, '$enabled');
  }

  Future<void> _set(String key, String value) {
    return _db
        .into(_db.settingEntries)
        .insertOnConflictUpdate(
          SettingEntriesCompanion.insert(key: key, value: value),
        );
  }
}
