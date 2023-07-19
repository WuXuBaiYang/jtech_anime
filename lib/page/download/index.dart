import 'dart:io';

import 'package:flutter/material.dart';
import 'package:jtech_anime/common/logic.dart';
import 'package:jtech_anime/manage/router.dart';
import 'package:jtech_anime/tool/permission.dart';
import 'package:jtech_anime/tool/snack.dart';

/*
* 下载管理页
* @author wuxubaiyang
* @Time 2023/7/12 9:08
*/
class DownloadPage extends StatefulWidget {
  const DownloadPage({super.key});

  @override
  State<StatefulWidget> createState() => _DownloadPageState();
}

/*
* 下载管理页-状态
* @author wuxubaiyang
* @Time 2023/7/12 9:08
*/
class _DownloadPageState extends LogicState<DownloadPage, _DownloadLogic> {
  @override
  _DownloadLogic initLogic() => _DownloadLogic();

  @override
  void initState() {
    super.initState();
    // 初始化操作
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // 检查存储权限
      logic.checkPermission(context);
    });
  }

  @override
  Widget buildWidget(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('下载管理页'),
      ),
    );
  }
}

/*
* 下载管理页-逻辑
* @author wuxubaiyang
* @Time 2023/7/12 9:08
*/
class _DownloadLogic extends BaseLogic {
  // 检查权限
  Future<void> checkPermission(BuildContext context) {
    return PermissionTool.checkAllGranted(context, permissions: [
      const PermissionRequest.androidManageExternalStorage(),
      if (Platform.isIOS) const PermissionRequest.storage(),
    ]).then((value) {
      if (!value) {
        SnackTool.showMessage(context, message: '缺少必须的文件管理权限');
        router.pop();
      }
    });
  }
}
