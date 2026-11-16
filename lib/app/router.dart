import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/brand_icons.dart';
import '../features/about/about_screen.dart';
import '../features/accessibility/accessibility_screen.dart';
import '../features/cheatsheets/cheatsheets_screen.dart';
import '../features/detail/risk_detail_screen.dart';
import '../features/learn/learn_screen.dart';
import '../features/practice/practice_screen.dart';
import '../features/progress/progress_screen.dart';

final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>(
  debugLabel: 'root',
);

final Provider<GoRouter> routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: '/learn',
    routes: <RouteBase>[
      StatefulShellRoute.indexedStack(
        builder:
            (
              BuildContext context,
              GoRouterState state,
              StatefulNavigationShell navigationShell,
            ) {
              return AppShell(navigationShell: navigationShell);
            },
        branches: <StatefulShellBranch>[
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: '/learn',
                builder: (BuildContext context, GoRouterState state) =>
                    const LearnScreen(),
                routes: <RouteBase>[
                  GoRoute(
                    path: ':listId/:riskId',
                    builder: (BuildContext context, GoRouterState state) {
                      return RiskDetailScreen(
                        listId: state.pathParameters['listId']!,
                        riskId: state.pathParameters['riskId']!,
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: '/practice',
                builder: (BuildContext context, GoRouterState state) =>
                    const PracticeScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: '/cheatsheets',
                builder: (BuildContext context, GoRouterState state) =>
                    const CheatsheetsScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: '/progress',
                builder: (BuildContext context, GoRouterState state) =>
                    const ProgressScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: '/access',
                builder: (BuildContext context, GoRouterState state) =>
                    const AccessibilityScreen(),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: '/about',
        parentNavigatorKey: rootNavigatorKey,
        builder: (BuildContext context, GoRouterState state) =>
            const AboutScreen(),
      ),
    ],
  );
});

/// A navigation destination whose glyph keeps its own colour in both the
/// selected and unselected states.
NavigationDestination _destination(
  ColorScheme scheme,
  BrandGlyph glyph,
  String label,
) {
  final Color accent = navAccentFor(scheme, glyph);
  return NavigationDestination(
    icon: BrandIcon(glyph, color: accent),
    selectedIcon: BrandIcon(glyph, color: accent, filled: true),
    label: label,
  );
}

class AppShell extends StatelessWidget {
  const AppShell({required this.navigationShell, super.key});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Divider(height: 1, color: scheme.outlineVariant),
          NavigationBar(
            selectedIndex: navigationShell.currentIndex,
            onDestinationSelected: (int index) {
              if (index != navigationShell.currentIndex) {
                unawaited(HapticFeedback.selectionClick());
              }
              navigationShell.goBranch(
                index,
                initialLocation: index == navigationShell.currentIndex,
              );
            },
            destinations: <NavigationDestination>[
              _destination(scheme, BrandGlyph.learn, 'Learn'),
              _destination(scheme, BrandGlyph.practice, 'Practice'),
              _destination(scheme, BrandGlyph.sheets, 'Sheets'),
              _destination(scheme, BrandGlyph.progress, 'Progress'),
              _destination(scheme, BrandGlyph.access, 'Access'),
            ],
          ),
        ],
      ),
    );
  }
}
