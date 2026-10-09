import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app.dart';
import 'core/cloud_config.dart';
import 'data/providers.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 云初始化（免登录可用：本地 SQLite 仍是唯一真源，登录同步在阶段 3 接入）
  await Supabase.initialize(
    url: CloudConfig.supabaseUrl,
    anonKey: CloudConfig.supabaseAnonKey,
  );

  final prefs = await SharedPreferences.getInstance();

  final container = ProviderContainer(overrides: [
    prefsProvider.overrideWithValue(prefs),
  ]);

  // 恢复持久化的用户设置到 provider 状态
  container.read(localeOverrideProvider.notifier).state =
      prefs.getString('locale_override');
  final mode = prefs.getString('theme_mode') ?? 'system';
  container.read(themeModeProvider.notifier).state = switch (mode) {
    'light' => ThemeModePrefs.light,
    'dark' => ThemeModePrefs.dark,
    _ => ThemeModePrefs.system,
  };
  container.read(memorialDefaultThemeProvider.notifier).state =
      prefs.getString('memorial_default_theme');

  // 预热默认树（空库 → 播种 Carter 演示家谱）
  final defaultTree = await container.read(defaultTreeProvider.future);
  // 恢复上次的当前树选择（多树管理）
  container.read(currentTreeIdProvider.notifier).state =
      prefs.getString('current_tree_id') ?? defaultTree.id;

  runApp(
    UncontrolledProviderScope(
      container: container,
      child: const LarariumApp(),
    ),
  );
}
