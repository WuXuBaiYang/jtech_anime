import 'package:flutter/material.dart';
import 'package:jtech_anime/common/logic.dart';

/*
* 历史记录页
* @author wuxubaiyang
* @Time 2023/7/12 9:13
*/
class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<StatefulWidget> createState() => _HistoryPageState();
}

/*
* 历史记录页-状态
* @author wuxubaiyang
* @Time 2023/7/12 9:13
*/
class _HistoryPageState extends LogicState<HistoryPage, _HistoryLogic> {
  @override
  _HistoryLogic initLogic() => _HistoryLogic();

  @override
  Widget buildWidget(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('历史记录页'),
      ),
    );
  }
}

/*
* 历史记录页-逻辑
* @author wuxubaiyang
* @Time 2023/7/12 9:13
*/
class _HistoryLogic extends BaseLogic {}
