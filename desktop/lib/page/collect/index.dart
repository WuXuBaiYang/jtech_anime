import 'package:flutter/material.dart';
import 'package:jtech_anime_base/base.dart';

/*
* 首页番剧收藏页面
* @author wuxubaiyang
* @Time 2023/9/11 15:00
*/
class HomeCollectPage extends StatefulWidget {
  const HomeCollectPage({super.key});

  @override
  State<StatefulWidget> createState() => _HomeCollectPageState();
}

/*
* 首页番剧收藏列表页面-状态
* @author wuxubaiyang
* @Time 2023/9/11 15:00
*/
class _HomeCollectPageState extends LogicState<HomeCollectPage, _HomeCollectLogic> {
  @override
  _HomeCollectLogic initLogic() => _HomeCollectLogic();

  @override
  Widget buildWidget(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('首页番剧收藏列表页面'),
      ),
    );
  }
}

/*
* 首页番剧收藏列表页面-逻辑
* @author wuxubaiyang
* @Time 2023/9/11 15:00
*/
class _HomeCollectLogic extends BaseLogic {}
