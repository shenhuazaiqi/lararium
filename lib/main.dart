import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app.dart';
import 'core/cloud_config.dart';
import 'package:drift/drift.dart';

import 'data/providers.dart';
import 'features/reminders/reminder_service.dart';

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

  // 恢复登录态到 UI（Supabase 会自动还原 session 存储）
  container.read(authEmailProvider.notifier).state =
      Supabase.instance.client.auth.currentUser?.email;

  // 启动时重排忌日/生日提醒（日期滚动后需重算；不阻塞首帧）
  unawaited(_rescheduleReminders(container, prefs));

  runApp(
    UncontrolledProviderScope(
      container: container,
      child: const LarariumApp(),
    ),
  );
}

/// 依据当前树的全部人物重排提醒通知（人物增改/日期滚动后调用）。
Future<void> _rescheduleReminders(
    ProviderContainer container,
    SharedPreferences prefs,
) async {
  try {
    final db = container.read(databaseProvider);
    final treeId = container.read(currentTreeIdProvider.notifier).state ??
        (await container.read(defaultTreeProvider.future)).id;
    final persons = await (db.select(db.persons)
          ..where((p) => p.treeId.equals(treeId) & p.deletedAt.isNull()))
        .get();
    final events = <({String name, DateTime date, bool isAnniversary})>[];
    final annivOn = prefs.getBool('rem_anniv') ?? true;
    final birthOn = prefs.getBool('rem_birth') ?? false;
    for (final p in persons) {
      if (annivOn && !p.isLiving && p.deathDate != null) {
        events.add((
          name: '${p.givenName} ${p.surname}'.trim(),
          date: p.deathDate!,
          isAnniversary: true,
        ));
      }
      if (birthOn && p.birthDate != null) {
        events.add((
          name: '${p.givenName} ${p.surname}'.trim(),
          date: p.birthDate!,
          isAnniversary: false,
        ));
      }
    }
    await ReminderService.instance.init();
    await ReminderService.instance.scheduleUpcoming(
      events: events,
      enabled: true,
      daysAhead: prefs.getInt('rem_days_ahead') ?? 0,
      prefs: prefs,
    );
  } catch (_) {
    // 提醒重排失败不阻塞启动
  }
}
