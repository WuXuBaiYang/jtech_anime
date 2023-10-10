import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:desktop/model/version.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:jtech_anime_base/base.dart';
import 'package:jtech_anime_base/manage/config.dart';

/*
* 应用版本检查
* @author wuxubaiyang
* @Time 2023/3/9 17:57
*/
class AppVersionTool {
  // 更新提示忽略缓存key
  static const String _ignoreUpdateKey = 'ignore_update_key';

  // 下载进度流
  static final StreamController<double> _downloadProgressController =
      StreamController.broadcast();

  // 获取下载进度流
  static Stream<double> get downloadProgressStream =>
      _downloadProgressController.stream;

  // 检查更新
  static Future<bool> check(BuildContext context,
      {bool immediately = false}) async {
    // 判断是否需要进行版本更新
    if (!immediately && (cache.getBool(_ignoreUpdateKey) ?? false)) {
      return false;
    }
    if (Platform.isWindows) return _checkWindowsUpdate(context);
    if (Platform.isMacOS) return _checkMacosUpdate(context);
    if (Platform.isLinux) return _checkLinuxUpdate(context);
    return false;
  }

  // 检查windows版本更新
  // 默认是调用我的账号下的更新服务器，这部分信息不开源，如有需要请自行重写以下内容
  static Future<bool> _checkWindowsUpdate(BuildContext context) async {
    final versionInfo = await _getLatestVersion(Platform.operatingSystem);
    if (versionInfo != null) {
      return versionInfo.checkUpdate().then((isUpdate) {
        final fileName = '${versionInfo.name}_${versionInfo.versionCode}.exe';
        if (isUpdate) _showUpdateDialog(context, versionInfo, fileName);
        return isUpdate;
      });
    }
    return false;
  }

  // 检查macos版本更新
  static Future<bool> _checkMacosUpdate(BuildContext context) {
    /// 等待开发
    return Future.value(false);
  }

  // 检查linux版本更新
  static Future<bool> _checkLinuxUpdate(BuildContext context) {
    /// 等待开发
    return Future.value(false);
  }

  // 检查当前平台最新版本
  static Future<AppVersion?> _getLatestVersion(String platform) async {
    try {
      final configJson =
          await rootBundle.loadString('assets/source/update_config.json');
      if (configJson.isNotEmpty) {
        final config = jsonDecode(configJson);
        final resp = await Dio().get(
          config['version_check_url'],
          options: Options(headers: {'apikey': config['api_key']}),
          queryParameters: {
            'limit': 1,
            'order': 'created_at.desc',
            'platform': 'eq.$platform',
          },
        );
        if (resp.statusCode == 200 && resp.data.isNotEmpty) {
          return AppVersion.from(resp.data.first);
        }
      }
    } catch (e) {
      LogTool.e('版本更新检查失败', error: e);
    }
    return null;
  }

  // 展示版本更新提示
  static Future<void> _showUpdateDialog(
      BuildContext context, AppVersion info, String fileName) {
    return MessageDialog.show(
      context,
      title: const Text('应用更新'),
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(info.changelog),
          const SizedBox(height: 14),
          Text(
            '${info.nameCN} · v${info.version} · ${info.fileSize}',
            textAlign: TextAlign.end,
            style: const TextStyle(color: Colors.grey, fontSize: 12),
          ),
        ],
      ),
      actionLeft: TextButton(
        onPressed: () {
          cache.setBool(_ignoreUpdateKey, true,
              expiration: const Duration(days: 7));
          router.pop();
        },
        child: const Text('一周内不提示'),
      ),
      actionMiddle: TextButton(
        onPressed: () => router.pop(),
        child: const Text('取消'),
      ),
      actionRight: TextButton(
        onPressed: () {
          router.pop();
          _installUpdate(context, info, fileName);
          SnackTool.showMessage(message: '正在下载安装包...');
        },
        child: const Text('更新'),
      ),
    );
  }

  // 下载并安装应用
  static Future<void> _installUpdate(
      BuildContext context, AppVersion info, String fileName) async {
    try {
      final savePath = await FileTool.getDirPath(
          join(globalConfig.baseCachePath, 'updates'),
          root: FileDir.applicationDocuments);
      if (savePath == null) return;
      final installFile = File(join(savePath, basename(info.installUrl)));
      final resp = await Dio().download(
        info.installUrl,
        installFile.path,
        onReceiveProgress: (count, total) =>
            _downloadProgressController.add(count / total),
      );
      _downloadProgressController.add(0);
      if (resp.statusCode == 200 && installFile.existsSync()) {
        // 使用命令启动已下载文件
        if (Platform.isWindows) Process.run(installFile.path, []);
        if (Platform.isMacOS) Process.run(installFile.path, []);
        if (Platform.isLinux) Process.run(installFile.path, []);
      }
    } catch (e) {
      LogTool.e('版本更新检查失败', error: e);
    }
  }
}
