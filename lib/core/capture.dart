import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

/// 树画布截图（PNG/PDF 导出用）。TreeScreen 把画布包进 RepaintBoundary 并挂上这个 key。
final GlobalKey treeCaptureKey = GlobalKey();

/// 把树画布渲染为高清 PNG（pixelRatio 3 ≈ 1170px 宽）。
/// 包一层异常安全（画布未挂载/未绘制时返回 null）
Future<Uint8List?> captureTreePngSafe({double pixelRatio = 3.0}) async {
  try {
    return await captureTreePng(pixelRatio: pixelRatio);
  } catch (_) {
    return null;
  }
}

Future<Uint8List?> captureTreePng({double pixelRatio = 3.0}) async {
  final boundary = treeCaptureKey.currentContext?.findRenderObject()
      as RenderRepaintBoundary?;
  if (boundary == null || !boundary.hasSize || boundary.size.isEmpty) return null;
  final ui.Image image = await boundary.toImage(pixelRatio: pixelRatio);
  final ByteData? data =
      await image.toByteData(format: ui.ImageByteFormat.png);
  return data?.buffer.asUint8List();
}
