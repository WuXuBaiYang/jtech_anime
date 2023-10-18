import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:jtech_anime_base/base.dart';
import 'package:jtech_anime_base/manage/cache.dart';
import 'package:jtech_anime_base/manage/router.dart';
import 'package:jtech_anime_base/model/version.dart';
import 'package:jtech_anime_base/tool/file.dart';
import 'package:jtech_anime_base/tool/log.dart';
import 'package:jtech_anime_base/widget/message_dialog.dart';

/*
* 应用版本检查
* @author wuxubaiyang
* @Time 2023/3/9 17:57
*/
abstract class AppVersionToolBase {
  // 更新提示忽略缓存key
  static const String _ignoreUpdateKey = 'ignore_update_key';

  // 默认更新配置文件路径
  static const String _defaultUpdateConfigPath =
      'packages/jtech_anime_base/assets/update_config.json';

  // 检查更新
  Future<bool> check(BuildContext context, {bool immediately = false}) async {
    // 判断是否需要进行版本更新
    if (!immediately && (cache.getBool(_ignoreUpdateKey) ?? false)) {
      return false;
    }
    final versionInfo = await _getLatestVersion(Platform.operatingSystem);
    if (versionInfo == null) return false;
    return versionInfo.checkUpdate().then((isUpdate) {
      if (isUpdate) {
        _showUpdateDialog(context, versionInfo).then((result) {
          if (result == true) upgradePlatform(context, versionInfo);
        });
      }
      return isUpdate;
    });
  }

  // 平台需要实现该方法
  Future<void> upgradePlatform(BuildContext context, AppVersion info);

  // 下载更新文件并返回文件路径
  Future<String?> downloadUpdateFile(
    AppVersion info, {
    required String saveDir,
    CancelToken? cancelToken,
    ProgressCallback? onReceiveProgress,
  }) async {
    try {
      final savePath = join(saveDir, basename(info.installUrl));
      if (File(savePath).existsSync()) return savePath;
      final tempFilePath = await _download(
        info.installUrl,
        '$savePath.temp',
        cancelToken: cancelToken,
        onReceiveProgress: (count, _) =>
            onReceiveProgress?.call(count, info.fileLength),
      );
      if (tempFilePath?.isEmpty ?? true) return null;
      // 验证文件sha256是否正确
      final sha256 = await FileTool.getFileSha256(tempFilePath!);
      if (!info.checkSha256(sha256)) return null;
      // 将临时文件改名
      await File(tempFilePath).rename(savePath);
      return savePath;
    } catch (e) {
      LogTool.e('下载更新文件失败', error: e);
    }
    return null;
  }

  // 断点续传的方式下载附件
  Future<String?> _download(
    String url,
    String savePath, {
    CancelToken? cancelToken,
    ProgressCallback? onReceiveProgress,
  }) async {
    int downloadBegin = 0;
    final file = File(savePath);
    if (file.existsSync()) downloadBegin = file.lengthSync();
    final resp = await Dio().get<ResponseBody>(url,
        options: Options(
          followRedirects: false,
          responseType: ResponseType.stream,
          headers: {"range": "bytes=$downloadBegin-"},
        ));
    final raf = file.openSync(mode: FileMode.append);
    int received = downloadBegin;
    final completer = Completer<String?>();
    final contentLength = _getContentLength(resp);
    final subscription = resp.data?.stream.listen((data) {
      raf.writeFromSync(data);
      received += data.length;
      onReceiveProgress?.call(received, contentLength);
    }, onDone: () async {
      await raf.close();
      completer.complete(savePath);
    }, onError: (e) async {
      await raf.close();
      completer.completeError(e);
    }, cancelOnError: true);
    if (subscription == null) return null;
    cancelToken?.whenCancel.then((_) async {
      await subscription.cancel();
      await raf.close();
    });
    return completer.future;
  }

  // 获取下载的文件大小
  int _getContentLength(Response<ResponseBody> resp) {
    try {
      final contentLength = resp.headers.value(HttpHeaders.contentLengthHeader);
      if (contentLength != null) return int.tryParse(contentLength) ?? -1;
    } catch (e) {
      LogTool.e('获取下载文件大小失败', error: e);
    }
    return 0;
  }

  // 检查当前平台最新版本
  // 默认调用我账号下的更新服务器，这部分信息闭源，如有需要请自行重写以下内容
  Future<AppVersion?> _getLatestVersion(String platform) async {
    try {
      final configJson = await rootBundle.loadString(_defaultUpdateConfigPath);
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
  Future<bool?> _showUpdateDialog(BuildContext context, AppVersion info) {
    return MessageDialog.show<bool>(
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
        onPressed: () => router.pop(true),
        child: const Text('更新'),
      ),
    );
  }
}
