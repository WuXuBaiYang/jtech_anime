import 'package:desktop/common/icon.dart';
import 'package:desktop/page/anime/index.dart';
import 'package:desktop/page/collect/index.dart';
import 'package:desktop/page/record/index.dart';
import 'package:desktop/page/timetable/index.dart';
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
              const VerticalDivider(),
              Expanded(child: _buildNavigationPage(index)),
            ],
          );
        },
      ),
    );
  }

  // 构建侧边导航栏
  Widget _buildSideNavigation(int index) {
    return ValueListenableBuilder<bool>(
      valueListenable: logic.expanded,
      builder: (_, expanded, __) {
        return NavigationRail(
          extended: expanded,
          selectedIndex: index,
          minExtendedWidth: 120,
          minWidth: 70,
          leading: _buildAnimeSource(),
          trailing: _buildExpandedButton(),
          onDestinationSelected: logic.selectIndex.setValue,
          destinations: [
            NavigationRailDestination(
              label: const Text('最新'),
              icon: Image.asset(CustomIcon.homeNavigationNewest,
                  width: 24, height: 24),
              selectedIcon: Image.asset(CustomIcon.homeNavigationNewestSelected,
                  width: 24, height: 24),
            ),
            const NavigationRailDestination(
              label: Text('时间表'),
              icon: Icon(FontAwesomeIcons.solidClock),
            ),
            const NavigationRailDestination(
              label: Text('下载'),
              icon: Icon(FontAwesomeIcons.solidCircleDown),
            ),
            const NavigationRailDestination(
              label: Text('浏览'),
              icon: Icon(FontAwesomeIcons.ghost),
            ),
            const NavigationRailDestination(
              label: Text('喜欢'),
              icon: Icon(FontAwesomeIcons.solidHeart),
            )
          ],
        );
      },
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
            const SizedBox(height: 8),
            GestureDetector(
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
            const SizedBox(height: 14),
          ],
        );
      },
    );
  }

  // 构建收缩按钮
  Widget _buildExpandedButton() {
    return ValueListenableBuilder<bool>(
      valueListenable: logic.expanded,
      builder: (_, expanded, __) {
        return Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButton(
                icon: Icon(expanded
                    ? FontAwesomeIcons.barsStaggered
                    : FontAwesomeIcons.bars),
                onPressed: () => logic.expanded.setValue(!expanded),
              ),
              const SizedBox(height: 14),
            ],
          ),
        );
      },
    );
  }

  // 构建导航页面
  Widget _buildNavigationPage(int index) {
    return IndexedStack(
      index: index,
      children: const [
        HomeAnimePage(),
        HomeTimeTablePage(),
        Text('page'),
        HomeRecordPage(),
        HomeCollectPage(),
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

  // 侧栏菜单展开状态
  final expanded = ValueChangeNotifier<bool>(false);
}
