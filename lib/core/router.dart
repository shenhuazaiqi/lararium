import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../data/providers.dart';
import '../features/export/export_screen.dart';
import '../features/import/import_screen.dart';
import '../features/pro/pro_screen.dart';
import '../features/reminders/reminders_screen.dart';
import '../features/sync/sync_screen.dart';
import '../features/memorial/memorial_screen.dart';
import '../features/memorial/memorial_wall_screen.dart';
import '../features/onboarding/welcome_screen.dart';
import '../features/people/people_screen.dart';
import '../features/person/add_relative_screen.dart';
import '../features/person/edit_person_screen.dart';
import '../features/person/person_create_screen.dart';
import '../features/search/search_screen.dart';
import '../features/memorial/theme_picker_screen.dart';
import '../features/settings/language_screen.dart';
import '../features/settings/settings_screen.dart';
import '../features/tools/relationship_screen.dart';
import '../features/tree/tree_screen.dart';
import 'theme.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

/// 响应式树网关：当前树变化时自动重建挂载的屏（多树管理）。
class TreeGate extends ConsumerWidget {
  const TreeGate({super.key, required this.builder});

  final Widget Function(String treeId) builder;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final treeId = ref.watch(effectiveTreeIdProvider);
    if (treeId == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return builder(treeId);
  }
}

/// go_router + StatefulShellRoute：底部 4 Tab（树/人物/纪念/设置）常驻（规划文档 2.4 #8）。
GoRouter buildRouter(Ref ref) {
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/tree',
    redirect: (context, state) {
      final onboarded = ref.read(prefsProvider).getBool('onboarded') ?? false;
      final onWelcome = state.matchedLocation == '/welcome';
      if (!onboarded && !onWelcome) return '/welcome';
      if (onboarded && onWelcome) return '/tree';
      return null;
    },
    routes: [
      GoRoute(
        path: '/welcome',
        builder: (context, state) => const WelcomeScreen(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, shell) => HomeShell(shell: shell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/tree',
                builder: (context, state) =>
                    TreeGate(builder: (id) => TreeScreen(treeId: id)),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/people',
                builder: (context, state) =>
                    TreeGate(builder: (id) => PeopleScreen(treeId: id)),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/wall',
                builder: (context, state) =>
                    TreeGate(builder: (id) => MemorialWallScreen(treeId: id)),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/settings',
                builder: (context, state) => const SettingsScreen(),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: '/memorial/:id',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) =>
            MemorialScreen(personId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/tools/relationship',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => TreeGate(
            builder: (id) => RelationshipScreen()),
      ),
      GoRoute(
        path: '/person/new',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const PersonCreateScreen(),
      ),
      GoRoute(
        path: '/person/edit/:id',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) =>
            EditPersonScreen(personId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/person/add/:baseId',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => AddRelativeScreen(
          baseId: state.pathParameters['baseId']!,
          initialRel: state.uri.queryParameters['rel'] ?? 'parent',
        ),
      ),
      GoRoute(
        path: '/search',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) =>
            TreeGate(builder: (id) => SearchScreen(treeId: id)),
      ),
      GoRoute(
        path: '/sync',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const SyncScreen(),
      ),
      GoRoute(
        path: '/reminders',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const RemindersScreen(),
      ),
      GoRoute(
        path: '/pro',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const ProScreen(),
      ),
      GoRoute(
        path: '/settings/language',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const LanguageScreen(),
      ),
      GoRoute(
        path: '/settings/memorial-style',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => ThemePickerScreen(
          personId: state.uri.queryParameters['person'],
        ),
      ),
      GoRoute(
        path: '/export',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const ExportScreen(),
      ),
      GoRoute(
        path: '/import',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const ImportScreen(),
      ),
    ],
  );
}

/// 缓存 router：prefs/onboarding 状态变化时重建由 App 层控制。
final routerProvider = Provider<GoRouter>((ref) => buildRouter(ref));

class HomeShell extends StatelessWidget {
  const HomeShell({super.key, required this.shell});

  final StatefulNavigationShell shell;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = Theme.of(context).extension<LarariumColors>()!;
    return Scaffold(
      body: shell,
      bottomNavigationBar: NavigationBar(
        backgroundColor: colors.surface,
        indicatorColor: colors.brandSoft,
        surfaceTintColor: Colors.transparent,
        height: 64,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        selectedIndex: shell.currentIndex,
        onDestinationSelected: (i) => shell.goBranch(
          i,
          initialLocation: i == shell.currentIndex,
        ),
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.account_tree_outlined),
            selectedIcon: Icon(Icons.account_tree, color: colors.brand),
            label: l10n.tabTree,
          ),
          NavigationDestination(
            icon: const Icon(Icons.people_outline),
            selectedIcon: Icon(Icons.people, color: colors.brand),
            label: l10n.tabPeople,
          ),
          NavigationDestination(
            icon: const Icon(Icons.local_florist_outlined),
            selectedIcon: Icon(Icons.local_florist, color: colors.brand),
            label: l10n.tabMemorial,
          ),
          NavigationDestination(
            icon: const Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings, color: colors.brand),
            label: l10n.tabSettings,
          ),
        ],
      ),
    );
  }
}
