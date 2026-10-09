import 'package:shared_preferences/shared_preferences.dart';

/// 免费版缅怀额度（规划文档 5.4.4）：
/// - 每类动作 1 次/天（留言 3 条/天），按「用户 × 本地自然日」计
/// - 忌日当天对该人物 +1（最重要的一条防差评豁免）
/// - 额度数字做成常量配置，云阶段切到服务端 remote_config（无需发版）
class MemorialQuota {
  MemorialQuota._();

  static const int dailyActLimit = 1;
  static const int dailyMessageLimit = 3;

  static String _dayKey(DateTime now) =>
      '${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}';

  static int usedToday(SharedPreferences prefs, String personId, String kind) {
    final v = prefs.getInt('quota_${_dayKey(DateTime.now())}_${personId}_$kind');
    return v ?? 0;
  }

  static bool isAnniversaryToday(DateTime? deathDate) {
    if (deathDate == null) return false;
    final now = DateTime.now();
    return deathDate.month == now.month && deathDate.day == now.day;
  }

  /// 返回 {allowed, remaining, isAnniversary}（对齐规划 6.7 的额度 UX 口径）
  static ({bool allowed, int remaining, bool isAnniversary}) check(
    SharedPreferences prefs,
    String personId,
    String kind,
    DateTime? deathDate, {
    int limit = dailyActLimit,
  }) {
    final bonus = isAnniversaryToday(deathDate) ? 1 : 0;
    final used = usedToday(prefs, personId, kind);
    final allowed = used < limit + bonus;
    return (
      allowed: allowed,
      remaining: (limit + bonus - used).clamp(0, limit + bonus),
      isAnniversary: bonus > 0,
    );
  }

  static Future<void> consume(
      SharedPreferences prefs, String personId, String kind) async {
    final key = 'quota_${_dayKey(DateTime.now())}_${personId}_$kind';
    await prefs.setInt(key, (prefs.getInt(key) ?? 0) + 1);
  }
}
