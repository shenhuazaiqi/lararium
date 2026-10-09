import 'dart:ui';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';

/// 7 套缅怀主题包（规划文档 5.4.3-A），配色 1:1 移植自已评审的 HTML 原型。
class TributeActionDef {
  const TributeActionDef(this.key, this.fx);

  final String key; // flower|marigold|garland|candle|diya|incense|prayer|bow|stone|ofrenda|donation|memory
  final String fx; // bloom|candle|diya|incense|pray|bow|stone|spark
}

class MemorialThemeDef {
  const MemorialThemeDef({
    required this.key,
    required this.label,
    required this.acts,
    required this.stageA,
    required this.stageB,
    required this.accent,
    required this.soft,
    required this.glow,
    required this.flame,
    required this.wick,
    required this.bouquet,
    required this.swatches,
  });

  final String key; // western|east_asian|latin|jewish|hindu|islamic|secular
  final String Function(AppLocalizations) label;
  final List<TributeActionDef> acts;

  final Color stageA; // 舞台底色上
  final Color stageB; // 舞台底色下
  final Color accent; // 强调色
  final Color soft; // 浅底
  final Color glow; // 光晕
  final Color flame; // 烛焰
  final Color wick; // 焰心
  final List<List<Color>> bouquet; // 花束 3 朵 [花瓣, 花心]
  final List<Color> swatches; // 主题色板（选择器圆点）
}

final _western = MemorialThemeDef(
  key: 'western',
  label: (l) => l.themeWestern,
  acts: [
    TributeActionDef('flower', 'bloom'),
    TributeActionDef('candle', 'candle'),
    TributeActionDef('prayer', 'pray'),
  ],
  stageA: Color(0xFF2C2620), stageB: Color(0xFF171412),
  accent: Color(0xFFE0A24E), soft: Color(0xFFFBEFD8),
  glow: Color(0x4DF2A93B), flame: Color(0xFFF2A93B), wick: Color(0xFFFFF3C4),
  bouquet: [
    [Color(0xFFEE8FA6), Color(0xFFF7D06B)],
    [Color(0xFFF0B84E), Color(0xFFE08A2E)],
    [Color(0xFFB892D6), Color(0xFFE9C6F2)],
  ],
  swatches: [Color(0xFFF3EDE2), Color(0xFFE0A24E), Color(0xFF2E6B4F)],
);

final _eastAsian = MemorialThemeDef(
  key: 'east_asian',
  label: (l) => l.themeEastAsian,
  acts: [
    TributeActionDef('incense', 'incense'),
    TributeActionDef('flower', 'bloom'),
    TributeActionDef('bow', 'bow'),
  ],
  stageA: Color(0xFF2A211C), stageB: Color(0xFF151110),
  accent: Color(0xFFB4433A), soft: Color(0xFFF7E4E2),
  glow: Color(0x47B4433A), flame: Color(0xFFE8663A), wick: Color(0xFFFFE2CB),
  bouquet: [
    [Color(0xFFF7F2ED), Color(0xFFE8C56A)],
    [Color(0xFFE9DCC6), Color(0xFFC9A063)],
    [Color(0xFFDCC6B4), Color(0xFFB4433A)],
  ],
  swatches: [Color(0xFFF5F2ED), Color(0xFF8B6B4A), Color(0xFFB4433A)],
);

final _latin = MemorialThemeDef(
  key: 'latin',
  label: (l) => l.themeLatin,
  acts: [
    TributeActionDef('marigold', 'bloom'),
    TributeActionDef('candle', 'candle'),
    TributeActionDef('ofrenda', 'bloom'),
  ],
  stageA: Color(0xFF33200F), stageB: Color(0xFF180E06),
  accent: Color(0xFFF2A93B), soft: Color(0xFFFCEBD2),
  glow: Color(0x57F2A93B), flame: Color(0xFFF2A93B), wick: Color(0xFFFFE9B8),
  bouquet: [
    [Color(0xFFF2A93B), Color(0xFFFFD98A)],
    [Color(0xFFE8862B), Color(0xFFF2A93B)],
    [Color(0xFFD2662A), Color(0xFFF7C46B)],
  ],
  swatches: [Color(0xFFF2A93B), Color(0xFFD2662A), Color(0xFF8A4E12)],
);

final _jewish = MemorialThemeDef(
  key: 'jewish',
  label: (l) => l.themeJewish,
  acts: [
    TributeActionDef('stone', 'stone'),
    TributeActionDef('candle', 'candle'),
    TributeActionDef('prayer', 'pray'),
  ],
  stageA: Color(0xFF1E2429), stageB: Color(0xFF0E1215),
  accent: Color(0xFF8FA6B5), soft: Color(0xFFE7EDEF),
  glow: Color(0x42B4C8D7), flame: Color(0xFFBFD4E0), wick: Color(0xFFF5FAFC),
  bouquet: [
    [Color(0xFFDDE4E8), Color(0xFFA9BDC9)],
    [Color(0xFFC6D2D9), Color(0xFF8FA6B5)],
    [Color(0xFFE8EDEF), Color(0xFFB7BFC4)],
  ],
  swatches: [Color(0xFFB7BFC4), Color(0xFF6B7F8F), Color(0xFF3E4E5C)],
);

final _hindu = MemorialThemeDef(
  key: 'hindu',
  label: (l) => l.themeHindu,
  acts: [
    TributeActionDef('garland', 'bloom'),
    TributeActionDef('diya', 'diya'),
    TributeActionDef('incense', 'incense'),
  ],
  stageA: Color(0xFF2B1E12), stageB: Color(0xFF140D07),
  accent: Color(0xFFC87A1E), soft: Color(0xFFFBE9D2),
  glow: Color(0x52F0B450), flame: Color(0xFFF0B44A), wick: Color(0xFFFFE9B8),
  bouquet: [
    [Color(0xFFF2A93B), Color(0xFFFFE0A0)],
    [Color(0xFFE4798F), Color(0xFFF7D06B)],
    [Color(0xFFB892D6), Color(0xFFFFE9B8)],
  ],
  swatches: [Color(0xFFE0A24E), Color(0xFFC87A1E), Color(0xFF7E5596)],
);

final _islamic = MemorialThemeDef(
  key: 'islamic',
  label: (l) => l.themeIslamic,
  // 尊重教义：不出示蜡烛/香/花圈（规划文档 5.4.3-A）
  acts: [
    TributeActionDef('prayer', 'pray'),
    TributeActionDef('donation', 'pray'),
    TributeActionDef('flower', 'bloom'),
  ],
  stageA: Color(0xFF12241C), stageB: Color(0xFF08120E),
  accent: Color(0xFF5FA583), soft: Color(0xFFE1F0E8),
  glow: Color(0x4778C8A0), flame: Color(0xFF7FCBA6), wick: Color(0xFFE4F5EC),
  bouquet: [
    [Color(0xFFCFE3D8), Color(0xFF5FA583)],
    [Color(0xFFE8F1EC), Color(0xFF8CBFA6)],
    [Color(0xFFB7D6C6), Color(0xFF2E6B4F)],
  ],
  swatches: [Color(0xFF2E6B4F), Color(0xFF5FA583), Color(0xFFCFE3D8)],
);

final _secular = MemorialThemeDef(
  key: 'secular',
  label: (l) => l.themeSecular,
  acts: [
    TributeActionDef('flower', 'bloom'),
    TributeActionDef('candle', 'candle'),
    TributeActionDef('memory', 'spark'),
  ],
  stageA: Color(0xFF232120), stageB: Color(0xFF121110),
  accent: Color(0xFF8B857C), soft: Color(0xFFEDEAE4),
  glow: Color(0x3DC8C4BC), flame: Color(0xFFC9C3B8), wick: Color(0xFFF6F4F0),
  bouquet: [
    [Color(0xFFF0EDE8), Color(0xFFC9C3B8)],
    [Color(0xFFE6E1D9), Color(0xFF8B857C)],
    [Color(0xFFD8D3CA), Color(0xFFA9A298)],
  ],
  swatches: [Color(0xFFE6E1D9), Color(0xFF8B857C), Color(0xFF5C574F)],
);

final List<MemorialThemeDef> memorialThemes = [
  _western, _eastAsian, _latin, _jewish, _hindu, _islamic, _secular,
];

MemorialThemeDef themeByKey(String? key) =>
    memorialThemes.firstWhere((t) => t.key == key, orElse: () => _western);

TributeActionDef? actionByKey(String key) {
  for (final t in memorialThemes) {
    for (final a in t.acts) {
      if (a.key == key) return a;
    }
  }
  return null;
}

String actLabel(AppLocalizations l10n, String key) => switch (key) {
      'flower' => l10n.actFlowers,
      'marigold' => l10n.actMarigolds,
      'garland' => l10n.actGarland,
      'candle' => l10n.actCandle,
      'diya' => l10n.actOilLamp,
      'incense' => l10n.actIncense,
      'prayer' => l10n.actPrayer,
      'bow' => l10n.actBow,
      'stone' => l10n.actStone,
      'ofrenda' => l10n.actOfrenda,
      'donation' => l10n.actDonation,
      'memory' => l10n.actMemory,
      _ => key,
    };

String actSendLabel(AppLocalizations l10n, String key) => switch (key) {
      'flower' => l10n.sendFlowers,
      'marigold' => l10n.sendMarigolds,
      'garland' => l10n.sendGarland,
      'candle' => l10n.sendCandle,
      'diya' => l10n.sendOilLamp,
      'incense' => l10n.sendIncense,
      'prayer' => l10n.sendPrayer,
      'bow' => l10n.sendBow,
      'stone' => l10n.sendStone,
      'ofrenda' => l10n.sendOfrenda,
      'donation' => l10n.sendDonation,
      'memory' => l10n.sendMemory,
      _ => key,
    };

String themeDesc(AppLocalizations l10n, String key) => switch (key) {
      'western' => l10n.themeDescWestern,
      'east_asian' => l10n.themeDescEastAsian,
      'latin' => l10n.themeDescLatin,
      'jewish' => l10n.themeDescJewish,
      'hindu' => l10n.themeDescHindu,
      'islamic' => l10n.themeDescIslamic,
      'secular' => l10n.themeDescSecular,
      _ => '',
    };

/// 地区 → 主题包推荐映射（规划文档 5.4.3-B）。仅作首次预选值，非强制。
String resolveRegionTheme(Locale locale) {
  final lang = locale.languageCode;
  final country = locale.countryCode?.toUpperCase();
  if (lang == 'zh' || lang == 'ja' || lang == 'ko' || lang == 'vi') {
    return 'east_asian';
  }
  if (lang == 'es') {
    // 拉美亡灵节文化圈 → latin；欧洲化天主教区 → western
    const latinAmerica = {
      'MX', 'GT', 'PE', 'CO', 'BO', 'EC', 'VE', 'SV', 'NI', 'CR', 'PA', 'DO', 'HN',
    };
    if (country != null && latinAmerica.contains(country)) return 'latin';
    return country == null ? 'latin' : 'western'; // es（无地区）按最大市场拉美预选
  }
  if (lang == 'he' || lang == 'iw') return 'jewish';
  if (lang == 'hi' || lang == 'bn' || lang == 'ta' || lang == 'mr') return 'hindu';
  if (lang == 'ar' || lang == 'fa' || lang == 'id' || lang == 'ms' || lang == 'tr') {
    return 'islamic';
  }
  return 'western'; // en/fr/de/it/pt/ru/nl 等
}
