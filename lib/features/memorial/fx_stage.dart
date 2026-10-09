import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'memorial_theme_defs.dart';

/// 05 缅怀页特效舞台：花瓣飘落 / 烛焰摇曳 / 青烟粒子 / 祈福光点 / 鞠躬 / 放石。
/// 全部 CustomPaint 自绘（规划文档 6.7：零依赖、无版权风险、可主题化）。
class FxStage extends StatefulWidget {
  const FxStage({
    super.key,
    required this.kind, // null = 空态
    required this.theme,
    required this.hint,
  });

  final String? kind;
  final MemorialThemeDef theme;
  final String hint;

  @override
  State<FxStage> createState() => _FxStageState();
}

class _FxStageState extends State<FxStage> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl =
      AnimationController(vsync: this, duration: const Duration(seconds: 4))
        ..repeat();

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final active = widget.kind != null;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      height: 172,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Theme.of(context).dividerColor),
        gradient: active
            ? LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [widget.theme.stageA, widget.theme.stageB])
            : null,
        color: active ? null : Theme.of(context).colorScheme.surfaceContainerHighest,
      ),
      child: AnimatedDefaultTextStyle(
        duration: const Duration(milliseconds: 400),
        style: TextStyle(
          fontSize: 12.5,
          height: 1.5,
          color: active
              ? Colors.white.withOpacity( 0.52)
              : Theme.of(context).colorScheme.onSurfaceVariant,
        ),
        child: Stack(
          alignment: Alignment.topCenter,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 26),
              child: Text(
                widget.hint,
                textAlign: TextAlign.center,
                maxLines: 2,
              ),
            ),
            Positioned.fill(
              child: AnimatedBuilder(
                animation: _ctrl,
                builder: (context, _) => CustomPaint(
                  painter: _FxPainter(
                    t: _ctrl.value,
                    kind: widget.kind,
                    theme: widget.theme,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FxPainter extends CustomPainter {
  _FxPainter({required this.t, required this.kind, required this.theme});

  final double t; // 0..1 循环
  final String? kind;
  final MemorialThemeDef theme;

  @override
  void paint(Canvas canvas, Size size) {
    switch (kind) {
      case 'bloom':
        _petals(canvas, size);
        _bouquet(canvas, size, sway: true);
        break;
      case 'candle':
      case 'diya':
        _glow(canvas, size, strength: 1);
        _candle(canvas, size, diya: kind == 'diya');
        break;
      case 'incense':
        _glow(canvas, size, strength: 0.5);
        _incense(canvas, size);
        break;
      case 'pray':
        _glow(canvas, size, strength: 0.8);
        _pray(canvas, size);
        break;
      case 'bow':
        _glow(canvas, size, strength: 0.6);
        _bow(canvas, size);
        break;
      case 'stone':
        _glow(canvas, size, strength: 0.5);
        _stone(canvas, size);
        break;
      case 'spark':
        _glow(canvas, size, strength: 0.6);
        _sparks(canvas, size);
        break;
    }
  }

  void _glow(Canvas canvas, Size size, {required double strength}) {
    final rect = Rect.fromCenter(
      center: Offset(size.width / 2, size.height * 0.62),
      width: size.width * 0.92,
      height: size.height * 1.2,
    );
    canvas.drawRect(
      rect,
      Paint()
        ..shader = RadialGradient(
          center: Alignment.center,
          radius: 0.55,
          colors: [theme.glow, theme.glow.withOpacity( 0)],
        ).createShader(rect),
    );
  }

  // ---- 花瓣 + 花束 ----

  void _petals(Canvas canvas, Size size) {
    const n = 8;
    for (var i = 0; i < n; i++) {
      final x = size.width * (0.18 + i * 0.09);
      final delay = i * 0.28 / 3.6; // 原型 delay i*0.28s / 周期 3.6s
      final local = ((t - delay) % 1.0 + 1.0) % 1.0;
      final y = -14 + local * (size.height + 40);
      final opacity = local < 0.12 ? local / 0.12 * 0.95 : (1 - local) * 1.15;
      final rot = local * 420 * math.pi / 180;
      final color = theme.bouquet[i % 3][0]
          .withOpacity(opacity.clamp(0.0, 0.95));
      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(rot);
      final path = Path()
        ..moveTo(0, -4.5)
        ..quadraticBezierTo(4.5, -4.5, 4.5, 0)
        ..quadraticBezierTo(4.5, 4.5, 0, 4.5)
        ..quadraticBezierTo(-4.5, 4.5, -4.5, 0)
        ..quadraticBezierTo(-4.5, -4.5, 0, -4.5);
      canvas.drawPath(path, Paint()..color = color);
      canvas.restore();
    }
  }

  void _bouquet(Canvas canvas, Size size, {required bool sway}) {
    const w = 134.0, h = 104.0;
    final scale = math.min(size.width / 190, size.height / 150);
    canvas.save();
    canvas.translate(size.width / 2, size.height - 8);
    if (sway) {
      final a = math.sin(t * 2 * math.pi) * 1.7 * math.pi / 180;
      canvas.rotate(a);
    }
    canvas.scale(scale, scale);
    canvas.translate(-w / 2, -h); // 原点 = 底部中心（transform-origin 50% 96% 近似）

    // 地面阴影
    canvas.drawOval(
      const Rect.fromLTRB(38, 96, 96, 103),
      Paint()..color = Colors.black.withOpacity( 0.08),
    );
    // 牛皮纸包装
    final wrap = Path()
      ..moveTo(38, 64)
      ..lineTo(96, 64)
      ..lineTo(87, 96)
      ..quadraticBezierTo(67, 101, 47, 96)
      ..close();
    canvas.drawPath(wrap, Paint()..color = const Color(0xFFE6D4B5));
    canvas.drawPath(
      wrap,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.3
        ..color = const Color(0xFFC7AF8B),
    );
    // 茎
    final stems = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.3
      ..strokeCap = StrokeCap.round
      ..color = const Color(0xFF5E8A63);
    final stemPath = Path()
      ..moveTo(46, 38)
      ..quadraticBezierTo(46, 48, 62, 64)
      ..moveTo(67, 24)
      ..lineTo(67, 64)
      ..moveTo(88, 38)
      ..quadraticBezierTo(88, 48, 72, 64);
    canvas.drawPath(stemPath, stems);
    // 叶
    final leaf = Paint()..color = const Color(0xFF6E9B72);
    canvas.drawPath(
      Path()
        ..moveTo(58, 55)
        ..quadraticBezierTo(44, 50, 40, 68)
        ..quadraticBezierTo(54, 68, 58, 55),
      leaf,
    );
    canvas.drawPath(
      Path()
        ..moveTo(76, 51)
        ..quadraticBezierTo(90, 46, 94, 64)
        ..quadraticBezierTo(80, 64, 76, 51),
      leaf,
    );
    // 三朵五瓣花
    const pos = [Offset(46, 38), Offset(67, 24), Offset(88, 38)];
    for (var i = 0; i < 3; i++) {
      final c = pos[i];
      final petal = theme.bouquet[i][0];
      final heart = theme.bouquet[i][1];
      for (var k = 0; k < 5; k++) {
        canvas.save();
        canvas.translate(c.dx, c.dy);
        canvas.rotate(k * 72 * math.pi / 180);
        canvas.translate(0, -6.6);
        canvas.drawOval(
          Rect.fromCenter(center: Offset.zero, width: 9.2, height: 13.2),
          Paint()..color = petal,
        );
        canvas.restore();
      }
      canvas.drawCircle(c, 3, Paint()..color = heart);
    }
    canvas.restore();
  }

  // ---- 蜡烛 / 油灯 ----

  void _candle(Canvas canvas, Size size, {required bool diya}) {
    final cx = size.width / 2;
    final baseY = size.height - 18;
    final bodyW = 42.0;
    final bodyH = diya ? 46.0 : 74.0;
    final bodyRect = Rect.fromLTWH(cx - bodyW / 2, baseY - bodyH, bodyW, bodyH);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        bodyRect,
        Radius.circular(diya ? 14 : 7),
      ),
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFF7F2E9), Color(0xFFDCD1C0)],
        ).createShader(bodyRect),
    );
    _flame(canvas, Offset(cx, bodyRect.top), diya ? 26 : 32);
  }

  void _flame(Canvas canvas, Offset tipBase, double height) {
    final flick = 1 + math.sin(t * 2 * math.pi * 2) * 0.08;
    final w = 20 * flick;
    final h = height * (1 - math.sin(t * 2 * math.pi * 2) * 0.05);
    final rect = Rect.fromCenter(
      center: Offset(tipBase.dx, tipBase.dy - h / 2 + 2),
      width: w,
      height: h,
    );
    final path = Path()
      ..moveTo(rect.center.dx, rect.top)
      ..quadraticBezierTo(rect.right, rect.center.dy, rect.center.dx, rect.bottom)
      ..quadraticBezierTo(rect.left, rect.center.dy, rect.center.dx, rect.top)
      ..close();
    canvas.drawPath(
      path,
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(0, 0.6),
          radius: 0.8,
          colors: [theme.wick, theme.flame, const Color(0xFFD2662A)],
          stops: const [0, 0.55, 1],
        ).createShader(rect)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1.2),
    );
  }

  // ---- 线香 ----

  void _incense(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final baseY = size.height - 12;
    final stickH = 104.0;
    final stickRect = Rect.fromLTWH(cx - 3.5, baseY - stickH, 7, stickH);
    canvas.drawRRect(
      RRect.fromRectAndRadius(stickRect, const Radius.circular(3.5)),
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF8B6B4A), Color(0xFF5C4530)],
        ).createShader(stickRect),
    );
    final ember = Offset(cx, baseY - stickH - 3);
    canvas.drawCircle(
      ember,
      4.5,
      Paint()..color = const Color(0xFFE8663A),
    );
    canvas.drawCircle(
      ember,
      9,
      Paint()..color = const Color(0xFFE8663A).withOpacity( 0.35),
    );
    // 三缕青烟
    for (var i = 0; i < 3; i++) {
      final delay = i / 3;
      final local = ((t - delay) % 1.0 + 1.0) % 1.0;
      final y = baseY - stickH - 10 - local * 88;
      final x = cx + local * 6 + math.sin((local + i * 0.33) * 2 * math.pi) * 5;
      final opacity =
          local < 0.18 ? local / 0.18 * 0.75 : (1 - local) / 0.82 * 0.75;
      final r = 8 + local * 18;
      canvas.drawCircle(
        Offset(x, y),
        r,
        Paint()
          ..color = const Color(0xFFE0DBD1)
              .withOpacity( opacity.clamp(0, 0.75)),
        // ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
      );
    }
  }

  // ---- 祈福 ----

  void _pray(Canvas canvas, Size size) {
    final breathe = 1 + math.sin(t * 2 * math.pi) * 0.014;
    final tp = TextPainter(
      text: const TextSpan(text: '🙏', style: TextStyle(fontSize: 60)),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(
      canvas,
      Offset(
        size.width / 2 - tp.width / 2,
        size.height - 38 - tp.height * breathe,
      ),
    );
    _sparks(canvas, size, bottomLimit: size.height - 110);
  }

  // ---- 鞠躬 ----

  void _bow(Canvas canvas, Size size) {
    // 周期 3.6s 内 42%~78% 区间完成前倾 9°（移植原型 keyframes）
    final phase = t;
    double angle = 0;
    if (phase > 0.42 && phase < 0.78) {
      final p = (phase - 0.42) / 0.36;
      angle = math.sin(p * math.pi) * 9 * math.pi / 180;
    }
    final scale = size.height / 134 * 0.9;
    canvas.save();
    canvas.translate(size.width / 2, size.height - 12);
    canvas.rotate(angle);
    canvas.scale(scale, scale);
    canvas.translate(-48, -94);

    final line = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round
      ..color = theme.accent;
    // 头
    canvas.drawCircle(
        const Offset(64, 23), 11, Paint()..color = theme.accent.withOpacity( 0.16));
    canvas.drawCircle(const Offset(64, 23), 11, line);
    // 躯干（前倾）
    canvas.drawPath(
      Path()
        ..moveTo(59, 34)
        ..quadraticBezierTo(44, 48, 38, 66),
      line,
    );
    // 腿脚
    canvas.drawPath(
      Path()
        ..moveTo(38, 66)
        ..lineTo(38, 85)
        ..moveTo(38, 85)
        ..lineTo(30, 91),
      line,
    );
    // 手臂
    canvas.drawPath(
      Path()
        ..moveTo(54, 40)
        ..quadraticBezierTo(62, 58, 58, 71),
      line,
    );
    // 地面
    canvas.drawLine(const Offset(14, 91), const Offset(82, 91),
        line..color = theme.accent.withOpacity( 0.3));
    canvas.restore();
  }

  // ---- 放石 ----

  void _stone(Canvas canvas, Size size) {
    final scale = size.width / 120 * 0.85;
    canvas.save();
    canvas.translate(size.width / 2, size.height - 24);
    canvas.scale(scale, scale);
    canvas.translate(-60, -78);

    final stones = [
      (const Offset(60, 65), 35.0, 14.0, const Color(0xFF8C857A), 0.0),
      (const Offset(45, 49), 25.0, 12.0, const Color(0xFFA29A8E), 0.26),
      (const Offset(71, 37), 19.0, 10.0, const Color(0xFFB7AFA2), 0.52),
    ];
    for (final (c, rx, ry, color, delay) in stones) {
      // 0.5s 内落下（周期 4s → delay/4 + 0.125 的窗口）
      final local = (t - delay / 4).clamp(0.0, 0.125) / 0.125;
      final drop = (1 - local) * -30;
      final sq = 1 - (1 - local) * 0.12;
      canvas.save();
      canvas.translate(c.dx, c.dy + drop);
      canvas.scale(1, sq);
      canvas.drawOval(
        Rect.fromCenter(center: Offset.zero, width: rx * 2, height: ry * 2),
        Paint()..color = color,
      );
      canvas.drawOval(
        Rect.fromCenter(
            center: Offset(0, -3), width: rx * 1.7, height: ry * 1.3),
        Paint()..color = Colors.white.withOpacity( 0.35),
      );
      canvas.restore();
    }
    canvas.restore();
  }

  // ---- 上升光点（祈福/回忆共用） ----

  void _sparks(Canvas canvas, Size size, {double bottomLimit = 100}) {
    final xs = [0.41, 0.57, 0.48, 0.53];
    for (var i = 0; i < 4; i++) {
      final delay = i * 0.7 / 3; // 原型 delay i*0.7s / 周期 3s
      final local = ((t - delay) % 1.0 + 1.0) % 1.0;
      final y = size.height - 72 - local * 84;
      final x = size.width * xs[i];
      final opacity =
          local < 0.22 ? local / 0.22 * 0.8 : (1 - local) / 0.78 * 0.8;
      final r = 5 + local * 6;
      canvas.drawCircle(
        Offset(x, y),
        r,
        Paint()
          ..color = theme.wick.withOpacity( opacity.clamp(0, 0.8)),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _FxPainter old) =>
      old.t != t || old.kind != kind || old.theme != theme;
}
