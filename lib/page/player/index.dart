import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:jtech_anime/common/logic.dart';
import 'package:jtech_anime/common/notifier.dart';
import 'package:jtech_anime/manage/parser.dart';
import 'package:jtech_anime/manage/router.dart';
import 'package:jtech_anime/model/anime.dart';
import 'package:jtech_anime/page/player/player.dart';
import 'package:jtech_anime/tool/snack.dart';
import 'package:jtech_anime/widget/listenable_builders.dart';
import 'package:jtech_anime/widget/status_box.dart';
import 'package:lecle_yoyo_player/lecle_yoyo_player.dart';

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
  @override
  _PlayerLogic initLogic() => _PlayerLogic();

  @override
  Widget buildWidget(BuildContext context) {
    return WillPopScope(
      child: Scaffold(
        backgroundColor: Colors.black,
        body: _buildVideoPlayer(context),
      ),
      onWillPop: () async {
        logic.setOrientation(true);
        return true;
      },
    );
  }

  // 构建视频播放器
  Widget _buildVideoPlayer(BuildContext context) {
    return ValueListenableBuilder2<String, bool>(
      first: logic.videoUrl,
      second: logic.loading,
      builder: (_, url, loading, __) {
        if (url.isEmpty || loading) {
          return const Center(
            child: StatusBox(
              status: StatusBoxStatus.loading,
              title: Text('正在解析播放地址~'),
              animSize: 24,
            ),
          );
        }
        return CustomVideoPlayer(
          url: url,
          videoInitCompleted: logic.setVideoController,
          loadingView: const Center(
            child: StatusBox(
              status: StatusBoxStatus.loading,
              title: Text('正在加载视频~'),
              animSize: 24,
            ),
          ),
        );
      },
    );
  }
}

/*
* 播放器页面（全屏播放）-逻辑
* @author wuxubaiyang
* @Time 2023/7/12 9:10
*/
class _PlayerLogic extends BaseLogic {
  // 当前番剧信息
  late ValueChangeNotifier<AnimeModel> animeInfo;

  // 当前使用资源下标
  final resourcesIndex = ValueChangeNotifier<int>(0);

  // 当前播放视频下标
  final videoIndex = ValueChangeNotifier<int>(0);

  // 当前视频播放地址
  final videoUrl = ValueChangeNotifier<String>('');

  // 加载状态管理
  final loading = ValueChangeNotifier<bool>(false);

  // 缓存视频播放器控制器
  VideoPlayerController? _controller;

  @override
  void init() {
    super.init();
    // 强制横屏
    setOrientation(false);
  }

  @override
  void setupArguments(BuildContext context, Map arguments) {
    animeInfo = ValueChangeNotifier(arguments['animeDetail']);
    // 选择当前视频
    changeVideo(
      context,
      arguments['resIndex'],
      arguments['index'],
    ).catchError((_) {
      setOrientation(true);
      router.pop();
    });
  }

  // 设置视频播放器控制器
  void setVideoController(VideoPlayerController c) => _controller = c;

  // 设置屏幕方向
  void setOrientation(bool portraitUp) {
    SystemChrome.setPreferredOrientations([
      portraitUp
          ? DeviceOrientation.portraitUp
          : DeviceOrientation.landscapeLeft,
    ]);
  }

  // 选择资源/视频
  Future<void> changeVideo(
      BuildContext context, int resIndex, int index) async {
    if (loading.value) return;
    if (resIndex < 0 || index < 0) return;
    final resources = animeInfo.value.resources;
    if (resources.isEmpty) return;
    if (resIndex >= resources.length) return;
    if (index >= resources[resIndex].length) return;
    try {
      loading.setValue(true);
      _controller?.dispose();
      videoIndex.setValue(index);
      resourcesIndex.setValue(resIndex);
      // 根据资源与视频下标切换视频播放地址
      final item = resources[resIndex][index];
      final result = await parserHandle.getAnimePlayUrl([item]);
      if (result.isEmpty) throw Exception('视频地址解析失败');
      videoUrl.setValue(result.first.url);
    } catch (e) {
      SnackTool.showMessage(context, message: '获取播放地址失败，请重试~');
      rethrow;
    } finally {
      loading.setValue(false);
    }
  }
}
