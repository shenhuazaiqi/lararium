import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/db/app_database.dart';
import '../../data/providers.dart';
import '../tree/tree_painter.dart' show avatarColorsFor, desaturate;

/// 通用照片头像：有照片（签名 URL）→ 圆形照片；否则字母渐变。
/// 已故 → 去饱和。[photoService] 由调用方传入（读签名 URL）。
class PhotoAvatar extends ConsumerStatefulWidget {
  const PhotoAvatar({
    super.key,
    required this.person,
    required this.size,
    required this.fontSize,
  });

  final Person person;
  final double size;
  final double fontSize;

  @override
  ConsumerState<PhotoAvatar> createState() => _PhotoAvatarState();
}

class _PhotoAvatarState extends ConsumerState<PhotoAvatar> {
  late Future<String?> _urlFuture;

  @override
  void didUpdateWidget(covariant PhotoAvatar old) {
    super.didUpdateWidget(old);
    if (old.person.avatarPath != widget.person.avatarPath) {
      _urlFuture = _fetch();
    }
  }

  @override
  void initState() {
    super.initState();
    _urlFuture = _fetch();
  }

  Future<String?> _fetch() =>
      ref.read(photoServiceProvider).signedUrl(widget.person.avatarPath);

  @override
  Widget build(BuildContext context) {
    // 上传新头像后 epoch 自增 → 重新签名 URL 拉取（路径固定不变）
    ref.listen(avatarEpochProvider, (_, __) {
      setState(() => _urlFuture = _fetch());
    });
    final p = widget.person;
    final dead = !p.isLiving;
    final palette = avatarColorsFor(p.id);
    final gradColors = dead
        ? [desaturate(palette[0]), desaturate(palette[1])]
        : palette;

    final hasPhoto = p.avatarPath != null && p.avatarPath!.isNotEmpty;
    final initials = ((p.givenName.isNotEmpty ? p.givenName[0] : '') +
            (p.surname.isNotEmpty ? p.surname[0] : ''))
        .toUpperCase();

    final fallback = Container(
      width: widget.size,
      height: widget.size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: gradColors,
        ),
      ),
      child: Text(initials,
          style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: widget.fontSize)),
    );

    if (!hasPhoto) return fallback;

    return FutureBuilder<String?>(
      future: _urlFuture,
      builder: (context, snap) {
        final url = snap.data;
        if (url == null) return fallback;
        return ClipOval(
          child: CachedNetworkImage(
            imageUrl: url,
            width: widget.size,
            height: widget.size,
            fit: BoxFit.cover,
            errorWidget: (_, __, ___) => fallback,
          ),
        );
      },
    );
  }
}
