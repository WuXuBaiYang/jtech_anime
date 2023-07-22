import 'package:flutter/material.dart';
import 'package:jtech_anime/common/logic.dart';

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
  Widget buildWidget(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('番剧缓存'),
      ),
    );
  }
}

/*
* 下载管理页-逻辑
* @author wuxubaiyang
* @Time 2023/7/12 9:08
*/
class _DownloadLogic extends BaseLogic {}
