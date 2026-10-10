import 'package:drift/drift.dart' show Value;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'db/app_database.dart';
import 'db/tables.dart';

/// 人物照片上传（阶段 3 媒体）：压缩 → Supabase Storage（私密桶）→ 本地记录路径。
/// 路径约定：tree_<treeId>/person_<personId>.jpg（RLS 按路径中的 tree_id 校验成员）。
class PhotoService {
  PhotoService(this._db, {required this.supabaseUrl});

  final AppDatabase _db;
  final String supabaseUrl;
  SupabaseClient get _client => Supabase.instance.client;

  static const bucket = 'person-photos';

  Future<String> storagePath(String treeId, String personId) =>
      Future.value('tree_$treeId/person_$personId.jpg');

  /// 压缩到最长边 1024 / 质量 80（规划文档：头像 ≤200KB）并上传，
  /// 成功后写本地 persons.avatarPath。返回存储路径。
  Future<String> uploadAvatar({
    required String treeId,
    required String personId,
    required String sourceFilePath,
  }) async {
    final path = await storagePath(treeId, personId);

    final compressed = await FlutterImageCompress.compressWithFile(
      sourceFilePath,
      minWidth: 1024,
      minHeight: 1024,
      quality: 80,
      format: CompressFormat.jpeg,
    );
    if (compressed == null) {
      throw Exception('compress failed');
    }

    await _client.storage.from(bucket).uploadBinary(
          path,
          compressed,
          fileOptions: const FileOptions(upsert: true, contentType: 'image/jpeg'),
        );

    await (_db.update(_db.persons)..where((p) => p.id.equals(personId))).write(
      PersonsCompanion(avatarPath: Value(path)),
    );
    return path;
  }

  /// 读取头像（私密桶 → 签名 URL，有效期 1 小时）。
  Future<String?> signedUrl(String? avatarPath) async {
    if (avatarPath == null || avatarPath.isEmpty) return null;
    try {
      final res = await _client.storage.from(bucket).createSignedUrl(
            avatarPath,
            3600,
          );
      // 签名 URL 形如 /object/sign/...?token=...，需要拼上主机
      return '\$supabaseUrl/storage/v1\$res';
    } catch (_) {
      return null;
    }
  }
}

/// Person 扩展：便于 UI 判断头像可用
extension PersonAvatarX on Person {
  bool get hasAvatar => avatarPath != null && avatarPath!.isNotEmpty;
}
