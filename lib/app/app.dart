import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/providers.dart';
import 'router.dart';
import 'settings.dart';
import 'theme.dart';

class Top10App extends ConsumerWidget {
  const Top10App({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppSettings settings =
        ref.watch(appSettingsProvider).value ?? const AppSettings();

    return MaterialApp.router(
      title: 'OWASP Top 10 Pocket Guide',
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(
        brightness: Brightness.light,
        highContrast: settings.highContrast,
        readableText: settings.readableText,
      ),
      darkTheme: buildAppTheme(
        brightness: Brightness.dark,
        highContrast: settings.highContrast,
        readableText: settings.readableText,
      ),
      themeMode: settings.themeMode,
      builder: (BuildContext context, Widget? child) {
        final MediaQueryData media = MediaQuery.of(context);

        // Preserve the platform's (possibly nonlinear) text scaler at the
        // default size, and layer the in-app size on top of its body-text
        // scale when one is selected.
        final TextScaler scaler = settings.textSize == AppTextSize.normal
            ? media.textScaler
            : TextScaler.linear(
                (media.textScaler.scale(14) / 14 * settings.textSize.factor)
                    .clamp(0.8, 3.0),
              );

        return MediaQuery(
          data: media.copyWith(
            textScaler: scaler,
            disableAnimations: settings.reduceMotion || media.disableAnimations,
          ),
          child: child ?? const SizedBox.shrink(),
        );
      },
      routerConfig: ref.watch(routerProvider),
    );
  }
}
