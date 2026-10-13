import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'memorial_theme_defs.dart';

/// 05 缅怀页特效舞台 v2 —— 每种缅怀方式一套独立动效语言：
///  bloom   绽放：花束错峰绽放（回弹缓动）+ 三景深落瓣
///  candle  烛光：三层焰芯 + 噪声摆动 + 上升余烬 + 光晕呼吸
///  pray    祈福：呼吸光环 + 旋转祈环 + 光尘升腾（无 emoji，跨文化抽象）
///  incense 上香：铜炉三炷香 + 烬火明灭 + 卷曲青烟
///  bow     鞠躬：剪影 + 预备-俯身缓动 + 地面投影收缩
///  stone   叠石：错峰落石 + 落地尘烟 + 回弹
///  diya    油灯：陶盏焰光 + 星芒闪烁 + 浮瓣
///  spark   追忆：流萤光尘（利萨茹游移 + 明灭）
/// 全部 CustomPaint 自绘、零依赖；配色全部联动主题包。
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
      AnimationController(vsync: this, duration: const Duration(seconds: 6))
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
      height: 176,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
            color: active
                ? widget.theme.glow.withOpacity(0.55)
                : Theme.of(context).dividerColor),
        gradient: active
            ? LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [widget.theme.stageA, widget.theme.stageB])
            : null,
        color: active
            ? null
            : Theme.of(context).colorScheme.surfaceContainerHighest,
      ),
      child: AnimatedDefaultTextStyle(
        duration: const Duration(milliseconds: 400),
        style: TextStyle(
          fontSize: 12.5,
          height: 1.5,
          color: active
              ? Colors.white.withOpacity(0.5)
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
              child: ClipRRect(
                borderRadius: BorderRadius.circular(17),
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
            ),
          ],
        ),
      ),
    );
  }
}

// ---------- 缓动与粒子工具 ----------

double _easeInOut(double x) => 0.5 - 0.5 * math.cos(math.pi * x.clamp(0.0, 1.0));

/// 回弹缓动（绽放用）：1.70158 为标准 back-out 系数
double _backOut(double x) {
  final c1 = 1.70158, c3 = c1 + 1;
  final p = x.clamp(0.0, 1.0);
  return 1 + c3 * math.pow(p - 1, 3) + c1 * math.pow(p - 1, 2);
}

class _FxPainter extends CustomPainter {
  _FxPainter({required this.t, required this.kind, required this.theme});

  final double t; // 0..1 主循环（6s）
  final String? kind;
  final MemorialThemeDef theme;

  @override
  void paint(Canvas canvas, Size size) {
    if (kind == null) return;
    _vignette(canvas, size);
    switch (kind) {
      case 'bloom':
        _bloom(canvas, size);
        break;
      case 'candle':
      case 'diya':
        kind == 'diya' ? _diya(canvas, size) : _candle(canvas, size);
        break;
      case 'incense':
        _incense(canvas, size);
        break;
      case 'pray':
        _pray(canvas, size);
        break;
      case 'bow':
        _bow(canvas, size);
        break;
      case 'stone':
        _stone(canvas, size);
        break;
      case 'spark':
        _fireflies(canvas, size);
        break;
    }
  }

  // ---------- 共用绘制原语 ----------

  /// 三层同心软光点（近似高斯光斑，避免逐帧 shader 分配）
  void _softDot(Canvas canvas, Offset c, double r, Color color,
      {double core = 1}) {
    final p = Paint()..color = color.withOpacity(0.10 * core);
    canvas.drawCircle(c, r, p);
    canvas.drawCircle(c, r * 0.62, Paint()..color = color.withOpacity(0.22 * core));
    canvas.drawCircle(c, r * 0.32, Paint()..color = color.withOpacity(0.5 * core));
  }

  /// 呼吸系数：0.85~1.15 缓慢起伏
  double _breathe({double speed = 1, double phase = 0}) =>
      1 + math.sin((t * speed + phase) * 2 * math.pi) * 0.12;

  /// 地面光池
  void _groundPool(Canvas canvas, Size size, Color color, {double w = 0.66}) {
    final cy = size.height - 10;
    final rect = Rect.fromCenter(
        center: Offset(size.width / 2, cy),
        width: size.width * w * _breathe(speed: 0.5),
        height: 16);
    canvas.drawOval(
      rect,
      Paint()
        ..color = color.withOpacity(0.16),
    );
    canvas.drawOval(
      Rect.fromCenter(
          center: Offset(size.width / 2, cy),
          width: rect.width * 0.55,
          height: 9),
      Paint()..color = color.withOpacity(0.12),
    );
  }

  /// 四角暗角，聚拢视线
  void _vignette(Canvas canvas, Size size) {
    final g = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Colors.black.withOpacity(0.16),
          Colors.transparent,
          Colors.transparent,
          Colors.black.withOpacity(0.22),
        ],
        stops: const [0, 0.18, 0.78, 1],
      ).createShader(Offset.zero & size);
    canvas.drawRect(Offset.zero & size, g);
  }

  /// 火焰：外焰（主题色）→ 内焰（焰心色）→ 蓝色焰心，噪声摆动
  void _flame(
    Canvas canvas,
    Offset base, {
    required double h,
    required double phase,
    double scale = 1,
  }) {
    final n1 = math.sin((t * 2.3 + phase) * 2 * math.pi);
    final n2 = math.sin((t * 3.7 + phase * 1.7) * 2 * math.pi + 1.3);
    final sway = (n1 * 0.7 + n2 * 0.3) * 2.6 * scale;
    final stretch = 1 + n2 * 0.06;
    final fh = h * stretch;
    final fw = h * 0.52 * (1 - n1 * 0.05);

    Offset tip(double dx, double dy) => Offset(base.dx + dx * scale + sway * (1 - dy), base.dy - fh * dy);

    // 外焰
    final outer = Path()
      ..moveTo(base.dx, base.dy)
      ..quadraticBezierTo(
          base.dx - fw, base.dy - fh * 0.45, tip(0, 1).dx + sway * 0.4, tip(0, 1).dy)
      ..quadraticBezierTo(
          base.dx + fw, base.dy - fh * 0.45, base.dx, base.dy)
      ..close();
    canvas.drawPath(
      outer,
      Paint()
        ..color = theme.flame.withOpacity(0.85)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2.5),
    );
    // 中焰
    final mid = Path()
      ..moveTo(base.dx, base.dy)
      ..quadraticBezierTo(base.dx - fw * 0.6, base.dy - fh * 0.4,
          tip(0, 0.82).dx, tip(0, 0.82).dy)
      ..quadraticBezierTo(
          base.dx + fw * 0.6, base.dy - fh * 0.4, base.dx, base.dy)
      ..close();
    canvas.drawPath(mid, Paint()..color = theme.wick.withOpacity(0.9));
    // 焰心
    canvas.drawCircle(
      Offset(base.dx + sway * 0.2, base.dy - fh * 0.16),
      3.1 * scale,
      Paint()..color = Colors.white.withOpacity(0.85),
    );
    // 蓝色焰根
    canvas.drawCircle(
      Offset(base.dx, base.dy - 1.5 * scale),
      2.2 * scale,
      Paint()..color = const Color(0xFF7FB4E8).withOpacity(0.65),
    );
  }

  /// 上升余烬 / 光尘：沿正弦轨迹上升、渐显渐隐
  void _risingMotes(
    Canvas canvas,
    Size size, {
    required Color color,
    required int count,
    required double bottom,
    required double rise,
    double speed = 1,
    double sizeMul = 1,
    double regionW = 0.5,
  }) {
    for (var i = 0; i < count; i++) {
      final seed = i * 0.618;
      final local = ((t * speed + seed) % 1.0 + 1.0) % 1.0;
      final x0 = size.width * (0.5 + (seed * 2 - 1) * regionW * 0.5);
      final y = bottom - local * rise;
      final swayX = math.sin((local * 1.6 + seed * 3) * 2 * math.pi) * 7;
      final fadeIn = (local / 0.2).clamp(0.0, 1.0);
      final fadeOut = (1 - local).clamp(0.0, 1.0);
      final twinkle = 0.6 + 0.4 * math.sin((t * 3 + seed * 5) * 2 * math.pi);
      final alpha = (fadeIn * fadeOut * twinkle).clamp(0.0, 1.0);
      if (alpha <= 0.01) continue;
      _softDot(
        canvas,
        Offset(x0 + swayX, y),
        (1.6 + seed * 1.8) * sizeMul,
        color,
        core: alpha,
      );
    }
  }

  // ---------- bloom 绽放 ----------

  void _bloom(Canvas canvas, Size size) {
    _groundPool(canvas, size, theme.glow.withOpacity(1) == theme.glow ? theme.accent : theme.accent, w: 0.6);

    // 三景深落瓣（远→近）
    _petalLayer(canvas, size, count: 4, depth: 0.45, alpha: 0.32, speed: 0.7);
    _petalLayer(canvas, size, count: 5, depth: 0.75, alpha: 0.55, speed: 0.9);
    _petalLayer(canvas, size, count: 3, depth: 1.15, alpha: 0.9, speed: 1.15);

    _bouquet(canvas, size);
  }

  void _petalLayer(
    Canvas canvas,
    Size size, {
    required int count,
    required double depth,
    required double alpha,
    required double speed,
  }) {
    for (var i = 0; i < count; i++) {
      final seed = i * 0.37 + depth;
      final local = ((t * speed + seed) % 1.0 + 1.0) % 1.0;
      final x0 = size.width * (0.12 + (seed * 7 % 1.0) * 0.76);
      final y = -12 + local * (size.height + 30);
      final sway = math.sin((local * 1.3 + seed * 4) * 2 * math.pi) * 13 * depth;
      final fade = math.sin(local * math.pi).clamp(0.0, 1.0);
      final color = theme.bouquet[i % 3][0].withOpacity(0.85 * alpha * fade);
      canvas.save();
      canvas.translate(x0 + sway, y);
      canvas.rotate((local * 1.8 + seed) * 2 * math.pi);
      final s = 4.6 * depth;
      final petal = Path()
        ..moveTo(0, -s)
        ..quadraticBezierTo(s * 0.85, -s * 0.4, 0, s)
        ..quadraticBezierTo(-s * 0.85, -s * 0.4, 0, -s);
      canvas.drawPath(petal, Paint()..color = color);
      canvas.drawPath(
        petal,
        Paint()
          ..color = Colors.white.withOpacity(0.18 * alpha * fade)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.8,
      );
      canvas.restore();
    }
  }

  void _bouquet(Canvas canvas, Size size) {
    final scale = math.min(size.width / 200, (size.height - 44) / 150);
    final sway = math.sin(t * 2 * math.pi) * 1.6 * math.pi / 180;
    canvas.save();
    canvas.translate(size.width / 2, size.height - 14);
    canvas.rotate(sway);
    canvas.scale(scale, scale);
    canvas.translate(-67, -104);

    // 地面阴影
    canvas.drawOval(
      const Rect.fromLTRB(30.0, 98.0, 104.0, 106.0),
      Paint()..color = Colors.black.withOpacity(0.14),
    );

    // 花瓣绽放进度（错峰 + 回弹）
    final blooms = [
      for (var i = 0; i < 4; i++)
        _backOut(((t - i * 0.09) % 1.0 / 0.38).clamp(0.0, 1.0)).clamp(0.0, 1.3),
    ];

    // 茎（束成一捆）
    final stem = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.4
      ..strokeCap = StrokeCap.round
      ..color = const Color(0xFF5E8A63);
    canvas.drawPath(
      Path()
        ..moveTo(40, 44)
        ..quadraticBezierTo(43, 66, 60, 86)
        ..moveTo(67, 20)
        ..quadraticBezierTo(67, 48, 67, 86)
        ..moveTo(94, 40)
        ..quadraticBezierTo(91, 64, 74, 86)
        ..moveTo(54, 56)
        ..quadraticBezierTo(58, 72, 65, 86)
        ..moveTo(84, 58)
        ..quadraticBezierTo(78, 72, 70, 86),
      stem,
    );
    // 叶（含叶脉）
    final leaf = Paint()..color = const Color(0xFF6E9B72);
    for (final (x0, y0, flip) in [
      (58.0, 62.0, -1.0),
      (76.0, 60.0, 1.0),
      (48.0, 74.0, -1.0),
    ]) {
      canvas.save();
      canvas.translate(x0, y0);
      canvas.scale(flip, 1);
      canvas.drawPath(
        Path()
          ..moveTo(0, 0)
          ..quadraticBezierTo(-16, -4, -22, 10)
          ..quadraticBezierTo(-8, 12, 0, 0),
        leaf,
      );
      canvas.drawLine(
          Offset(-3, 2),
          Offset(-17, 7),
          Paint()
            ..color = Colors.white.withOpacity(0.25)
            ..strokeWidth = 0.8);
      canvas.restore();
    }

    // 牛皮纸包装（双层折角 + 缎带）
    final wrapBack = Path()
      ..moveTo(28, 62)
      ..lineTo(106, 62)
      ..lineTo(96, 100)
      ..quadraticBezierTo(67, 108, 38, 100)
      ..close();
    canvas.drawPath(wrapBack, Paint()..color = const Color(0xFFD9C49E));
    final wrapFront = Path()
      ..moveTo(34, 66)
      ..lineTo(100, 66)
      ..lineTo(92, 100)
      ..quadraticBezierTo(67, 107, 42, 100)
      ..close();
    canvas.drawPath(wrapFront, Paint()..color = const Color(0xFFE6D4B5));
    canvas.drawPath(
      wrapFront,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2
        ..color = const Color(0xFFC7AF8B),
    );
    // 缎带
    canvas.drawRRect(
      RRect.fromRectAndRadius(
          const Rect.fromLTRB(56, 84, 78, 92), const Radius.circular(2)),
      Paint()..color = theme.accent.withOpacity(0.9),
    );
    canvas.drawCircle(const Offset(67, 88), 3.4,
        Paint()..color = theme.accent);

    // 花：外圈 6 瓣 + 内圈 5 瓣（错相）+ 点点花心
    const centers = [Offset(40, 44), Offset(67, 20), Offset(94, 40), Offset(67, 46)];
    for (var i = 0; i < centers.length; i++) {
      final c = centers[i];
      final open = blooms[i].clamp(0.05, 1.25);
      final petal = theme.bouquet[i % 3][0];
      final heart = theme.bouquet[i % 3][1];
      canvas.save();
      canvas.translate(c.dx, c.dy);
      canvas.rotate(i * 0.7);
      canvas.scale(open.clamp(0.05, 1.0), open.clamp(0.05, 1.0));
      for (var k = 0; k < 6; k++) {
        canvas.save();
        canvas.rotate(k * 60 * math.pi / 180);
        canvas.translate(0, -7.4);
        canvas.drawOval(
          Rect.fromCenter(center: Offset.zero, width: 8.6, height: 12.6),
          Paint()..color = petal,
        );
        canvas.restore();
      }
      for (var k = 0; k < 5; k++) {
        canvas.save();
        canvas.rotate(k * 72 * math.pi / 180 + 0.5);
        canvas.translate(0, -4.2);
        canvas.drawOval(
          Rect.fromCenter(center: Offset.zero, width: 5.4, height: 7.6),
          Paint()..color = Color.lerp(petal, Colors.white, 0.35)!,
        );
        canvas.restore();
      }
      for (var k = 0; k < 5; k++) {
        final a = k * 72 * math.pi / 180;
        canvas.drawCircle(
          Offset(math.cos(a) * 1.6, math.sin(a) * 1.6),
          0.9,
          Paint()..color = heart,
        );
      }
      canvas.restore();
    }
    canvas.restore();
  }

  // ---------- candle 烛光 ----------

  void _candle(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final baseY = size.height - 22;

    // 背景呼吸光晕
    _halo(canvas, Offset(cx, baseY - 86), 64, theme.glow, strength: 0.9);
    _groundPool(canvas, size, theme.flame, w: 0.55);

    // 黄铜烛托
    final dish = Rect.fromCenter(
        center: Offset(cx, baseY + 4), width: 74, height: 10);
    canvas.drawOval(dish, Paint()..color = const Color(0xFF8A6E3E));
    canvas.drawOval(
      Rect.fromCenter(
          center: Offset(cx, baseY + 2.5), width: 62, height: 7),
      Paint()..color = const Color(0xFFB08D4F),
    );

    // 蜡身（圆柱明暗 + 顶部融蜡）
    final bodyTop = baseY - 66.0;
    final bodyRect = Rect.fromLTWH(cx - 20, bodyTop, 40, 66);
    canvas.drawRRect(
      RRect.fromRectAndRadius(bodyRect, const Radius.circular(6)),
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            const Color(0xFFCBBFA8),
            const Color(0xFFF7F2E9),
            const Color(0xFFD6CAB6),
          ],
          stops: const [0, 0.42, 1],
        ).createShader(bodyRect),
    );
    // 融蜡顶
    final wax = Path()
      ..moveTo(cx - 20, bodyTop + 6)
      ..quadraticBezierTo(cx - 12, bodyTop + 1, cx - 5, bodyTop + 4)
      ..quadraticBezierTo(cx, bodyTop + 8, cx + 6, bodyTop + 3)
      ..quadraticBezierTo(cx + 14, bodyTop - 1, cx + 20, bodyTop + 5)
      ..lineTo(cx + 20, bodyTop + 12)
      ..lineTo(cx - 20, bodyTop + 12)
      ..close();
    canvas.drawPath(wax, Paint()..color = const Color(0xFFF9F4EB));
    // 烛芯
    canvas.drawLine(
      Offset(cx, bodyTop + 3),
      Offset(cx, bodyTop - 3),
      Paint()
        ..color = const Color(0xFF3A3128)
        ..strokeWidth = 1.6
        ..strokeCap = StrokeCap.round,
    );

    _flame(canvas, Offset(cx, bodyTop - 2), h: 34, phase: 0);

    // 上升余烬
    _risingMotes(
      canvas,
      size,
      color: theme.flame,
      count: 3,
      bottom: bodyTop - 26,
      rise: 60,
      regionW: 0.22,
      sizeMul: 0.8,
    );
  }

  /// 大光晕（双层呼吸）
  void _halo(Canvas canvas, Offset c, double r, Color color,
      {required double strength}) {
    final breathe = _breathe(speed: 0.6);
    _softDot(canvas, c, r * 1.5 * breathe, color, core: 0.55 * strength);
    _softDot(canvas, c, r * 0.7 * breathe, color, core: 0.9 * strength);
  }

  // ---------- diya 油灯 ----------

  void _diya(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final baseY = size.height - 30;

    _halo(canvas, Offset(cx, baseY - 26), 52, theme.glow, strength: 1);
    _groundPool(canvas, size, theme.flame, w: 0.5);

    // 陶盏（宽碟形 + 侈口）
    final bowl = Path()
      ..moveTo(cx - 46, baseY - 6)
      ..quadraticBezierTo(cx - 40, baseY + 18, cx, baseY + 20)
      ..quadraticBezierTo(cx + 40, baseY + 18, cx + 46, baseY - 6)
      ..quadraticBezierTo(cx, baseY + 2, cx - 46, baseY - 6)
      ..close();
    canvas.drawPath(
      bowl,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [const Color(0xFFB4632E), const Color(0xFF7E3F1C)],
        ).createShader(Rect.fromLTWH(cx - 46, baseY - 6, 92, 26)),
    );
    // 皿口沿 + 油面
    canvas.drawOval(
      Rect.fromCenter(
          center: Offset(cx, baseY - 6), width: 92, height: 16),
      Paint()..color = const Color(0xFF8A4A22),
    );
    canvas.drawOval(
      Rect.fromCenter(
          center: Offset(cx, baseY - 6), width: 78, height: 11),
      Paint()..color = const Color(0xFF5C3016),
    );
    // 油面高光
    canvas.drawOval(
      Rect.fromCenter(
          center: Offset(cx - 14, baseY - 7), width: 26, height: 3.4),
      Paint()..color = Colors.white.withOpacity(0.16),
    );

    _flame(canvas, Offset(cx, baseY - 10), h: 26, phase: 0.4, scale: 0.92);

    // 环绕星芒（四芒星，明灭）
    for (var i = 0; i < 4; i++) {
      final seed = i * 0.25;
      final tw = math.sin((t * (1.2 + i * 0.35) + seed * 4) * 2 * math.pi);
      if (tw < 0.1) continue;
      final a = seed * 2 * math.pi + t * 0.6;
      final c = Offset(
        cx + math.cos(a) * 58,
        baseY - 14 + math.sin(a * 1.3) * 16,
      );
      _star(canvas, c, 3.4 + tw * 1.4, theme.wick.withOpacity(tw.clamp(0.0, 1.0)));
    }

    // 浮瓣（油面两侧轻晃）
    for (var i = 0; i < 2; i++) {
      final side = i == 0 ? -1.0 : 1.0;
      final bob = math.sin((t + i * 0.5) * 2 * math.pi) * 1.6;
      final c = Offset(cx + side * 34, baseY - 5 + bob);
      canvas.save();
      canvas.translate(c.dx, c.dy);
      canvas.rotate(side * 0.5 + bob * 0.08);
      canvas.drawOval(
        Rect.fromCenter(center: Offset.zero, width: 9, height: 5.4),
        Paint()..color = theme.bouquet[0][0].withOpacity(0.85),
      );
      canvas.restore();
    }
  }

  void _star(Canvas canvas, Offset c, double r, Color color) {
    final p = Path()
      ..moveTo(c.dx, c.dy - r)
      ..quadraticBezierTo(c.dx + r * 0.18, c.dy - r * 0.18, c.dx + r, c.dy)
      ..quadraticBezierTo(c.dx + r * 0.18, c.dy + r * 0.18, c.dx, c.dy + r)
      ..quadraticBezierTo(c.dx - r * 0.18, c.dy + r * 0.18, c.dx - r, c.dy)
      ..quadraticBezierTo(c.dx - r * 0.18, c.dy - r * 0.18, c.dx, c.dy - r);
    canvas.drawPath(p, Paint()..color = color);
  }

  // ---------- incense 上香 ----------

  void _incense(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final baseY = size.height - 24;

    _groundPool(canvas, size, theme.accent, w: 0.42);
    _halo(canvas, Offset(cx, baseY - 88), 40, theme.glow, strength: 0.5);

    // 铜炉（鼓腹 + 圈足 + 口沿）
    final potC = Offset(cx, baseY - 2);
    canvas.drawOval(
      Rect.fromCenter(center: potC, width: 62, height: 12),
      Paint()..color = Colors.black.withOpacity(0.18),
    );
    final pot = Path()
      ..moveTo(cx - 26, baseY - 10)
      ..quadraticBezierTo(cx - 24, baseY + 14, cx, baseY + 15)
      ..quadraticBezierTo(cx + 24, baseY + 14, cx + 26, baseY - 10)
      ..close();
    canvas.drawPath(
      pot,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            const Color(0xFF6E5433),
            const Color(0xFFC9A05E),
            const Color(0xFF7A5C36),
          ],
          stops: const [0, 0.45, 1],
        ).createShader(Rect.fromLTWH(cx - 26, baseY - 10, 52, 25)),
    );
    canvas.drawOval(
      Rect.fromCenter(
          center: Offset(cx, baseY - 10), width: 54, height: 9),
      Paint()..color = const Color(0xFF3E2F1B),
    );
    canvas.drawOval(
      Rect.fromCenter(
          center: Offset(cx, baseY - 9), width: 44, height: 6),
      Paint()..color = const Color(0xFFC9A05E).withOpacity(0.5),
    );
    // 圈足
    canvas.drawRRect(
      RRect.fromRectAndRadius(
          Rect.fromLTWH(cx - 12, baseY + 13, 24, 5), const Radius.circular(2)),
      Paint()..color = const Color(0xFF6E5433),
    );

    // 三炷香（错落扇形）
    final sticks = [
      (dx: -9.0, h: 92.0, phase: 0.0),
      (dx: 0.0, h: 102.0, phase: 0.33),
      (dx: 9.0, h: 86.0, phase: 0.66),
    ];
    for (final s in sticks) {
      final sx = cx + s.dx;
      final topY = baseY - 10 - s.h;
      final stickRect = Rect.fromLTWH(sx - 1.8, topY, 3.6, s.h);
      canvas.drawRRect(
        RRect.fromRectAndRadius(stickRect, const Radius.circular(1.8)),
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [const Color(0xFF7A5C3E), const Color(0xFF4E3826)],
          ).createShader(stickRect),
      );
      // 烬火（明灭）
      final pulse = 0.55 + 0.45 * math.sin((t * 1.8 + s.phase) * 2 * math.pi);
      final ember = Offset(sx, topY - 1);
      canvas.drawCircle(ember, 2.4,
          Paint()..color = const Color(0xFFE8663A).withOpacity(0.9));
      _softDot(canvas, ember, 7 * pulse, const Color(0xFFE8663A),
          core: 0.8 * pulse);
    }

    // 三缕卷曲青烟（烟团沿摆动线上升 + 一条连续细烟丝）
    for (var i = 0; i < 3; i++) {
      final s = sticks[i];
      final sx = cx + s.dx;
      final startY = baseY - 12 - s.h;
      for (var k = 0; k < 8; k++) {
        final seed = k / 8 + s.phase * 0.1;
        final local = ((t * 0.85 + seed) % 1.0 + 1.0) % 1.0;
        final y = startY - 6 - local * 92;
        final grow = local * 1.0;
        // 卷曲：双频正弦叠加，越升摆幅越大
        final x = sx +
            math.sin(grow * 3.1 + s.phase * 5) * (3 + grow * 13) +
            math.sin(grow * 7.7 + 1.7) * 2.2;
        final fadeIn = (local / 0.16).clamp(0.0, 1.0);
        final fadeOut = (1 - local).clamp(0.0, 1.0);
        final alpha = fadeIn * fadeOut * 0.5;
        if (alpha <= 0.01) continue;
        _softDot(
          canvas,
          Offset(x, y),
          3.2 + grow * 12,
          const Color(0xFFDCD6CB),
          core: alpha,
        );
      }
      // 连续烟丝（贝塞尔细线，低透明度）
      final wisp = Path()..moveTo(sx, startY - 4);
      for (var step = 1; step <= 8; step++) {
        final g = step / 8;
        wisp.lineTo(
          sx +
              math.sin(g * 3.1 + s.phase * 5) * (3 + g * 13) +
              math.sin(g * 7.7 + 1.7) * 2.2,
          startY - 4 - g * 88,
        );
      }
      canvas.drawPath(
        wisp,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.1
          ..color = const Color(0xFFDCD6CB).withOpacity(0.14),
      );
    }
  }

  // ---------- pray 祈福 ----------

  void _pray(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height * 0.44;

    _halo(canvas, Offset(cx, cy), 56, theme.glow, strength: 1);
    _groundPool(canvas, size, theme.glow, w: 0.4);

    // 旋转祈环（双细环反向微旋，如经轮/祷告环）
    final ring = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.1
      ..color = theme.wick.withOpacity(0.34);
    canvas.save();
    canvas.translate(cx, cy);
    canvas.rotate(t * 2 * math.pi * 0.08);
    canvas.drawOval(
        Rect.fromCenter(center: Offset.zero, width: 96, height: 34), ring);
    canvas.rotate(-t * 2 * math.pi * 0.16);
    canvas.drawOval(
        Rect.fromCenter(center: Offset.zero, width: 120, height: 44),
        ring..color = theme.wick.withOpacity(0.2));
    canvas.restore();

    // 环上光珠（沿环游移）
    for (var i = 0; i < 3; i++) {
      final a = t * 2 * math.pi * 0.5 + i * 2.09;
      final p = Offset(cx + math.cos(a) * 48, cy + math.sin(a) * 17);
      _softDot(canvas, p, 5.5, theme.wick, core: 0.9);
    }

    // 光尘升腾
    _risingMotes(
      canvas,
      size,
      color: theme.wick,
      count: 9,
      bottom: size.height - 46,
      rise: size.height * 0.72,
      regionW: 0.6,
      speed: 0.8,
    );

    // 顶部垂落光带
    final beam = Rect.fromLTWH(cx - 34, 0, 68, cy + 10);
    canvas.drawRect(
      beam,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            theme.wick.withOpacity(0.14),
            theme.wick.withOpacity(0),
          ],
        ).createShader(beam),
    );
  }

  // ---------- bow 鞠躬 ----------

  void _bow(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final baseY = size.height - 22;

    _groundPool(canvas, size, theme.accent, w: 0.4);
    _halo(canvas, Offset(cx, baseY - 62), 46, theme.glow, strength: 0.45);

    // 预备-俯身-起身（30%~72% 区间完成一个周期，ease in out）
    final phase = t;
    double bend = 0;
    if (phase > 0.28 && phase < 0.74) {
      final p = ((phase - 0.28) / 0.46).clamp(0.0, 1.0);
      bend = _easeInOut(p);
    }
    final angle = bend * 14 * math.pi / 180;
    final breathe = _breathe(speed: 0.5);

    // 地面投影（随俯身收缩变深）
    final shadowW = 44 - bend * 14;
    canvas.drawOval(
      Rect.fromCenter(
          center: Offset(cx, baseY + 3), width: shadowW, height: 7),
      Paint()..color = Colors.black.withOpacity(0.16 + bend * 0.1),
    );

    final scale = (size.height - 60) / 96;
    canvas.save();
    canvas.translate(cx, baseY);
    canvas.scale(scale, scale);
    // 原点 = 脚底
    canvas.save();
    canvas.translate(0, -2);
    canvas.rotate(angle); // 绕脚踝前倾

    final body = Paint()
        ..color = theme.accent.withOpacity((0.88 * breathe).clamp(0.0, 1.0));
    final rim = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = theme.wick.withOpacity(0.35);

    // 剪影：头（圆）+ 躯干 + 双腿
    canvas.drawCircle(const Offset(0, -57), 7.4, body);
    canvas.drawCircle(const Offset(0, -57), 7.4, rim);
    // 躯干与腿
    final torso = Path()
      ..moveTo(-7, -50)
      ..quadraticBezierTo(-9, -38, -8, -26)
      ..quadraticBezierTo(-7.4, -18, -6, -12)
      ..lineTo(6, -12)
      ..quadraticBezierTo(7.4, -18, 8, -26)
      ..quadraticBezierTo(9, -38, 7, -50)
      ..quadraticBezierTo(0, -53.5, -7, -50)
      ..close();
    canvas.drawPath(torso, body);
    canvas.drawPath(torso, rim);
    // 双腿
    final legs = Path()
      ..moveTo(-5.4, -12)
      ..lineTo(-5.8, -1)
      ..lineTo(-1.6, -1)
      ..lineTo(-1, -12)
      ..moveTo(1.4, -12)
      ..lineTo(1.8, -1)
      ..lineTo(6, -1)
      ..lineTo(5.2, -12)
      ..close();
    canvas.drawPath(legs, body);
    // 合十的手（胸前一枚小光点）
    _softDot(canvas, Offset(0, -40), 4.6, theme.wick, core: 0.95);
    canvas.restore();
    canvas.restore();

    // 环绕微尘
    _risingMotes(
      canvas,
      size,
      color: theme.accent,
      count: 3,
      bottom: baseY - 8,
      rise: 54,
      regionW: 0.6,
      sizeMul: 0.7,
      speed: 0.7,
    );
  }

  // ---------- stone 叠石 ----------

  void _stone(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final baseY = size.height - 26;

    _groundPool(canvas, size, theme.accent, w: 0.46);
    _halo(canvas, Offset(cx, baseY - 44), 42, theme.glow, strength: 0.5);

    final scale = math.min(size.width / 190, (size.height - 56) / 120);
    canvas.save();
    canvas.translate(cx, baseY);
    canvas.scale(scale, scale);
    canvas.translate(-60, -84);

    // 地面影
    canvas.drawOval(
      const Rect.fromLTRB(26, 78, 94, 86),
      Paint()..color = Colors.black.withOpacity(0.16),
    );

    // 三块叠石：错峰落下 + 尘烟 + 回弹
    final stones = [
      (c: const Offset(60, 66), rx: 34.0, ry: 13.0,
       color: const Color(0xFF8C857A), delay: 0.0),
      (c: const Offset(45, 47), rx: 24.0, ry: 11.0,
       color: const Color(0xFFA29A8E), delay: 0.3),
      (c: const Offset(72, 32), rx: 18.0, ry: 9.0,
       color: const Color(0xFFB7AFA2), delay: 0.6),
    ];
    for (final s in stones) {
      // 每块 0.9 单位窗口内完成 落下→触地→回弹
      final local = ((t + s.delay) % 1.0);
      double drop = 0;
      double squash = 1;
      if (local < 0.16) {
        final p = local / 0.16;
        drop = (1 - _easeInOut(p)) * -46;
        if (p > 0.92) squash = 1 - (p - 0.92) * 1.2;
      } else if (local < 0.28) {
        final p = (local - 0.16) / 0.12;
        squash = 1 + math.sin(p * math.pi) * 0.1; // 落定回弹
      }
      // 落地尘烟（触地窗口内一圈扩散软点）
      if (local > 0.13 && local < 0.3) {
        final dp = (local - 0.13) / 0.17;
        for (var k = 0; k < 4; k++) {
          final a = k * 1.57 + 0.4;
          _softDot(
            canvas,
            Offset(s.c.dx + math.cos(a) * (14 + dp * 22),
                s.c.dy + s.ry + math.sin(a) * 4 - dp * 6),
            3 + dp * 5,
            const Color(0xFFCFC8BC),
            core: (1 - dp) * 0.5,
          );
        }
      }
      canvas.save();
      canvas.translate(s.c.dx, s.c.dy + drop);
      canvas.scale(1, squash);
      canvas.drawOval(
        Rect.fromCenter(center: Offset.zero, width: s.rx * 2, height: s.ry * 2),
        Paint()..color = s.color,
      );
      // 顶面高光 + 底部阴影
      canvas.drawOval(
        Rect.fromCenter(
            center: Offset(-s.rx * 0.14, -s.ry * 0.3),
            width: s.rx * 1.5,
            height: s.ry * 1.15),
        Paint()..color = Colors.white.withOpacity(0.3),
      );
      canvas.drawOval(
        Rect.fromCenter(
            center: Offset(s.rx * 0.2, s.ry * 0.42),
            width: s.rx * 1.3,
            height: s.ry * 0.9),
        Paint()..color = Colors.black.withOpacity(0.1),
      );
      canvas.restore();
    }
    canvas.restore();

    // 雾尘微光
    _risingMotes(
      canvas,
      size,
      color: theme.wick,
      count: 3,
      bottom: baseY - 10,
      rise: 48,
      regionW: 0.5,
      sizeMul: 0.6,
      speed: 0.55,
    );
  }

  // ---------- spark 追忆（流萤） ----------

  void _fireflies(Canvas canvas, Size size) {
    _halo(canvas, Offset(size.width / 2, size.height * 0.46), 46, theme.glow,
        strength: 0.5);

    for (var i = 0; i < 7; i++) {
      final seed = i * 1.618;
      final a = 0.9 + (seed % 1.0) * 0.5;
      final b = 0.6 + (seed * 1.7 % 1.0) * 0.4;
      final x = size.width / 2 +
          math.sin((t * a + seed) * 2 * math.pi) * size.width * 0.3;
      final y = size.height * 0.28 +
          math.sin((t * b + seed * 2.3) * 2 * math.pi) * size.height * 0.26 +
          i * 4;
      final tw = math.sin((t * (1.1 + seed % 1.0) + seed) * 2 * math.pi);
      final alpha = ((tw + 1) / 2).clamp(0.0, 1.0);
      if (alpha < 0.08) continue;
      _softDot(
        canvas,
        Offset(x, y),
        3.4 + (seed % 1.0) * 2.4,
        theme.wick,
        core: alpha,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _FxPainter old) =>
      old.t != t || old.kind != kind || old.theme != theme;
}
