import 'package:flutter/material.dart';
import 'package:jtech_anime/common/logic.dart';

/*
* 番剧解析源管理
* @author wuxubaiyang
* @Time 2023/8/30 17:27
*/
class AnimeSourcePage extends StatefulWidget {
  const AnimeSourcePage({super.key});

  @override
  State<StatefulWidget> createState() => _AnimeSourcePageState();
}

/*
* 番剧解析源管理-状态
* @author wuxubaiyang
* @Time 2023/8/30 17:27
*/
class _AnimeSourcePageState extends LogicState<AnimeSourcePage, _AnimeSourceLogic> {
  @override
  _AnimeSourceLogic initLogic() => _AnimeSourceLogic();

  @override
  Widget buildWidget(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('番剧解析源管理'),
      ),
    );
  }
}

/*
* 番剧解析源管理-逻辑
* @author wuxubaiyang
* @Time 2023/8/30 17:27
*/
class _AnimeSourceLogic extends BaseLogic {}
