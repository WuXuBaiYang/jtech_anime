import 'package:desktop/widget/page.dart';
import 'package:flutter/material.dart';
import 'package:jtech_anime_base/base.dart';

/*
* 首页
* @author wuxubaiyang
* @Time 2023/9/5 17:07
*/
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<StatefulWidget> createState() => _HomePageState();
}

/*
* 首页-状态
* @author wuxubaiyang
* @Time 2023/9/5 17:07
*/
class _HomePageState extends LogicState<HomePage, _HomeLogic> {
  @override
  _HomeLogic initLogic() => _HomeLogic();

  @override
  Widget buildWidget(BuildContext context) {
    return WindowPage(
      child: Center(
        child: StatusBox(
          status: StatusBoxStatus.loading,
        ),
      ),
      actions: [],
    );
  }
}

/*
* 首页-逻辑
* @author wuxubaiyang
* @Time 2023/9/5 17:07
*/
class _HomeLogic extends BaseLogic {}
