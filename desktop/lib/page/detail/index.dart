import 'package:desktop/widget/page.dart';
import 'package:flutter/material.dart';
import 'package:jtech_anime_base/base.dart';

/*
* 动漫详情页
* @author wuxubaiyang
* @Time 2023/7/12 9:07
*/
class AnimeDetailPage extends StatefulWidget {
  const AnimeDetailPage({super.key});

  @override
  State<StatefulWidget> createState() => _AnimeDetailPageState();
}

/*
* 动漫详情页-状态
* @author wuxubaiyang
* @Time 2023/7/12 9:07
*/
class _AnimeDetailPageState
    extends LogicState<AnimeDetailPage, _AnimeDetailLogic>
    with SingleTickerProviderStateMixin {
  @override
  _AnimeDetailLogic initLogic() => _AnimeDetailLogic();

  @override
  Widget buildWidget(BuildContext context) {
    return WindowPage(
      child: Text('aa'),
    );
  }
}

/*
* 动漫详情页-逻辑
* @author wuxubaiyang
* @Time 2023/7/12 9:07
*/
class _AnimeDetailLogic extends BaseLogic {}
