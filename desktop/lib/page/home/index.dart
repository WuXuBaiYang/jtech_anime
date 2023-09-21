import 'package:desktop/common/icon.dart';
import 'package:desktop/common/route.dart';
import 'package:desktop/page/anime/index.dart';
import 'package:desktop/page/collect/index.dart';
import 'package:desktop/page/download/index.dart';
import 'package:desktop/page/record/index.dart';
import 'package:desktop/page/timetable/index.dart';
import 'package:desktop/widget/page.dart';
import 'package:flutter/material.dart';
import 'package:jtech_anime_base/base.dart';

import 'source.dart';

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
  void initState() {
    super.initState();
    // 监听解析源变化
    event.on<SourceChangeEvent>().listen((event) {
      // 如果解析源为空则弹出不可取消的强制选择弹窗
      if (event.source == null) {
        AnimeSourceChangeDialog.show(context, dismissible: false);
      }
    });
  }

  @override
  Widget buildWidget(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: logic.selectIndex,
      builder: (_, index, __) {
        return WindowPage(
          sideBar: _buildSideNavigation(context, index),
          child: _buildNavigationPage(index),
        );
      },
    );
  }

  // 构建侧边导航栏
  Widget _buildSideNavigation(BuildContext context, int index) {
    return ValueListenableBuilder<bool>(
      valueListenable: logic.expanded,
      builder: (_, expanded, __) {
        return NavigationRail(
          minWidth: 70,
          extended: expanded,
          selectedIndex: index,
          minExtendedWidth: 120,
          trailing: _buildExpandedButton(),
          leading: _buildAnimeSource(context),
          // backgroundColor: Colors.transparent,
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
            NavigationRailDestination(
              label: const Text('下载'),
              icon: _buildDownloadIcon(),
            ),
            const NavigationRailDestination(
              label: Text('浏览'),
              icon: Icon(FontAwesomeIcons.ghost),
            ),
            const NavigationRailDestination(
              label: Text('喜欢'),
              icon: Icon(FontAwesomeIcons.solidHeart),
            ),
          ],
        );
      },
    );
  }

  // 构建插件入口方法
  Widget _buildAnimeSource(BuildContext context) {
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
              onTap: () => router.pushNamed(RoutePath.animeSource),
              onLongPress: () => AnimeSourceChangeDialog.show(context),
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
                    ? FontAwesomeIcons.bars
                    : FontAwesomeIcons.barsStaggered),
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
        HomeDownloadPage(),
        HomeRecordPage(),
        HomeCollectPage(),
      ],
    );
  }

  // 构建下载按钮
  Widget _buildDownloadIcon() {
    const icon = FontAwesomeIcons.solidCircleDown;
    return ValueListenableBuilder(
      valueListenable: logic.selectIndex,
      builder: (_, selectIndex, __) {
        final selected = selectIndex == 2;
        if (selected) return const Icon(icon);
        return StreamBuilder(
          stream: download.downloadProgress,
          builder: (_, snap) {
            final task = snap.data;
            return Stack(
              children: [
                if (task != null)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const LottieView(CustomAnime.homeDownloading,
                          width: 30, height: 30, fit: BoxFit.cover),
                      Text(
                        FileTool.formatSize(task.totalSpeed, fixed: 0),
                        style: const TextStyle(fontSize: 10),
                      ),
                    ],
                  ),
                if (task == null) const Icon(icon),
              ],
            );
          },
        );
      },
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
