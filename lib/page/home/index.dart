import 'package:flutter/material.dart';
import 'package:jtech_anime/common/logic.dart';
import 'package:jtech_anime/model/anime.dart';
import 'package:jtech_anime/parser/yhdmz.dart';

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
      body: Center(
        child: TextButton(
          onPressed: () async {
            final handle = YHDMZParserHandle();
            // final result =
            //     await handle.loadAnimeList(params: {'order': '更新时间'});
            // final result =
            //     await handle.loadAnimeListNextPage(params: {'order': '更新时间'});
            // final result = await handle.searchAnimeList('鬼');
            final result = await handle
                .getAnimeDetail('https://www.yhdmz.org/showp/20422.html');
            // final result = await handle.getAnimePlayUrl([
            //   ResourceItemModel(
            //     url: 'https://www.yhdmz.org/vp/22289-1-0.html',
            //   )
            // ]);
            print('--------------------');
          },
          child: const Text('测试解析'),
        ),
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
