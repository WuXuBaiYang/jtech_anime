import 'package:flutter/material.dart';
import 'package:jtech_anime/common/logic.dart';

/*
* 搜索页
* @author wuxubaiyang
* @Time 2023/7/10 17:28
*/
class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<StatefulWidget> createState() => _SearchPageState();
}

/*
* 搜索页-状态
* @author wuxubaiyang
* @Time 2023/7/10 17:28
*/
class _SearchPageState extends LogicState<SearchPage, _SearchLogic> {
  @override
  _SearchLogic initLogic() => _SearchLogic();

  @override
  Widget buildWidget(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leadingWidth: 24,
        title: TextField(),
      ),
    );
  }
}

/*
* 搜索页-逻辑
* @author wuxubaiyang
* @Time 2023/7/10 17:28
*/
class _SearchLogic extends BaseLogic {}
