import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;


/// 忌日/生日本地提醒（规划文档 5.4：忌日提醒 + 阶段 5 交付项）。
/// 完全本地计算、零服务端成本；提前 N 天 + 当天各一条，每天 9:00。
class ReminderService {
  ReminderService._();
  static final instance = ReminderService._();

  final _plugin = FlutterLocalNotificationsPlugin();
  bool _ready = false;

  Future<void> init() async {
    if (_ready) return;
    tzdata.initializeTimeZones();
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings();
    await _plugin.initialize(const InitializationSettings(android: android, iOS: ios));
    final impl = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    await impl?.requestNotificationsPermission();
    _ready = true;
  }

  Future<void> cancelAll() => _plugin.cancelAll();

  String _fmtDate(DateTime d) =>
      '${d.month}/${d.day}';

  /// 为一批（姓名, 日期, 类型）调度未来 30 天内的提醒。
  /// [isAnniversary] true = 忌日，false = 生日。
  Future<int> scheduleUpcoming({
    required List<({String name, DateTime date, bool isAnniversary})> events,
    required bool enabled,
    required int daysAhead,
    required SharedPreferences prefs,
  }) async {
    await cancelAll();
    if (!enabled) return 0;
    final now = DateTime.now();
    var scheduled = 0;
    var idSeed = 100;

    for (final e in events) {
      // 未来 30 天内的下一次周年日
      DateTime next =
          DateTime(now.year, e.date.month, e.date.day, 9, 0);
      if (next.isBefore(now)) {
        next = DateTime(now.year + 1, e.date.month, e.date.day, 9, 0);
      }
      final diff = next.difference(DateTime(now.year, now.month, now.day)).inDays;
      if (diff > 30) continue;

      final kindLabel = e.isAnniversary ? 'Memorial' : 'Birthday';
      final body = e.isAnniversary
          ? '${e.name} — $kindLabel · light a candle in memory'
          : '${e.name} — $kindLabel';

      // 当天 9:00
      if (next.isAfter(now)) {
        await _schedule(idSeed++, '${kindLabel}: ${e.name}', body, next);
        scheduled++;
      }
      // 提前 N 天
      if (daysAhead > 0 && daysAhead < 30) {
        final ahead = next.subtract(Duration(days: daysAhead));
        if (ahead.isAfter(now)) {
          await _schedule(
              idSeed++,
              'Upcoming: ${e.name}',
              '$kindLabel in $daysAhead days (${_fmtDate(next)})',
              ahead);
          scheduled++;
        }
      }
    }
    await prefs.setInt('reminders_scheduled', scheduled);
    return scheduled;
  }

  Future<void> _schedule(int id, String title, String body, DateTime when) async {
    final details = NotificationDetails(
      android: AndroidNotificationDetails(
        'anniversaries',
        'Anniversaries & birthdays',
        channelDescription: 'Death anniversaries and birthday reminders',
        importance: Importance.defaultImportance,
        priority: Priority.defaultPriority,
      ),
      iOS: const DarwinNotificationDetails(),
    );
    await _plugin.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(when, tz.local),
      details,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }
}
