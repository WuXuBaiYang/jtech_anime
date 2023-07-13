import 'package:flutter/material.dart';
import 'package:jtech_anime/common/logic.dart';

/*
* 播放记录页
* @author wuxubaiyang
* @Time 2023/7/13 17:31
*/
class PlayRecordPage extends StatefulWidget {
  const PlayRecordPage({super.key});

  @override
  State<StatefulWidget> createState() => _PlayRecordPageState();
}

/*
* 播放记录页-状态
* @author wuxubaiyang
* @Time 2023/7/13 17:31
*/
class _PlayRecordPageState
    extends LogicState<PlayRecordPage, _PlayRecordLogic> {
  @override
  _PlayRecordLogic initLogic() => _PlayRecordLogic();

  @override
  Widget buildWidget(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('播放记录页'),
      ),
    );
  }
}

/*
* 播放记录页-逻辑
* @author wuxubaiyang
* @Time 2023/7/13 17:31
*/
class _PlayRecordLogic extends BaseLogic {}
