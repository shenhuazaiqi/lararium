import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';
import 'data/providers.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

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
  await container.read(defaultTreeProvider.future);

  runApp(
    UncontrolledProviderScope(
      container: container,
      child: const LarariumApp(),
    ),
  );
}
