import 'dart:async';
import 'package:audio_session/audio_session.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pad/page/player/resource.dart';
import 'package:pad/tool/tool.dart';
import 'package:jtech_anime_base/base.dart';

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
class _PlayerPageState extends LogicState<PlayerPage, _PlayerLogic>
    with WidgetsBindingObserver {
  // 页面key
  final pageKey = GlobalKey<ScaffoldState>();

  @override
  _PlayerLogic initLogic() => _PlayerLogic();

  @override
  void initState() {
    super.initState();
    // 监听生命周期
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  Widget buildWidget(BuildContext context) {
    return Scaffold(
      key: pageKey,
      backgroundColor: Colors.black,
      endDrawer: _buildResourceDrawer(),
      endDrawerEnableOpenDragGesture: false,
      onEndDrawerChanged: (isOpened) {
        logic.controller.setControlVisible(true, ongoing: isOpened);
      },
      body: Stack(
        children: [
          Positioned.fill(child: _buildVideoPlayer()),
          Align(
            alignment: Alignment.bottomLeft,
            child: _buildPlayRecordTag(),
          ),
        ],
      ),
    );
  }

  // 构建资源侧栏弹窗
  Widget _buildResourceDrawer() {
    return ValueListenableBuilder<ResourceItemModel>(
      valueListenable: logic.resourceInfo,
      builder: (_, item, __) {
        return PlayerResourceDrawer(
          currentItem: item,
          animeInfo: logic.animeInfo.value,
          onResourceSelect: (item) {
            pageKey.currentState?.closeEndDrawer();
            logic.changeVideo(item);
          },
        );
      },
    );
  }

  // 构建视频播放器
  Widget _buildVideoPlayer() {
    return ValueListenableBuilder<Orientation>(
      valueListenable: logic.screenOrientation,
      builder: (_, orientation, __) {
        final landscape = orientation == Orientation.landscape;
        return CustomVideoPlayer(
          subTitle: _buildSubTitle(),
          controller: logic.controller,
          title: Text(logic.animeInfo.value.name),
          showTimer: landscape,
          showSpeed: landscape,
          showProgressText: landscape,
          bottomActions: [
            _buildBottomActionsNext(),
            const Spacer(),
            if (landscape) _buildBottomActionsChoice(),
            if (landscape) _buildBottomActionsAutoPlay(),
            _buildBottomActionsOrientation(),
          ],
        );
      },
    );
  }

  // 构建视频播放器头部子标题
  Widget _buildSubTitle() {
    return ValueListenableBuilder<ResourceItemModel>(
      valueListenable: logic.resourceInfo,
      builder: (_, resource, __) {
        final subTitle = logic.resourceInfo.value.name;
        const subTitleStyle = TextStyle(fontSize: 12, color: Colors.white70);
        return Text(subTitle, style: subTitleStyle);
      },
    );
  }

  // 构建底部下一集按钮
  Widget _buildBottomActionsNext() {
    return ValueListenableBuilder<ResourceItemModel?>(
      valueListenable: logic.nextResourceInfo,
      builder: (_, resource, __) {
        final canPlayNext = resource != null;
        return IconButton(
          onPressed: canPlayNext
              ? Throttle.click(() {
                  logic.controller.setControlVisible(true);
                  logic.changeVideo(resource);
                }, 'playNextResource')
              : null,
          icon: Icon(FontAwesomeIcons.forward,
              color: canPlayNext ? Colors.white : Colors.white30),
        );
      },
    );
  }

  // 构建底部选集按钮
  Widget _buildBottomActionsChoice() {
    return TextButton(
      child: const Text('选集'),
      onPressed: () {
        logic.controller.setControlVisible(true, ongoing: true);
        pageKey.currentState?.openEndDrawer();
      },
    );
  }

  // 构建底部连播按钮
  Widget _buildBottomActionsAutoPlay() {
    return ValueListenableBuilder<bool>(
      valueListenable: logic.autoPlay,
      builder: (_, autoPlay, __) {
        return Tooltip(
          message: autoPlay ? '关闭自动连播' : '开启自动连播',
          child: Transform.scale(
            scale: 0.8,
            child: Switch(
              value: autoPlay,
              activeColor: kPrimaryColor,
              onChanged: (v) {
                logic.autoPlay.setValue(v);
                logic.controller.setControlVisible(true);
              },
            ),
          ),
        );
      },
    );
  }

  // 构建底部屏幕方向按钮
  Widget _buildBottomActionsOrientation() {
    return ValueListenableBuilder<Orientation>(
      valueListenable: logic.screenOrientation,
      builder: (_, orientation, __) {
        return AnimatedRotation(
          duration: const Duration(milliseconds: 200),
          turns: orientation == Orientation.landscape ? 0 : 0.25,
          child: IconButton(
            icon: const Icon(FontAwesomeIcons.mobileScreen),
            onPressed: () {
              logic.screenOrientation
                  .setValue(Orientation.values[orientation.index ^ 1]);
              logic.controller.setControlVisible(true);
            },
          ),
        );
      },
    );
  }

  // 构建播放记录标记
  Widget _buildPlayRecordTag() {
    const textStyle = TextStyle(color: Colors.white54);
    return ValueListenableBuilder<PlayRecord?>(
      valueListenable: logic.playRecord,
      builder: (_, playRecord, __) {
        if (playRecord == null) return const SizedBox();
        logic.time2CloseRecord();
        final milliseconds = playRecord.progress;
        final progress = Duration(milliseconds: milliseconds);
        final fullTime = progress.format(DurationPattern.fullTime);
        return Card(
          elevation: 0,
          color: Colors.black26,
          margin: const EdgeInsets.only(bottom: 130, left: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                iconSize: 20,
                color: Colors.white54,
                icon: const Icon(FontAwesomeIcons.xmark),
                onPressed: () => logic.playRecord.setValue(null),
              ),
              Text('已定位到 $fullTime', style: textStyle),
              TextButton(
                onPressed: logic.seekVideo2Rest,
                child: const Text('重新播放'),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // 当页面退出时暂停视频播放
    if (state == AppLifecycleState.paused) {
      logic.resumeFlag.setValue(logic.controller.state.playing);
      logic.controller
        ..setScreenLocked(false)
        ..pause();
    } else if (state == AppLifecycleState.resumed) {
      logic.resumePlayByFlag();
    }
  }

  @override
  void dispose() {
    // 取消监听生命周期
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
}

/*
* 播放器页面（全屏播放）-逻辑
* @author wuxubaiyang
* @Time 2023/7/12 9:10
*/
class _PlayerLogic extends BaseLogic {
  // 播放器控制器
  final controller = CustomVideoPlayerController();

  // 当前番剧信息
  late ValueChangeNotifier<AnimeModel> animeInfo;

  // 当前播放的资源信息
  late ValueChangeNotifier<ResourceItemModel> resourceInfo;

  // 存储下一条视频信息
  final nextResourceInfo = ValueChangeNotifier<ResourceItemModel?>(null);

  // 播放记录
  final playRecord = ValueChangeNotifier<PlayRecord?>(null);

  // 播放恢复标记
  final resumeFlag = ValueChangeNotifier<bool>(false);

  // 获取资源列表
  List<List<ResourceItemModel>> get resources => animeInfo.value.resources;

  // 是否自动连播
  final autoPlay = ValueChangeNotifier<bool>(true);

  // 当前屏幕方向
  final screenOrientation =
      ValueChangeNotifier<Orientation>(Orientation.landscape);

  @override
  void init() {
    super.init();
    // 监听播放完成状态
    controller.stream.completed.listen((completed) {
      if (!completed) return;
      // 自动播放下一集
      if (autoPlay.value) {
        final nextVideo = nextResourceInfo.value;
        if (nextVideo != null) changeVideo(nextVideo);
      }
    });
    // 设置页面进入状态
    entryPlayer();
    // 监听视频播放进度
    controller.stream.position.listen((e) {
      // 更新当前播放进度
      Throttle.c(
        () => _updateVideoProgress(e),
        'updateVideoProgress',
      );
    });
    // 监听屏幕旋转方向
    screenOrientation.addListener(() {
      setScreenOrientation(screenOrientation.value == Orientation.portrait);
    });
    // 监听音频设备状态
    _listenAudioSession();
  }

  @override
  void setupArguments(BuildContext context, Map arguments) {
    animeInfo = ValueChangeNotifier(arguments['animeDetail']);
    resourceInfo = ValueChangeNotifier(arguments['item']);
    // 初始化
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // 选择当前视频(如果用户传入了播放记录则代表需要立即跳转到指定位置)
      changeVideo(resourceInfo.value).catchError((_) {
        if (context.mounted) router.pop();
      });
    });
  }

  // 资源访问token
  CancelToken? _cancelToken;

  // 选择资源/视频
  Future<void> changeVideo(ResourceItemModel item) async {
    final resources = animeInfo.value.resources;
    if (resources.isEmpty) return;
    return Loading.show(loadFuture: Future(() async {
      try {
        playRecord.setValue(null);
        resourceInfo.setValue(item);
        nextResourceInfo.setValue(_findNextResourceItem(item));
        // 停止现有播放内容
        await cancelVideoPlay();
        _cancelToken = CancelToken();
        _cancelToken?.whenCancel.then((_) {
          throw Exception('取消视频播放');
        });
        // 根据当前资源获取播放记录
        PlayRecord? record = await db.getPlayRecord(animeInfo.value.url);
        if (record?.resUrl != item.url) record = null;
        // 根据资源与视频下标切换视频播放地址
        final result =
            await animeParser.getPlayUrls([item], cancelToken: _cancelToken);
        if (result.isEmpty) throw Exception('视频地址解析失败');
        String playUrl = result.first.playUrl;
        final downloadRecord = await db.getDownloadRecord(playUrl,
            status: [DownloadRecordStatus.complete]);
        // 如果视频已下载则使用本地路径;
        // 如果播放地址为m3u8则使用本地过滤缓存机制;
        if (downloadRecord != null) {
          playUrl = downloadRecord.playFilePath;
        } else if (playUrl.endsWith('.m3u8')) {
          final result = await M3U8Parser()
              .cacheFilter(playUrl, cancelToken: _cancelToken);
          if (result != null) playUrl = result.path;
        }
        // 播放已下载视频或者在线视频并跳转到指定位置
        await controller.play(playUrl);
        if (record != null) {
          final duration = Duration(
            milliseconds: record.progress,
          );
          await _waitVideoDuration();
          controller.seekTo(duration);
        }
        playRecord.setValue(record);
      } catch (e) {
        SnackTool.showMessage(message: '获取播放地址失败，请重试~');
        rethrow;
      }
    }));
  }

  // 终止视频播放与资源获取
  Future<void> cancelVideoPlay() async {
    _cancelToken?.cancel();
    _cancelToken = null;
    await controller.stop();
  }

  // 根据标记恢复播放
  Future<void> resumePlayByFlag() async {
    if (!resumeFlag.value) return;
    resumeFlag.setValue(false);
    return controller.resume();
  }

  // 进入播放页面设置(横向布局且不显示状态栏)
  void entryPlayer() async {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    setScreenOrientation(false);
  }

  // 退出播放页面设置(恢复布局并显示状态栏)
  void quitPlayer() async {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: SystemUiOverlay.values);
    setScreenOrientation(true);
  }

  // 一定时间后关闭播放记录弹窗
  void time2CloseRecord() => Debounce.c(
        () => playRecord.setValue(null),
        'time2CloseRecord',
        delay: const Duration(milliseconds: 5000),
      );

  // 更新视频进度
  void _updateVideoProgress(Duration progress) {
    if (progress < const Duration(seconds: 5)) return;
    final source = animeParser.currentSource;
    if (source == null) return;
    final item = animeInfo.value;
    final resItem = resourceInfo.value;
    db.updatePlayRecord(PlayRecord()
      ..url = item.url
      ..name = item.name
      ..cover = item.cover
      ..source = source.key
      ..resUrl = resItem.url
      ..resName = resItem.name
      ..progress = progress.inMilliseconds);
  }

  // 跳转到视频的开始位置
  Future<void> seekVideo2Rest() async {
    playRecord.setValue(null);
    await _waitVideoDuration();
    await controller.seekTo(const Duration(seconds: 1));
  }

  // 等待获取视频时长
  Future<void> _waitVideoDuration() async {
    if (controller.state.duration > Duration.zero) return;
    await controller.stream.duration.first;
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

  // 监听音频设备状态
  void _listenAudioSession() async {
    const configure = AudioSessionConfiguration.music();
    final session = await AudioSession.instance;
    await session.configure(configure);
    session.devicesChangedEventStream.listen((event) {
      if (event.devicesRemoved.isNotEmpty) {
        if (controller.state.playing) controller.pause();
      }
    });
  }

  @override
  void dispose() {
    // 种植视频播放并销毁资源获取
    cancelVideoPlay();
    // 销毁控制器
    controller.dispose();
    // 退出播放器状态
    quitPlayer();
    super.dispose();
  }
}
