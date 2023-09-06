import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:jtech_anime/manage/notification.dart';
import 'package:jtech_anime/model/version.dart';
import 'package:jtech_anime_base/base.dart';
import 'package:ota_update/ota_update.dart';
import 'permission.dart';

/*
* 应用版本检查
* @author wuxubaiyang
* @Time 2023/3/9 17:57
*/
class AppVersionTool {
  // 更新提示忽略缓存key
  static const String _ignoreUpdateKey = 'ignore_update_key';

  // 检查更新
  static Future<bool> check(BuildContext context,
      {bool immediately = false}) async {
    // 判断是否需要进行版本更新
    if (!immediately && (cache.getBool(_ignoreUpdateKey) ?? false)) {
      return false;
    }
    if (Platform.isAndroid) return _checkAndroidUpdate(context);
    if (Platform.isIOS) return _checkIosUpdate(context);
    return false;
  }

  // 检查android的版本更新
  // 默认是调用我的账号下的更新服务器，这部分信息不开源，如有需要请自行重写以下内容
  static Future<bool> _checkAndroidUpdate(BuildContext context) async {
    final configJson =
        await rootBundle.loadString('assets/source/update_config.json');
    if (configJson.isEmpty) return false;
    final config = jsonDecode(configJson);
    final url = 'https://api.appmeta.cn/apps/latest/${config['id']}';
    final resp =
        await Dio().get(url, queryParameters: {'api_token': config['token']});
    if (resp.statusCode == 200) {
      final data = resp.data;
      final appVersion = AppVersion.from({
        'nameCN': data['name'],
        'version': data['versionShort'],
        'versionCode': int.tryParse(data['build']) ?? -1,
        'changelog': data['changelog'] ?? '',
        'fileLength': data['binary']['fsize'],
        'installUrl': data['install_url'],
      });
      return appVersion.checkUpdate().then((isUpdate) {
        if (isUpdate) {
          return _showAndroidUpdateDialog(context, appVersion)
              .then((value) => value ?? false);
        }
        return Future.value(false);
      });
    }
    return false;
  }

  // 展示版本更新提示
  static Future<bool?> _showAndroidUpdateDialog(
      BuildContext context, AppVersion info) {
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
          PermissionTool.checkAllGranted(context, permissions: [
            const PermissionRequest.androidManageExternalStorage(),
            const PermissionRequest.androidRequestInstallPackages(),
          ]).then((v) {
            if (!v) return SnackTool.showMessage(message: '未能获取到权限');
            router.pop(true);
            _installAndroidApk(context, info);
            SnackTool.showMessage(message: '正在下载安装包...');
          });
        },
        child: const Text('更新'),
      ),
    );
  }

  // 下载并安装apk
  static Future<void> _installAndroidApk(
      BuildContext context, AppVersion info) async {
    final progress = ValueChangeNotifier<int?>(null);
    const noticeTag = 9527;
    progress.addListener(() async {
      final v = progress.value;
      if (v == null) return notice.cancel(noticeTag);
      notice.showProgress(
        indeterminate: v < 0,
        maxProgress: 100,
        progress: v,
        id: noticeTag,
      );
    });
    progress.setValue(-1);
    try {
      OtaUpdate()
          .execute(info.installUrl,
              destinationFilename: '${info.name}_${info.versionCode}.apk',
              sha256checksum: info.sha256checksum)
          .listen((e) {
        switch (e.status) {
          case OtaStatus.DOWNLOADING:
            return progress.setValue(int.parse(e.value ?? '0'));
          case OtaStatus.INSTALLING:
          case OtaStatus.ALREADY_RUNNING_ERROR:
          case OtaStatus.PERMISSION_NOT_GRANTED_ERROR:
          case OtaStatus.INTERNAL_ERROR:
          case OtaStatus.DOWNLOAD_ERROR:
          case OtaStatus.CHECKSUM_ERROR:
            return progress.setValue(null);
        }
      });
    } catch (e) {
      LogTool.e('版本更新检查失败', error: e);
      progress.setValue(null);
    }
  }

  // 检查ios版本更新
  static Future<bool> _checkIosUpdate(BuildContext context) {
    return Future.value(false);
  }
}
