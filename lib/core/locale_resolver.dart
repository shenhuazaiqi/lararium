import 'dart:ui';

import 'package:flutter/foundation.dart';
/// 默认语言自动选择 —— 严格按规划文档 5.3.2 的算法：
/// 1. 用户手动选过 → 用用户选择（最高优先级，持久化）
/// 2. 遍历系统 locales（复数）列表
///    a. 先精确匹配 languageCode + countryCode
///    b. 再只匹配 languageCode
///    c. 中文特殊处理：CN/SG/MY 或 script=Hans → zh-Hans；TW/HK/MO 或 Hant → zh-Hant；无信息 → zh-Hans
/// 3. 列表中任意一个能匹配即停止
/// 4. 全部无法匹配 → 兜底 en
class LocaleResolver {
  LocaleResolver._();

  /// App 支持的 12 种语言（V1.0 首版，见规划文档 5.3.1）。
  static const supportedTags = [
    'en', 'es', 'pt', 'fr', 'de', 'it', 'ja', 'ko', 'zh-Hans', 'zh-Hant', 'ru', 'nl',
  ];

  static Locale fallback = const Locale('en');

  static Locale parseTag(String tag) {
    if (tag.contains('-')) {
      final parts = tag.split('-');
      if (parts.length >= 2 && parts[0] == 'zh') {
        return Locale.fromSubtags(
            languageCode: 'zh', scriptCode: parts[1]);
      }
      return Locale(parts[0], parts[1]);
    }
    return Locale(tag);
  }

  static String tagOf(Locale l) {
    if (l.scriptCode != null) return '${l.languageCode}-${l.scriptCode}';
    return l.languageCode;
  }

  static Locale resolve({
    String? overrideTag,
    List<Locale>? systemLocales,
  }) {
    if (overrideTag != null && supportedTags.contains(overrideTag)) {
      return parseTag(overrideTag);
    }
    final locales = systemLocales ??
        WidgetsBindingDispatcherLocales.platformDispatcherLocales();
    for (final l in locales) {
      final exact = _matchExact(l);
      if (exact != null) return exact;
    }
    for (final l in locales) {
      final loose = _matchLanguage(l);
      if (loose != null) return loose;
    }
    return fallback;
  }

  /// 精确匹配（含地区）：目前只有中文有脚本级变体需要精确判定。
  static Locale? _matchExact(Locale l) {
    if (l.languageCode == 'zh') return _resolveChinese(l);
    return null;
  }

  /// 只匹配语言码。
  static Locale? _matchLanguage(Locale l) {
    switch (l.languageCode) {
      case 'zh':
        return _resolveChinese(l); // 无 script/地区信息 → 简体为主流
      case 'en':
      case 'es':
      case 'pt':
      case 'fr':
      case 'de':
      case 'it':
      case 'ja':
      case 'ko':
      case 'ru':
      case 'nl':
        return Locale(l.languageCode);
    }
    return null;
  }

  static Locale _resolveChinese(Locale l) {
    final script = l.scriptCode;
    final region = l.countryCode?.toUpperCase();
    if (script == 'Hant' ||
        (script == null && (region == 'TW' || region == 'HK' || region == 'MO'))) {
      return Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hant');
    }
    return Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hans');
  }
}

/// 隔离 WidgetsBinding 依赖，便于单元测试。
class WidgetsBindingDispatcherLocales {
  WidgetsBindingDispatcherLocales._();

  static List<Locale> platformDispatcherLocales() =>
      PlatformDispatcher.instance.locales;
}
