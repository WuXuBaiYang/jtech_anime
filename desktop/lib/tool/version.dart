import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:jtech_anime_base/base.dart';
import 'package:jtech_anime_base/manage/config.dart';

/*
* 应用版本检查
* @author wuxubaiyang
* @Time 2023/3/9 17:57
*/
class AppVersionTool extends AppVersionToolBase {
  // 下载进度流
  static final StreamController<double> _downloadProgressController =
      StreamController.broadcast();

  // 获取下载进度流
  static Stream<double> get downloadProgressStream =>
      _downloadProgressController.stream;

  @override
  Future<void> upgradePlatform(BuildContext context, AppVersion info) async {
    try {
      final savePath = await FileTool.getDirPath(
          join(globalConfig.baseCachePath, 'updates'),
          root: FileDir.applicationDocuments);
      if (savePath == null) return;
      final installFile = File(join(savePath, basename(info.installUrl)));
      final resp = await Dio().download(
        info.installUrl,
        installFile.path,
        onReceiveProgress: (count, _) =>
            _downloadProgressController.add(count / info.fileLength),
      );
      _downloadProgressController.add(0);
      if (resp.statusCode == 200 && installFile.existsSync()) {
        // 使用命令启动已下载文件
        if (Platform.isWindows) Process.run(installFile.path, []);
      }
    } catch (e) {
      LogTool.e('版本更新检查失败', error: e);
    }
  }
}
