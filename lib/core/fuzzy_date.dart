/// 家谱特有的「模糊日期」：支持 `1918` / `1921-03` / `1921-03-30` 三档精度。
/// 规划文档 6.6 坑 #5：仅年份/约年份不能走 DateFormat，需独立逻辑。
class FuzzyDate {
  const FuzzyDate(this.date, this.precision);

  final DateTime date;
  /// day | month | year
  final String precision;

  static FuzzyDate? tryParse(String input) {
    final s = input.trim();
    if (s.isEmpty) return null;
    final m = RegExp(r'^(\d{4})(?:-(\d{1,2}))?(?:-(\d{1,2}))?$').firstMatch(s);
    if (m == null) return null;
    final y = int.parse(m.group(1)!);
    if (y < 1 || y > 3000) return null;
    final mo = int.tryParse(m.group(2) ?? '') ?? 1;
    final d = int.tryParse(m.group(3) ?? '') ?? 1;
    if (mo < 1 || mo > 12 || d < 1 || d > 31) return null;
    final precision = m.group(3) != null
        ? 'day'
        : m.group(2) != null
            ? 'month'
            : 'year';
    return FuzzyDate(DateTime(y, mo, d), precision);
  }

  static String encode(DateTime date, String precision) {
    final y = date.year.toString().padLeft(4, '0');
    if (precision == 'year') return y;
    final m = date.month.toString().padLeft(2, '0');
    if (precision == 'month') return '$y-$m';
    final d = date.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }
}
