import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_meedu_videoplayer/meedu_player.dart';
import 'package:jtech_anime/common/logic.dart';
import 'package:jtech_anime/common/notifier.dart';
import 'package:jtech_anime/manage/db.dart';
import 'package:jtech_anime/manage/parser.dart';
import 'package:jtech_anime/manage/router.dart' as router;
import 'package:jtech_anime/manage/theme.dart';
import 'package:jtech_anime/model/anime.dart';
import 'package:jtech_anime/model/database/play_record.dart';
import 'package:jtech_anime/page/player/resource.dart';
import 'package:jtech_anime/tool/debounce.dart';
import 'package:jtech_anime/tool/snack.dart';
import 'package:jtech_anime/tool/throttle.dart';
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
      body: Stack(
        children: [
          Positioned.fill(child: _buildVideoPlayer(context)),
          Align(
            alignment: Alignment.bottomLeft,
            child: _buildPlayRecordTag(),
          ),
        ],
      ),
      endDrawerEnableOpenDragGesture: false,
      endDrawer: _buildResourceDrawer(context),
    );
  }

  // 构建资源侧栏弹窗
  Widget _buildResourceDrawer(BuildContext context) {
    return ValueListenableBuilder<ResourceItemModel>(
      valueListenable: logic.resourceInfo,
      builder: (_, item, __) {
        return PlayerResourceDrawer(
          currentItem: item,
          resources: logic.resources,
          onResourceSelect: (item) {
            pageKey.currentState?.closeEndDrawer();
            logic.changeVideo(context, item);
          },
        );
      },
    );
  }

  // 构建视频播放器
  Widget _buildVideoPlayer(BuildContext context) {
    return MeeduVideoPlayer(
      controller: logic.controller,
      header: (_, controller, responsive) {
        return Text(logic.animeInfo.value.name);
      },
      customCaptionView: (_, controller, responsive, text) {
        return Text(logic.resourceInfo.value.name);
      },
      bottomRight: (_, controller, responsive) {
        return TextButton(
          child: const Text('选集'),
          onPressed: () => pageKey.currentState?.openEndDrawer(),
        );
      },
    );
  }

  // 构建播放记录标记
  Widget _buildPlayRecordTag() {
    return SizedBox();
    // const textStyle = TextStyle(color: Colors.white54);
    // return ValueListenableBuilder2<PlayRecord?, dynamic>(
    //   first: logic.playRecord,
    //   second: logic.controller,
    //   builder: (_, playRecord, state, __) {
    //     if (!logic.controller.isPlaying) return const SizedBox();
    //     logic.time2CloseRecord();
    //     final milliseconds = playRecord?.progress ?? 0;
    //     final progress = Duration(milliseconds: milliseconds);
    //     final fullTime = progress.format(DurationPattern.fullTime);
    //     return AnimatedOpacity(
    //       opacity: playRecord != null ? 1 : 0,
    //       duration: const Duration(milliseconds: 80),
    //       child: Card(
    //         elevation: 0,
    //         color: Colors.black26,
    //         margin: const EdgeInsets.only(bottom: 110, left: 8),
    //         child: Padding(
    //           padding: const EdgeInsets.symmetric(vertical: 8),
    //           child: Row(
    //             mainAxisSize: MainAxisSize.min,
    //             children: [
    //               IconButton(
    //                 iconSize: 20,
    //                 color: Colors.white54,
    //                 icon: const Icon(FontAwesomeIcons.xmark),
    //                 onPressed: () => logic.playRecord.setValue(null),
    //               ),
    //               Text('上次看到 $fullTime', style: textStyle),
    //               TextButton(
    //                 onPressed: logic.seekVideo2Record,
    //                 child: const Text('继续观看'),
    //               ),
    //             ],
    //           ),
    //         ),
    //       ),
    //     );
    //   },
    // );
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

  // 当前播放的资源信息
  late ValueChangeNotifier<ResourceItemModel> resourceInfo;

  // 播放器控制器
  late MeeduPlayerController controller;

  // 存储下一条视频信息
  final nextResourceInfo = ValueChangeNotifier<ResourceItemModel?>(null);

  // 播放记录
  final playRecord = ValueChangeNotifier<PlayRecord?>(null);

  // 获取资源列表
  List<List<ResourceItemModel>> get resources => animeInfo.value.resources;

  @override
  void init() {
    super.init();
    // 设置页面进入状态
    entryPlayer();
    // 监听视频播放进度
    controller.onPositionChanged.listen((e) {
      // 更新当前播放进度并加入节流
      Throttle.c(() => _updateVideoProgress(e));
    });
  }

  @override
  void setupArguments(BuildContext context, Map arguments) {
    animeInfo = ValueChangeNotifier(arguments['animeDetail']);
    resourceInfo = ValueChangeNotifier(arguments['item']);
    final record = arguments['playRecord'];
    // 初始化视频播放器并设置播放记录
    controller = _createVideoController(record);
    // 选择当前视频(如果用户传入了播放记录则代表需要立即跳转到指定位置)
    changeVideo(context, resourceInfo.value, getPlayRecord: record == null)
        .catchError((_) => router.router.pop());
  }

  // 创建视频播放器控制器
  MeeduPlayerController _createVideoController(PlayRecord? record) {
    // 屏幕控制
    const screenManage = ScreenManager(
      orientations: [
        DeviceOrientation.landscapeRight,
        DeviceOrientation.landscapeRight
      ],
      systemUiMode: SystemUiMode.immersiveSticky,
    );
    // 按钮启用
    const enabledButtons = EnabledButtons(
      rewindAndfastForward: false,
      playPauseAndRepeat: true,
      playBackSpeed: true,
      muteAndSound: true,
      lockControls: true,
      fullscreen: false,
      videoFit: true,
      pip: false,
    );
    // 加载组件
    const loadingWidget = StatusBox(
      status: StatusBoxStatus.loading,
      animSize: 35,
      space: 14,
    );
    // 异常提示
    const errorText = '视频加载失败，请重试~';
    return MeeduPlayerController(
      controlsStyle: ControlsStyle.primary,
      enabledButtons: enabledButtons,
      loadingWidget: loadingWidget,
      screenManager: screenManage,
      colorTheme: kPrimaryColor,
      errorText: errorText,
      showLogs: kDebugMode,
    );
  }

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

  // 一定时间后关闭播放记录弹窗
  void time2CloseRecord() => Debounce.c(
        () => playRecord.setValue(null),
        delay: const Duration(milliseconds: 5000),
      );

  // 更新视频进度
  void _updateVideoProgress(Duration progress) {
    final source = parserHandle.currentSource;
    final item = animeInfo.value;
    final resItem = resourceInfo.value;
    db.updatePlayRecord(PlayRecord()
      ..url = item.url
      ..source = source
      ..name = item.name
      ..cover = item.cover
      ..resName = resItem.name
      ..resUrl = resItem.url
      ..progress = progress.inMilliseconds);
  }

  // 跳转到视频的指定位置
  Future<void> seekVideo2Record() async {
    final record = playRecord.value;
    if (record == null) return;
    playRecord.setValue(null);
    await controller.seekTo(Duration(
      milliseconds: record.progress,
    ));
  }

  // 选择资源/视频
  Future<void> changeVideo(BuildContext context, ResourceItemModel item,
      {bool getPlayRecord = true}) async {
    if (isLoading) return;
    final resources = animeInfo.value.resources;
    if (resources.isEmpty) return;
    try {
      loading.setValue(true);
      resourceInfo.setValue(item);
      nextResourceInfo.setValue(_findNextResourceItem(item));
      // 根据当前资源获取播放记录
      if (getPlayRecord) {
        final record = await db.getPlayRecord(animeInfo.value.url);
        playRecord.setValue(record);
      }
      // 根据资源与视频下标切换视频播放地址
      await controller.
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
    // 销毁控制器
    controller.dispose();
    super.dispose();
  }
}
