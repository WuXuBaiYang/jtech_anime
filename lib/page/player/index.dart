import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:jtech_anime/common/logic.dart';
import 'package:jtech_anime/common/notifier.dart';
import 'package:jtech_anime/manage/parser.dart';
import 'package:jtech_anime/manage/router.dart';
import 'package:jtech_anime/manage/theme.dart';
import 'package:jtech_anime/model/anime.dart';
import 'package:jtech_anime/page/player/resource.dart';
import 'package:jtech_anime/tool/snack.dart';
import 'package:jtech_anime/widget/player/controller.dart';
import 'package:jtech_anime/widget/player/player.dart';
import 'package:jtech_anime/widget/status_box.dart';

/*
* 播放器页面（全屏播放）
* @author wuxubaiyang
* @Time 2023/7/12 9:10
*/
class PlayerPage extends StatefulWidget {
  const PlayerPage({super.key});

  @override
  State<StatefulWidget> createState() => _PlayerPageState();
}

/*
* 播放器页面（全屏播放）-状态
* @author wuxubaiyang
* @Time 2023/7/12 9:10
*/
class _PlayerPageState extends LogicState<PlayerPage, _PlayerLogic> {
  // 页面key
  final pageKey = GlobalKey<ScaffoldState>();

  @override
  _PlayerLogic initLogic() => _PlayerLogic();

  @override
  Widget buildWidget(BuildContext context) {
    return Scaffold(
      key: pageKey,
      backgroundColor: Colors.black,
      body: _buildVideoPlayer(context),
      endDrawerEnableOpenDragGesture: false,
      endDrawer: ValueListenableBuilder<ResourceItemModel?>(
        valueListenable: logic.resourceInfo,
        builder: (_, item, __) {
          return PlayerResourceDrawer(
            currentItem: item,
            resources: logic.resources,
            onResourceSelect: (item) {
              logic.changeVideo(context, item);
              pageKey.currentState?.closeEndDrawer();
            },
          );
        },
      ),
    );
  }

  // 构建视频播放器
  Widget _buildVideoPlayer(BuildContext context) {
    return SizedBox.expand(
      child: ValueListenableBuilder<ResourceItemModel?>(
        valueListenable: logic.nextResourceInfo,
        builder: (_, nextResource, __) {
          return CustomVideoPlayer(
            primaryColor: kPrimaryColor,
            controller: logic.controller,
            title: _buildVideoPlayerTitle(),
            onNext: nextResource != null
                ? () {
                    logic.changeVideo(context, nextResource);
                  }
                : null,
            placeholder: _buildVideoPlayerPlaceholder(),
            actions: actions,
          );
        },
      ),
    );
  }

  // 构建视频播放器标题
  Widget _buildVideoPlayerTitle() {
    return ValueListenableBuilder<ResourceItemModel?>(
      valueListenable: logic.resourceInfo,
      builder: (_, item, __) {
        final title = logic.animeInfo.value.name;
        final subTitle = item != null ? '  ·  ${item.name}' : '';
        return Text('$title$subTitle');
      },
    );
  }

  // 构建视频播放器占位组件
  Widget _buildVideoPlayerPlaceholder() {
    return const StatusBox(
      status: StatusBoxStatus.loading,
      title: Text('正在解析视频~'),
      color: Colors.white54,
      animSize: 35,
      space: 14,
    );
  }

  // 视频播放器的动作按钮集合
  List<Widget> get actions => [
        TextButton(
          child: const Text('选集'),
          onPressed: () => pageKey.currentState?.openEndDrawer(),
        ),
      ];
}

/*
* 播放器页面（全屏播放）-逻辑
* @author wuxubaiyang
* @Time 2023/7/12 9:10
*/
class _PlayerLogic extends BaseLogic {
  // 当前番剧信息
  late ValueChangeNotifier<AnimeModel> animeInfo;

  // 播放器控制器
  final controller = CustomVideoPlayerController();

  // 当前播放的资源信息
  final resourceInfo = ValueChangeNotifier<ResourceItemModel?>(null);

  // 存储下一条视频信息
  final nextResourceInfo = ValueChangeNotifier<ResourceItemModel?>(null);

  @override
  void init() {
    super.init();
    // 设置页面进入状态
    entryPlayer();
  }

  @override
  void setupArguments(BuildContext context, Map arguments) {
    animeInfo = ValueChangeNotifier(arguments['animeDetail']);
    // 选择当前视频
    changeVideo(context, arguments['item']).catchError((_) => router.pop());
  }

  // 获取资源列表
  List<List<ResourceItemModel>> get resources => animeInfo.value.resources;

  // 进入播放页面设置(横向布局且不显示状态栏)
  void entryPlayer() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }

  // 退出播放页面设置(纵向布局显示状态栏)
  void quitPlayer() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  }

  // 选择资源/视频
  Future<void> changeVideo(BuildContext context, ResourceItemModel item) async {
    if (isLoading) return;
    final resources = animeInfo.value.resources;
    if (resources.isEmpty) return;
    try {
      loading.setValue(true);
      resourceInfo.setValue(item);
      nextResourceInfo.setValue(_findNextResourceItem(item));
      // 根据资源与视频下标切换视频播放地址
      await controller.stop();
      final result = await parserHandle.getAnimeVideoCache([item]);
      if (result.isEmpty) throw Exception('视频地址解析失败');
      // 解析完成之后实现视频播放
      await controller.playNet(result.first.playUrl);
    } catch (e) {
      SnackTool.showMessage(context, message: '获取播放地址失败，请重试~');
      rethrow;
    } finally {
      loading.setValue(false);
    }
  }

  // 获取列表中的下一个资源
  ResourceItemModel? _findNextResourceItem(ResourceItemModel item) {
    for (final it in animeInfo.value.resources) {
      final iter = it.iterator;
      while (iter.moveNext()) {
        if (item.url == iter.current.url) {
          if (iter.moveNext()) return iter.current;
          return null;
        }
      }
    }
    return null;
  }

  @override
  void dispose() {
    // 退出播放器状态
    quitPlayer();
    super.dispose();
  }
}
