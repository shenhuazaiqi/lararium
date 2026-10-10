import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';

/// 上传头像前的自定义裁剪页：拖动 + 双指缩放 + 90° 旋转，
/// 方形框内即保留区域，确认后输出 1024×1024 JPEG 字节。
/// 纯 Flutter 实现（dart:ui 画布裁剪），不依赖原生裁剪库。
class AvatarCropScreen extends StatefulWidget {
  const AvatarCropScreen({super.key, required this.imageBytes});

  final Uint8List imageBytes;

  /// 打开裁剪页；确认返回裁剪字节，取消返回 null。
  static Future<Uint8List?> push(BuildContext context, Uint8List bytes) =>
      Navigator.of(context).push<Uint8List>(MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => AvatarCropScreen(imageBytes: bytes),
      ));

  @override
  State<AvatarCropScreen> createState() => _AvatarCropScreenState();
}

class _AvatarCropScreenState extends State<AvatarCropScreen> {
  ui.Image? _src;
  double _scale = 1; // 用户缩放（1 = 恰好铺满方框）
  Offset _offset = Offset.zero; // 图像中心相对方框中心的偏移
  double _boxSize = 0; // 裁剪方框边长（build 时按可用空间计算）
  bool _exporting = false;

  // 手势起始基准
  double? _startScale;
  Offset? _startOffset;
  Offset? _startFocal;

  static const _outSize = 1024;

  @override
  void initState() {
    super.initState();
    _decode();
  }

  Future<void> _decode() async {
    final codec = await ui.instantiateImageCodec(widget.imageBytes);
    final frame = await codec.getNextFrame();
    if (!mounted) return;
    setState(() => _src = frame.image);
  }

  double get _baseScale {
    final img = _src!;
    return _boxSize / math.min(img.width, img.height);
  }

  /// 约束：图像始终完全盖住方框。
  void _clamp() {
    if (_src == null) return;
    final img = _src!;
    _scale = _scale.clamp(1.0, 8.0);
    final total = _baseScale * _scale;
    final maxDx =
        math.max(0.0, (img.width * total - _boxSize) / 2);
    final maxDy =
        math.max(0.0, (img.height * total - _boxSize) / 2);
    _offset = Offset(
      _offset.dx.clamp(-maxDx, maxDx),
      _offset.dy.clamp(-maxDy, maxDy),
    );
  }

  /// 图像在裁剪区坐标系中的绘制矩形。
  Rect get _imageRect {
    final img = _src!;
    final total = _baseScale * _scale;
    final dispW = img.width * total;
    final dispH = img.height * total;
    // _offset 是"图像中心 - 方框中心"；裁剪区局部坐标以方框左上为原点
    final cx = _boxSize / 2 + _offset.dx;
    final cy = _boxSize / 2 + _offset.dy;
    return Rect.fromCenter(
        center: Offset(cx, cy), width: dispW, height: dispH);
  }

  Future<void> _rotate() async {
    final img = _src;
    if (img == null || _exporting) return;
    final recorder = ui.PictureRecorder();
    ui.Canvas(recorder)
      ..translate(img.height.toDouble(), 0)
      ..rotate(math.pi / 2)
      ..drawImage(img, Offset.zero, Paint());
    final rotated =
        await recorder.endRecording().toImage(img.height, img.width);
    if (!mounted) return;
    setState(() {
      _src = rotated;
      _scale = 1;
      _offset = Offset.zero;
    });
  }

  /// 按当前框位置裁剪 → 1024×1024 → JPEG 压缩 → 返回字节。
  Future<void> _confirm() async {
    final img = _src;
    if (img == null || _exporting) return;
    setState(() => _exporting = true);
    try {
      final rect = _imageRect;
      final total = _baseScale * _scale;
      // 框（局部 0,0..boxSize）映射回源图像素坐标
      final src = Rect.fromLTWH(
        -rect.left / total,
        -rect.top / total,
        _boxSize / total,
        _boxSize / total,
      );
      final recorder = ui.PictureRecorder();
      ui.Canvas(recorder).drawImageRect(
        img,
        src,
        Offset.zero &
            Size(_outSize.toDouble(), _outSize.toDouble()),
        Paint()..filterQuality = ui.FilterQuality.high,
      );
      final rendered = await recorder.endRecording().toImage(_outSize, _outSize);
      final png =
          await rendered.toByteData(format: ui.ImageByteFormat.png);
      rendered.dispose();
      if (png == null) throw Exception('encode failed');
      final jpeg = await FlutterImageCompress.compressWithList(
        png.buffer.asUint8List(),
        quality: 80,
        format: CompressFormat.jpeg,
      );
      if (!mounted) return;
      Navigator.of(context).pop(Uint8List.fromList(jpeg));
    } catch (_) {
      if (!mounted) return;
      setState(() => _exporting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Crop failed')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: const Color(0xFF141414),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(l10n.cropTitle,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
        actions: [
          IconButton(
            tooltip: l10n.cropRotate,
            onPressed: _rotate,
            icon: const Icon(Icons.rotate_right),
          ),
        ],
      ),
      body: _src == null
          ? const Center(child: CircularProgressIndicator(color: Colors.white))
          : LayoutBuilder(builder: (context, cons) {
              _boxSize =
                  math.min(cons.maxWidth, cons.maxHeight) - 24;
              return GestureDetector(
                behavior: HitTestBehavior.opaque,
                onScaleStart: (d) {
                  _startScale = _scale;
                  _startOffset = _offset;
                  _startFocal = d.focalPoint;
                },
                onScaleUpdate: (d) {
                  if (_startScale == null) return;
                  setState(() {
                    _scale = _startScale! * d.scale;
                    _offset = _startOffset! + (d.focalPoint - _startFocal!);
                    _clamp();
                  });
                },
                child: CustomPaint(
                  size: Size(cons.maxWidth, cons.maxHeight),
                  painter: _CropPainter(
                    image: _src!,
                    imageRect: _imageRect,
                    boxSize: _boxSize,
                  ),
                ),
              );
            }),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 14),
          child: Row(
            children: [
              TextButton(
                onPressed:
                    _exporting ? null : () => Navigator.of(context).pop(),
                child: Text(l10n.cancel,
                    style: const TextStyle(
                        color: Colors.white70, fontSize: 15)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    minimumSize: const Size.fromHeight(48),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(13)),
                  ),
                  onPressed: _exporting ? null : _confirm,
                  child: _exporting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.black54),
                        )
                      : Text(l10n.cropConfirm,
                          style: const TextStyle(
                              fontSize: 15.5,
                              fontWeight: FontWeight.w600)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 底图 + 方形暗化遮罩 + 三分线 + 圆形参考线（头像最终以圆形显示）。
class _CropPainter extends CustomPainter {
  _CropPainter({
    required this.image,
    required this.imageRect,
    required this.boxSize,
  });

  final ui.Image image;
  final Rect imageRect;
  final double boxSize;

  @override
  void paint(Canvas canvas, Size size) {
    // 图像可超出边界，必须裁剪在本区域内的部分
    canvas.clipRect(Offset.zero & size);
    canvas.drawRect(Offset.zero & size, Paint()..color = Colors.black);
    canvas.drawImageRect(
      image,
      Offset.zero &
          Size(image.width.toDouble(), image.height.toDouble()),
      imageRect,
      Paint()..filterQuality = ui.FilterQuality.medium,
    );

    final box = Rect.fromLTWH(
      (size.width - boxSize) / 2,
      (size.height - boxSize) / 2,
      boxSize,
      boxSize,
    );

    // 框外暗化
    final mask = Path()
      ..fillType = PathFillType.evenOdd
      ..addRect(Offset.zero & size)
      ..addRRect(RRect.fromRectAndRadius(
          box, const Radius.circular(18)));
    canvas.drawPath(mask, Paint()..color = Colors.black54);

    final line = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    // 三分线
    line.color = Colors.white24;
    for (final t in [1 / 3, 2 / 3]) {
      canvas.drawLine(
          Offset(box.left + box.width * t, box.top),
          Offset(box.left + box.width * t, box.bottom),
          line);
      canvas.drawLine(
          Offset(box.left, box.top + box.height * t),
          Offset(box.right, box.top + box.height * t),
          line);
    }

    // 圆形参考线（对应头像的圆形裁剪显示）
    line.color = Colors.white38;
    canvas.drawCircle(box.center, box.width * 0.43, line);

    // 边框
    line.color = Colors.white70;
    line.strokeWidth = 1.5;
    canvas.drawRRect(
        RRect.fromRectAndRadius(box, const Radius.circular(18)), line);
  }

  @override
  bool shouldRepaint(_CropPainter old) =>
      old.image != image ||
      old.imageRect != imageRect ||
      old.boxSize != boxSize;
}
