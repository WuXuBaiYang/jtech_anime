import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:jtech_anime/common/manage.dart';
import 'package:jtech_anime/model/version.dart';
import 'package:jtech_anime/tool/log.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'cache.dart';

/*
* supabase框架
* @author wuxubaiyang
* @Time 2022/3/17 14:14
*/
class SupabaseManage extends BaseManage {
  // 文件缓存前缀
  static const String _fileIdCacheKey = 'fileIdCache';

  // app更新检查缓存
  static const String _apkVersionCheckKey = 'apkVersionCheck';

  static final SupabaseManage _instance = SupabaseManage._internal();

  factory SupabaseManage() => _instance;

  // 客户端
  Supabase? _supabase;

  SupabaseManage._internal();

  // 缓存读取到的supabase信息（该信息不会上传到git，所以自行打包的开源版本无法接收到更新）
  Map? _supabaseInfo;

  @override
  Future<void> init() async {
    await _initSupabaseInfo();
    if (hasSupabaseInfo) {
      _supabase = await Supabase.initialize(
        url: _supabaseInfo!['baseUrl'],
        anonKey: _supabaseInfo!['anonKey'],
        debug: kDebugMode,
      );
    }
  }

  // 判断是否存在supabaseInfo
  bool get hasSupabaseInfo => _supabaseInfo != null;

  // 获取supabase信息
  Future<void> _initSupabaseInfo() async {
    try {
      final json = await rootBundle.loadString('assets/filter/supabase.json');
      _supabaseInfo = jsonDecode(json);
    } catch (e) {
      LogTool.e('开源版本不支持自动更新');
    }
  }

  // 获取最新的应用更新记录
  Future<AppVersion?> getLatestAppVersion() async {
    if (!hasSupabaseInfo) return null;
    var result = cache.getJson(_apkVersionCheckKey);
    if (kDebugMode || result == null) {
      result = await _supabase?.client
          .from(_supabaseInfo!['appVersionTable'])
          .select()
          .maybeSingle()
          .order('created_at');
      if (result == null) return null;
      await cache.setJsonMap(_apkVersionCheckKey, result,
          expiration: const Duration(hours: 6));
    }
    return AppVersion.from(result);
  }

  // 获取已签名的文件访问地址
  Future<String> _getSigneUrl(
    String bucket,
    String fileId, {
    int expiresIn = 60,
    TransformOptions? transform,
    Duration expiration = const Duration(days: 1),
    bool cached = true,
  }) async {
    if (!hasSupabaseInfo) return '';
    final cacheKey = _getFileCacheKey(fileId);
    var fileUrl = cache.getString(cacheKey);
    if (!cached || fileUrl == null) {
      fileUrl = await _supabase?.client.storage
          .from(bucket)
          .createSignedUrl(fileId, expiresIn, transform: transform);
      await cache.setString('${_fileIdCacheKey}_$fileId', fileUrl ?? '',
          expiration: expiration);
    }
    return fileUrl ?? '';
  }

  // 获取androidAPK下载地址
  Future<String> getAndroidAPKUrl(String fileId) =>
      _getSigneUrl(_supabaseInfo?['appVersionBucket'] ?? '', fileId,
          expiresIn: 60 * 5, cached: false);

  // 获取文件缓存key
  String _getFileCacheKey(String fileId) => '${_fileIdCacheKey}_$fileId';
}

// 单例调用
final supabase = SupabaseManage();
