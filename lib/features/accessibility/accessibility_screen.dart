import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/settings.dart';
import '../../core/widgets.dart';
import '../../data/providers.dart';
import '../../data/settings_repository.dart';
import 'system_accessibility.dart';

class AccessibilityScreen extends ConsumerWidget {
  const AccessibilityScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ThemeData theme = Theme.of(context);
    final AppSettings settings =
        ref.watch(appSettingsProvider).value ?? const AppSettings();
    final SettingsRepository repository = ref.read(settingsRepositoryProvider);
    final bool screenReaderOn = MediaQuery.accessibleNavigationOf(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Accessibility')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: <Widget>[
          Text(
            'Make the app work for you. Settings are saved on this device.',
            style: theme.textTheme.bodyLarge,
          ),
          const SizedBox(height: 8),
          const SectionHeader(
            title: 'Appearance',
            icon: Icons.palette_outlined,
          ),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: <Widget>[
              for (final ThemeMode mode in ThemeMode.values)
                ChoiceChip(
                  label: Text(_themeLabel(mode)),
                  selected: settings.themeMode == mode,
                  onSelected: (_) => unawaited(repository.setThemeMode(mode)),
                ),
            ],
          ),
          const SectionHeader(title: 'Text size', icon: Icons.text_fields),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: <Widget>[
              for (final AppTextSize size in AppTextSize.values)
                ChoiceChip(
                  label: Text(size.label),
                  selected: settings.textSize == size,
                  onSelected: (_) => unawaited(repository.setTextSize(size)),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'The app also follows the system font size.',
            style: theme.textTheme.bodySmall,
          ),
          const SectionHeader(
            title: 'Display',
            icon: Icons.visibility_outlined,
          ),
          Card(
            child: Column(
              children: <Widget>[
                SwitchListTile(
                  secondary: const Icon(Icons.contrast),
                  title: const Text('High contrast'),
                  subtitle: const Text('Stronger colors and borders'),
                  value: settings.highContrast,
                  onChanged: (bool value) =>
                      unawaited(repository.setHighContrast(value)),
                ),
                const Divider(height: 1),
                SwitchListTile(
                  secondary: const Icon(Icons.format_line_spacing),
                  title: const Text('Readable spacing'),
                  subtitle: const Text('Wider letter and line spacing'),
                  value: settings.readableText,
                  onChanged: (bool value) =>
                      unawaited(repository.setReadableText(value)),
                ),
                const Divider(height: 1),
                SwitchListTile(
                  secondary: const Icon(Icons.motion_photos_off_outlined),
                  title: const Text('Reduce motion'),
                  subtitle: const Text('Turn off animations'),
                  value: settings.reduceMotion,
                  onChanged: (bool value) =>
                      unawaited(repository.setReduceMotion(value)),
                ),
              ],
            ),
          ),
          const SectionHeader(
            title: 'Screen reader',
            icon: Icons.record_voice_over_outlined,
          ),
          Card(
            child: Column(
              children: <Widget>[
                ListTile(
                  leading: const Icon(Icons.record_voice_over_outlined),
                  title: const Text('TalkBack'),
                  subtitle: Text(
                    screenReaderOn
                        ? 'On. Android is announcing this screen.'
                        : 'Off. Turn it on in Android accessibility settings.',
                  ),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.settings_accessibility_outlined),
                  title: const Text('Open Android accessibility settings'),
                  subtitle: const Text(
                    'Enable TalkBack or another screen reader',
                  ),
                  trailing: const Icon(Icons.open_in_new),
                  onTap: () async {
                    final bool opened = await openSystemAccessibilitySettings();
                    if (!opened && context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Could not open Android accessibility settings.',
                          ),
                        ),
                      );
                    }
                  },
                ),
              ],
            ),
          ),
          const SectionHeader(title: 'Built in', icon: Icons.verified_outlined),
          const Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  _BuiltInItem('Screen reader labels and state announcements'),
                  _BuiltInItem(
                    'TalkBack status and a shortcut to its settings',
                  ),
                  _BuiltInItem('Quiz feedback uses words and icons, not color'),
                  _BuiltInItem('Touch targets of at least 48 dp'),
                  _BuiltInItem('Text scaling without clipping'),
                  _BuiltInItem('Light, dark, and system appearance'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Design goal: WCAG 2.2 level AA. Test with TalkBack and real '
            'users before release.',
            style: theme.textTheme.bodySmall,
          ),
        ],
      ),
    );
  }

  String _themeLabel(ThemeMode mode) {
    return switch (mode) {
      ThemeMode.system => 'System',
      ThemeMode.light => 'Light',
      ThemeMode.dark => 'Dark',
    };
  }
}

class _BuiltInItem extends StatelessWidget {
  const _BuiltInItem(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Icon(Icons.check, size: 18),
          const SizedBox(width: 8),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}
