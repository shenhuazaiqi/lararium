import 'dart:ui' show Locale;

import 'package:intl/intl.dart';

import '../data/db/app_database.dart';

/// 姓名显示顺序按 locale（规划文档 6.6 坑 #4）：东亚姓前，其余名前。
String personDisplayName(Person p, Locale locale) {
  const surnameFirst = {'ja', 'ko', 'zh'};
  final full = surnameFirst.contains(locale.languageCode)
      ? '${p.surname} ${p.givenName}'
      : '${p.givenName} ${p.surname}';
  return full.trim().isEmpty ? '—' : full.trim();
}

/// 按精度的本地化日期显示（规划文档 6.6 坑 #5）。
String formatFuzzyDate(DateTime d, String precision, String locale) {
  switch (precision) {
    case 'year':
      return '${d.year}';
    case 'month':
      return DateFormat.yMMM(locale).format(d);
    default:
      return DateFormat.yMMMd(locale).format(d);
  }
}

/// 人物生卒显示：树节点用（仅年份）。
String personYears(Person p) {
  if (!p.isLiving && p.deathDate != null) {
    return '${p.birthDate?.year ?? '?'} – ${p.deathDate!.year}';
  }
  if (p.birthDate != null) return '${p.birthDate!.year}';
  return '';
}

/// 生卒地点行：「Mar 12, 1918 · Boston, MA」。
String bornLine(Person p, String locale) {
  if (p.birthDate == null) return p.birthPlace ?? '—';
  final d = formatFuzzyDate(p.birthDate!, p.birthPrecision, locale);
  final place = p.birthPlace;
  return place == null || place.isEmpty ? d : '$d · $place';
}

String diedLine(Person p, String locale) {
  if (p.deathDate == null) return p.deathPlace ?? '—';
  final d = formatFuzzyDate(p.deathDate!, p.deathPrecision, locale);
  final place = p.deathPlace;
  return place == null || place.isEmpty ? d : '$d · $place';
}

/// 忌日月日（用于纪念页 "Anniversary: Nov 4"）。
String anniversaryLabel(Person p, String locale) {
  if (p.deathDate == null) return '';
  return DateFormat.MMMd(locale).format(p.deathDate!);
}
