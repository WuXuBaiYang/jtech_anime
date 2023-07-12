import 'package:flutter/material.dart';
import 'package:jtech_anime/common/logic.dart';

/*
* 收藏页
* @author wuxubaiyang
* @Time 2023/7/12 9:11
*/
class CollectPage extends StatefulWidget {
  const CollectPage({super.key});

  @override
  State<StatefulWidget> createState() => _CollectPageState();
}

/*
* 收藏页-状态
* @author wuxubaiyang
* @Time 2023/7/12 9:11
*/
class _CollectPageState extends LogicState<CollectPage, _CollectLogic> {
  @override
  _CollectLogic initLogic() => _CollectLogic();

  @override
  Widget buildWidget(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('收藏页'),
      ),
    );
  }
}

/*
* 收藏页-逻辑
* @author wuxubaiyang
* @Time 2023/7/12 9:11
*/
class _CollectLogic extends BaseLogic {}
