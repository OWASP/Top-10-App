import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:top_10_app/app/settings.dart';
import 'package:top_10_app/data/database.dart';
import 'package:top_10_app/data/settings_repository.dart';

void main() {
  late AppDatabase database;
  late SettingsRepository repository;

  setUp(() {
    database = AppDatabase.forTesting(NativeDatabase.memory());
    repository = SettingsRepository(database);
  });

  tearDown(() => database.close());

  test('settings start with defaults and persist every option', () async {
    final AppSettings defaults = await repository.watch().first;
    expect(defaults.themeMode, ThemeMode.system);
    expect(defaults.textSize, AppTextSize.normal);
    expect(defaults.highContrast, isFalse);
    expect(defaults.readableText, isFalse);
    expect(defaults.reduceMotion, isFalse);

    await repository.setThemeMode(ThemeMode.light);
    await repository.setTextSize(AppTextSize.extraLarge);
    await repository.setHighContrast(true);
    await repository.setReadableText(true);
    await repository.setReduceMotion(true);

    final AppSettings saved = await repository.watch().first;
    expect(saved.themeMode, ThemeMode.light);
    expect(saved.textSize, AppTextSize.extraLarge);
    expect(saved.highContrast, isTrue);
    expect(saved.readableText, isTrue);
    expect(saved.reduceMotion, isTrue);
  });
}
