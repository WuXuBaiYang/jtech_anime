import 'package:desktop/page/home/anime.dart';
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
      child: ValueListenableBuilder<int>(
        valueListenable: logic.selectIndex,
        builder: (_, index, __) {
          return Row(
            children: [
              _buildSideNavigation(index),
              Expanded(child: _buildNavigationPage(index)),
            ],
          );
        },
      ),
    );
  }

  // 构建侧边导航栏
  Widget _buildSideNavigation(int index) {
    return NavigationRail(
      elevation: 1,
      selectedIndex: index,
      leading: _buildAnimeSource(),
      labelType: NavigationRailLabelType.selected,
      onDestinationSelected: logic.selectIndex.setValue,
      destinations: [
        NavigationRailDestination(
          icon: Icon(FontAwesomeIcons.arrowDownWideShort),
          selectedIcon: Icon(FontAwesomeIcons.arrowDownWideShort),
          label: Text('最新'),
        ),
        NavigationRailDestination(
          icon: Icon(FontAwesomeIcons.arrowDownWideShort),
          selectedIcon: Icon(FontAwesomeIcons.arrowDownWideShort),
          label: Text('时间轴'),
        ),
        NavigationRailDestination(
          icon: Icon(FontAwesomeIcons.arrowDownWideShort),
          selectedIcon: Icon(FontAwesomeIcons.arrowDownWideShort),
          label: Text('下载'),
        ),
        NavigationRailDestination(
          icon: Icon(FontAwesomeIcons.arrowDownWideShort),
          selectedIcon: Icon(FontAwesomeIcons.arrowDownWideShort),
          label: Text('记录'),
        ),
        NavigationRailDestination(
          icon: Icon(FontAwesomeIcons.arrowDownWideShort),
          selectedIcon: Icon(FontAwesomeIcons.arrowDownWideShort),
          label: Text('收藏'),
        ),
      ],
    );
  }

  // 构建插件入口方法
  Widget _buildAnimeSource() {
    return SourceStreamView(
      builder: (_, snap) {
        final source = snap.data?.source;
        if (source == null) return const SizedBox();
        return Column(
          children: [
            Transform.translate(
              offset: const Offset(0, -4),
              child: GestureDetector(
                child: AnimeSourceLogo(
                  source: source,
                ),
                onTap: () {
                  /// 跳转到插件设置页面
                },
                onLongPress: () {
                  /// 弹出插件设置菜单
                },
              ),
            ),
            const SizedBox(height: 14),
          ],
        );
      },
    );
  }

  // 构建导航页面
  Widget _buildNavigationPage(int index) {
    return IndexedStack(
      index: index,
      children: [
        HomeAnimePage(),
        Text('page'),
        Text('page'),
        Text('page'),
        Text('page'),
      ],
    );
  }
}

/*
* 首页-逻辑
* @author wuxubaiyang
* @Time 2023/9/5 17:07
*/
class _HomeLogic extends BaseLogic {
  // 当前选中导航下标
  final selectIndex = ValueChangeNotifier<int>(0);
}
