import 'package:flutter/material.dart';

enum AppTextSize {
  normal('Default', 1),
  large('Large', 1.15),
  extraLarge('Extra large', 1.3);

  const AppTextSize(this.label, this.factor);

  final String label;
  final double factor;
}

/// Accessibility and appearance preferences stored on the device.
class AppSettings {
  const AppSettings({
    this.themeMode = ThemeMode.system,
    this.textSize = AppTextSize.normal,
    this.highContrast = false,
    this.readableText = false,
    this.reduceMotion = false,
  });

  static const String themeModeKey = 'themeMode';
  static const String textSizeKey = 'textSize';
  static const String highContrastKey = 'highContrast';
  static const String readableTextKey = 'readableText';
  static const String reduceMotionKey = 'reduceMotion';

  final ThemeMode themeMode;
  final AppTextSize textSize;
  final bool highContrast;
  final bool readableText;
  final bool reduceMotion;

  factory AppSettings.fromMap(Map<String, String> values) {
    return AppSettings(
      themeMode: switch (values[themeModeKey]) {
        'light' => ThemeMode.light,
        'dark' => ThemeMode.dark,
        _ => ThemeMode.system,
      },
      textSize: AppTextSize.values.firstWhere(
        (AppTextSize size) => size.name == values[textSizeKey],
        orElse: () => AppTextSize.normal,
      ),
      highContrast: values[highContrastKey] == 'true',
      readableText: values[readableTextKey] == 'true',
      reduceMotion: values[reduceMotionKey] == 'true',
    );
  }

  AppSettings copyWith({
    ThemeMode? themeMode,
    AppTextSize? textSize,
    bool? highContrast,
    bool? readableText,
    bool? reduceMotion,
  }) {
    return AppSettings(
      themeMode: themeMode ?? this.themeMode,
      textSize: textSize ?? this.textSize,
      highContrast: highContrast ?? this.highContrast,
      readableText: readableText ?? this.readableText,
      reduceMotion: reduceMotion ?? this.reduceMotion,
    );
  }
}
