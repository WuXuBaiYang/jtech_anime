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
      final saveDir = await FileTool.getDirPath(
          join(globalConfig.baseCachePath, 'updates'),
          root: FileDir.applicationDocuments);
      if (saveDir == null) return;
      _downloadProgressController.add(0);
      final downloadFilePath = await downloadUpdateFile(
        info,
        saveDir: saveDir,
        onReceiveProgress: (count, total) =>
            _downloadProgressController.add(count / total),
      );
      if (downloadFilePath == null) return;
      // 使用命令启动已下载文件
      if (Platform.isWindows) Process.run(downloadFilePath, []);
      SnackTool.showMessage(message: '正在启动安装...');
    } catch (e) {
      LogTool.e('版本更新检查失败', error: e);
    }
  }
}
