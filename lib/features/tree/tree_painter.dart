import 'package:flutter/material.dart';

import '../../core/theme.dart';
import 'layout/tree_layout.dart';

/// 节点的展示信息（文案与配色在 widget 层算好，painter 保持纯绘制）。
class PersonNodeVisual {
  const PersonNodeVisual({
    required this.name,
    required this.years,
    required this.initials,
    required this.avatarTop,
    required this.avatarBottom,
  });

  final String name;
  final String years;
  final String initials;
  final Color avatarTop;
  final Color avatarBottom;
}

/// 头像渐变色板（移植原型 10 人配色，按 personId 稳定取色）。
const List<List<Color>> kAvatarPalette = [
  [Color(0xFF4A90D9), Color(0xFF2A5F96)],
  [Color(0xFF5FA583), Color(0xFF2E6B4F)],
  [Color(0xFFE0A24E), Color(0xFFB0742A)],
  [Color(0xFFB98BD6), Color(0xFF7E5596)],
  [Color(0xFFE4798F), Color(0xFFB84E68)],
  [Color(0xFF6B7F8F), Color(0xFF3E4E5C)],
  [Color(0xFF8A6BB1), Color(0xFF5C4280)],
  [Color(0xFF8B857C), Color(0xFF5C574F)],
  [Color(0xFF5FA583), Color(0xFF357A5B)],
  [Color(0xFFC8791A), Color(0xFF8A4E12)],
];

List<Color> avatarColorsFor(String personId) {
  var h = 0;
  for (final cu in personId.codeUnits) {
    h = (h * 31 + cu) & 0x7fffffff;
  }
  return kAvatarPalette[h % kAvatarPalette.length];
}

Color desaturate(Color c) {
  final l = c.computeLuminance();
  final g = (l * 255).round();
  return Color.fromARGB(c.alpha, g, g, g);
}

class TreeViewport extends ChangeNotifier {
  double scale = 1;
  Offset offset = Offset.zero;

  void set({double? scale, Offset? offset}) {
    if (scale != null) this.scale = scale;
    if (offset != null) this.offset = offset;
    notifyListeners();
  }

  void zoomAround(Offset focal, double newScale) {
    final s = newScale.clamp(0.3, 2.2);
    final world = (focal - offset) / scale;
    offset = focal - world * s;
    scale = s;
    notifyListeners();
  }
}

class TreePainter extends CustomPainter {
  TreePainter({
    required this.result,
    required this.visuals,
    required this.viewport,
    required this.colors,
    required this.selfBadge,
  }) : super(repaint: viewport);

  final TreeLayoutResult result;
  final Map<String, PersonNodeVisual> visuals;
  final TreeViewport viewport;
  final LarariumColors colors;
  final String? selfBadge;

  @override
  void paint(Canvas canvas, Size size) {
    if (result.nodes.isEmpty) return;
    canvas.save();
    canvas.translate(viewport.offset.dx, viewport.offset.dy);
    canvas.scale(viewport.scale);

    _paintWires(canvas);
    _paintNodes(canvas);

    canvas.restore();
  }

  void _paintWires(Canvas canvas) {
    final paint = Paint()
      ..color = colors.line2
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6
      ..strokeCap = StrokeCap.round;
    final path = Path();
    for (final w in result.wires) {
      path.moveTo(w.from.dx, w.from.dy);
      path.lineTo(w.to.dx, w.to.dy);
    }
    canvas.drawPath(path, paint);
  }

  void _paintNodes(Canvas canvas) {
    for (final node in result.nodes) {
      final v = visuals[node.person.id];
      if (v == null) continue;
      final r = node.rect;
      final dead = !node.person.isLiving;

      // 阴影 + 外圈
      if (node.isFocus) {
        final ring = RRect.fromRectAndRadius(
          r.inflate(3.5),
          const Radius.circular(17.5),
        );
        canvas.drawRRect(ring, Paint()..color = colors.brandSoft);
      }
      final shadow = Paint()
        ..color = Colors.black.withOpacity( 0.06)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);
      canvas.drawRRect(
        RRect.fromRectAndRadius(r.translate(0, 2), const Radius.circular(14)),
        shadow,
      );

      // 节点底
      final fill = Paint()
        ..color = dead ? Color.lerp(colors.surface, colors.surface2, 0.6)! : colors.surface;
      canvas.drawRRect(
        RRect.fromRectAndRadius(r, const Radius.circular(14)),
        fill,
      );
      final border = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5
        ..color = node.isFocus ? colors.brand : colors.line2;
      canvas.drawRRect(
        RRect.fromRectAndRadius(r, const Radius.circular(14)),
        border,
      );

      final cx = r.center.dx;

      // 头像（已故 → 去饱和）
      final top = dead ? desaturate(v.avatarTop) : v.avatarTop;
      final bottom = dead ? desaturate(v.avatarBottom) : v.avatarBottom;
      final avatarRect = Rect.fromCircle(center: Offset(cx, r.top + 19), radius: 13);
      canvas.drawCircle(
        avatarRect.center,
        13,
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [top, bottom],
          ).createShader(avatarRect),
      );
      _text(canvas, v.initials, avatarRect.center, fontSize: 10,
          weight: FontWeight.w700, color: Colors.white);

      // 姓名
      _text(canvas, v.name, Offset(cx, r.top + 42),
          fontSize: 11.5,
          weight: FontWeight.w600,
          color: dead ? colors.ink2 : colors.ink,
          maxWidth: r.width - 14);

      // 年份
      _text(canvas, v.years, Offset(cx, r.top + 57),
          fontSize: 9.5, color: colors.ink3, maxWidth: r.width - 14);

      // 「我」徽标
      if (node.isSelf && selfBadge != null) {
        _badge(canvas, selfBadge!, Offset(cx, r.top - 8),
            background: node.isFocus ? colors.brand : colors.ink3);
      }
    }
  }

  void _text(
    Canvas canvas,
    String s,
    Offset center, {
    required double fontSize,
    Color color = Colors.black,
    FontWeight weight = FontWeight.w400,
    double? maxWidth,
  }) {
    final tp = TextPainter(
      text: TextSpan(
        text: s,
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: weight,
          color: color,
          height: 1.15,
        ),
      ),
      maxLines: 1,
      ellipsis: '…',
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: maxWidth ?? double.infinity);
    tp.paint(canvas, center - Offset(tp.width / 2, tp.height / 2));
  }

  void _badge(Canvas canvas, String label, Offset topCenter,
      {required Color background}) {
    final tp = TextPainter(
      text: TextSpan(
        text: label.toUpperCase(),
        style: TextStyle(
          fontSize: 8.5,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
          color: Colors.white,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    const hPad = 6.0, h = 15.0;
    final w = tp.width + hPad * 2;
    final rect = Rect.fromLTWH(topCenter.dx - w / 2, topCenter.dy - h / 2, w, h);
    canvas.drawRRect(RRect.fromRectAndRadius(rect, const Radius.circular(5)),
        Paint()..color = background);
    tp.paint(canvas, rect.center - Offset(tp.width / 2, tp.height / 2));
  }

  @override
  bool shouldRepaint(covariant TreePainter old) =>
      old.result != result || old.colors != colors || old.selfBadge != selfBadge;
}
