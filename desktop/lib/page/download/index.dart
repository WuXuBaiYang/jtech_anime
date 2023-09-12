import 'package:flutter/material.dart';
import 'package:jtech_anime_base/base.dart';

/*
* 首页下载管理页面
* @author wuxubaiyang
* @Time 2023/9/12 14:09
*/
class HomeDownloadPage extends StatefulWidget {
  const HomeDownloadPage({super.key});

  @override
  State<StatefulWidget> createState() => _HomeDownloadPageState();
}

/*
* 首页下载管理页面-状态
* @author wuxubaiyang
* @Time 2023/9/12 14:09
*/
class _HomeDownloadPageState
    extends LogicState<HomeDownloadPage, _HomeDownloadLogic> {
  @override
  _HomeDownloadLogic initLogic() => _HomeDownloadLogic();

  @override
  Widget buildWidget(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('首页下载管理页面'),
      ),
    );
  }
}

/*
* 首页下载管理页面-逻辑
* @author wuxubaiyang
* @Time 2023/9/12 14:09
*/
class _HomeDownloadLogic extends BaseLogic {}
