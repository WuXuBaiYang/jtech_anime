import 'package:flutter/material.dart';
import 'package:jtech_anime/common/logic.dart';

/*
* 首页
* @author wuxubaiyang
* @Time 2023/7/6 10:03
*/
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<StatefulWidget> createState() => _HomePageState();
}

/*
* 首页-状态
* @author wuxubaiyang
* @Time 2023/7/6 10:03
*/
class _HomePageState extends LogicState<HomePage, _HomeLogic> {
  @override
  _HomeLogic initLogic() => _HomeLogic();

  @override
  Widget buildWidget(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('首页'),
      ),
    );
  }
}

/*
* 首页-逻辑
* @author wuxubaiyang
* @Time 2023/7/6 10:03
*/
class _HomeLogic extends BaseLogic {}
