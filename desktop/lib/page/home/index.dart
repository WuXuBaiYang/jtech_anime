import 'package:desktop/common/icon.dart';
import 'package:desktop/common/route.dart';
import 'package:desktop/page/anime/index.dart';
import 'package:desktop/page/collect/index.dart';
import 'package:desktop/page/download/index.dart';
import 'package:desktop/page/record/index.dart';
import 'package:desktop/page/timetable/index.dart';
import 'package:desktop/tool/version.dart';
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
    // 初始化加载
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // 检查版本更新
      AppVersionTool().check(context);
    });
    // 监听解析源变化
    event.on<SourceChangeEvent>().listen((event) {
      setState(() {});
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
    return NavigationRail(
      selectedIndex: index,
      leading: _buildAnimeSource(context),
      labelType: NavigationRailLabelType.all,
      backgroundColor: Colors.black.withOpacity(0.01),
      onDestinationSelected: logic.selectIndex.setValue,
      destinations: [
        NavigationRailDestination(
          label: const Text('最新'),
          icon: Image.asset(CustomIcon.homeNavigationNewest,
              width: 24, height: 24),
          selectedIcon: Image.asset(CustomIcon.homeNavigationNewestSelected,
              width: 24, height: 24),
        ),
        if (animeParser.isSupport(AnimeParserFunction.timeTable))
          const NavigationRailDestination(
            label: Text('时间表'),
            icon: Icon(FontAwesomeIcons.solidClock),
          ),
        _buildDownloadNavigation(),
        const NavigationRailDestination(
          label: Text('浏览'),
          icon: Icon(FontAwesomeIcons.ghost),
        ),
        const NavigationRailDestination(
          label: Text('喜欢'),
          icon: Icon(FontAwesomeIcons.solidHeart),
        ),
      ],
      trailing: _buildSideNavigationTrailing(context),
    );
  }

  // 构建侧边导航栏尾部
  Widget _buildSideNavigationTrailing(BuildContext context) {
    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          IconButton(
            iconSize: 16,
            onPressed: () => AnimeSourceProxyDialog.show(context),
            icon: const Icon(FontAwesomeIcons.globe),
          ),
          CacheFutureBuilder<String>(
            future: () => Tool.version,
            builder: (_, snap) {
              return TextButton(
                style: ButtonStyle(
                  textStyle: MaterialStateProperty.all(
                    const TextStyle(fontSize: 12),
                  ),
                ),
                child: Text('v${snap.data ?? ''}'),
                onPressed: () async {
                  SnackTool.showMessage(message: '正在检查最新版本');
                  final result = await AppVersionTool().check(context, true);
                  if (!result) SnackTool.showMessage(message: '已是最新版本');
                },
              );
            },
          ),
          const SizedBox(height: 8),
        ],
      ),
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

  // 构建导航页面
  Widget _buildNavigationPage(int index) {
    return IndexedStack(
      index: index,
      children: [
        const HomeAnimePage(),
        if (animeParser.isSupport(AnimeParserFunction.timeTable))
          const HomeTimeTablePage(),
        const HomeDownloadPage(),
        const HomeRecordPage(),
        const HomeCollectPage(),
      ],
    );
  }

  // 构建下载导航
  NavigationRailDestination _buildDownloadNavigation() {
    return NavigationRailDestination(
      padding: EdgeInsets.zero,
      icon: StreamBuilder<DownloadTask?>(
        stream: download.downloadProgress,
        builder: (_, snap) {
          if (download.hasDownloadTask) {
            return const LottieView(
              CustomAnime.homeDownloading,
              fit: BoxFit.fill,
              height: 32,
              width: 32,
            );
          }
          return const Icon(FontAwesomeIcons.solidCircleDown);
        },
      ),
      label: StreamBuilder<DownloadTask?>(
        stream: download.downloadProgress,
        builder: (_, snap) {
          if (download.hasDownloadTask) {
            return Text('${FileTool.formatSize(
              snap.data!.totalSpeed,
            )}/s');
          }
          return const Text('下载');
        },
      ),
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
