import 'package:flutter/material.dart';
import 'package:jtech_anime_base/base.dart';

/*
* 播放器页面
* @author wuxubaiyang
* @Time 2023/9/15 8:33
*/
class PlayerPage extends StatefulWidget {
  const PlayerPage({super.key});

  @override
  State<StatefulWidget> createState() => _PlayerPageState();
}

/*
* 播放器页面-状态
* @author wuxubaiyang
* @Time 2023/9/15 8:33
*/
class _PlayerPageState extends LogicState<PlayerPage, _PlayerLogic> {
  @override
  _PlayerLogic initLogic() => _PlayerLogic();

  @override
  Widget buildWidget(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('播放器页面'),
      ),
    );
  }
}

/*
* 播放器页面-逻辑
* @author wuxubaiyang
* @Time 2023/9/15 8:33
*/
class _PlayerLogic extends BaseLogic {}
