import 'dart:async';
import 'package:battery_plus/battery_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_meedu_videoplayer/meedu_player.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:jtech_anime/common/logic.dart';
import 'package:jtech_anime/common/notifier.dart';
import 'package:jtech_anime/manage/db.dart';
import 'package:jtech_anime/manage/parser.dart';
import 'package:jtech_anime/manage/router.dart' as router;
import 'package:jtech_anime/manage/theme.dart';
import 'package:jtech_anime/model/anime.dart';
import 'package:jtech_anime/model/database/download_record.dart';
import 'package:jtech_anime/model/database/play_record.dart';
import 'package:jtech_anime/page/player/resource.dart';
import 'package:jtech_anime/tool/date.dart';
import 'package:jtech_anime/tool/debounce.dart';
import 'package:jtech_anime/tool/loading.dart';
import 'package:jtech_anime/tool/snack.dart';
import 'package:jtech_anime/tool/throttle.dart';
import 'package:jtech_anime/widget/future_builder.dart';
import 'package:jtech_anime/widget/text_scroll.dart';

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
    return Theme(
      data: _themeData,
      child: Scaffold(
        key: pageKey,
        backgroundColor: Colors.black,
        body: Stack(
          children: [
            Positioned.fill(child: _buildVideoPlayer()),
            Align(
              alignment: Alignment.bottomLeft,
              child: _buildPlayRecordTag(),
            ),
          ],
        ),
        endDrawerEnableOpenDragGesture: false,
        endDrawer: _buildResourceDrawer(),
      ),
    );
  }

  // 播放器页面样式
  ThemeData get _themeData => ThemeData.dark(useMaterial3: true).copyWith(
        colorScheme: ColorScheme.dark(
          primary: kPrimaryColor,
          secondary: kSecondaryColor,
        ),
      );

  // 构建资源侧栏弹窗
  Widget _buildResourceDrawer() {
    return ValueListenableBuilder<ResourceItemModel>(
      valueListenable: logic.resourceInfo,
      builder: (_, item, __) {
        return PlayerResourceDrawer(
          currentItem: item,
          resources: logic.resources,
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
    return MeeduVideoPlayer(
      controller: logic.controller,
      header: (_, controller, responsive) {
        return _buildVideoPlayerHeader();
      },
      bottomRight: (_, controller, responsive) {
        return _buildVideoPlayerBottomRight();
      },
    );
  }

  // 构建视频播放器头部
  Widget _buildVideoPlayerHeader() {
    const titleStyle = TextStyle(fontSize: 18);
    return Row(
      children: [
        const BackButton(),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomScrollText.slow(
              logic.animeInfo.value.name,
              style: titleStyle,
            ),
            _buildVideoPlayerHeaderSubTitle(),
          ],
        ),
        const Spacer(),
        _buildVideoPlayerHeaderTime(),
        const SizedBox(width: 8),
        _buildVideoPlayerHeaderBattery(),
        const SizedBox(width: 8),
      ],
    );
  }

  // 构建视频播放器头部子标题
  Widget _buildVideoPlayerHeaderSubTitle() {
    return ValueListenableBuilder<ResourceItemModel>(
      valueListenable: logic.resourceInfo,
      builder: (_, resource, __) {
        final subTitle = logic.resourceInfo.value.name;
        const subTitleStyle = TextStyle(fontSize: 12, color: Colors.white70);
        return Text(subTitle, style: subTitleStyle);
      },
    );
  }

  // 构建视频播放器头部时间
  Widget _buildVideoPlayerHeaderTime() {
    return ValueListenableBuilder<DateTime>(
      valueListenable: logic.currentTime,
      builder: (_, time, __) {
        return Text(time.format(DatePattern.time));
      },
    );
  }

  // 电池容量图标集合
  final _batteryIcons = [
    FontAwesomeIcons.batteryEmpty,
    FontAwesomeIcons.batteryQuarter,
    FontAwesomeIcons.batteryHalf,
    FontAwesomeIcons.batteryThreeQuarters,
    FontAwesomeIcons.batteryFull,
  ];

  // 构建视频播放器头部电池
  Widget _buildVideoPlayerHeaderBattery() {
    return CacheFutureBuilder<int>(
      future: () => Battery().batteryLevel,
      builder: (_, snap) {
        if (snap.hasData) {
          final value = snap.data! - 1;
          final per = 100 / _batteryIcons.length;
          return Icon(_batteryIcons[value ~/ per]);
        }
        return const SizedBox();
      },
    );
  }

  // 构建视频播放器底部右侧
  Widget _buildVideoPlayerBottomRight() {
    return Row(
      children: [
        ValueListenableBuilder<ResourceItemModel?>(
          valueListenable: logic.nextResourceInfo,
          builder: (_, resource, __) {
            if (resource == null) return const SizedBox();
            return TextButton(
              onPressed: Throttle.click(
                () => logic.changeVideo(resource),
                'playNextResource',
              ),
              child: const Text('下一集'),
            );
          },
        ),
        TextButton(
          child: const Text('选集'),
          onPressed: () => pageKey.currentState?.openEndDrawer(),
        ),
      ],
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
          margin: const EdgeInsets.only(bottom: 110, left: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                iconSize: 20,
                color: Colors.white54,
                icon: const Icon(FontAwesomeIcons.xmark),
                onPressed: () => logic.playRecord.setValue(null),
              ),
              Text('上次看到 $fullTime', style: textStyle),
              TextButton(
                onPressed: logic.seekVideo2Record,
                child: const Text('继续观看'),
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
      logic.controller
        ..lockedControls.value = false
        ..pause();
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
  // 当前番剧信息
  late ValueChangeNotifier<AnimeModel> animeInfo;

  // 当前播放的资源信息
  late ValueChangeNotifier<ResourceItemModel> resourceInfo;

  // 播放器控制器
  final controller = _createVideoController();

  // 存储下一条视频信息
  final nextResourceInfo = ValueChangeNotifier<ResourceItemModel?>(null);

  // 播放记录
  final playRecord = ValueChangeNotifier<PlayRecord?>(null);

  // 获取资源列表
  List<List<ResourceItemModel>> get resources => animeInfo.value.resources;

  // 当前时间
  final currentTime = ValueChangeNotifier<DateTime>(DateTime.now());

  // 计时器
  late final Timer _timer = Timer.periodic(
      const Duration(seconds: 1), (t) => currentTime.setValue(DateTime.now()));

  @override
  void init() {
    super.init();
    // 设置页面进入状态
    entryPlayer();
    // 监听视频播放进度
    Duration? total;
    controller.onPositionChanged.listen((e) {
      // 更新当前播放进度
      Throttle.c(
        () => _updateVideoProgress(e),
        'updateVideoProgress',
      );
      // 监听播放进度，当播放完成之后则自动播放下一集
      if (total != null && e >= total!) {
        final item = nextResourceInfo.value;
        if (item != null) {
          changeVideo(item);
          total = null;
        }
      }
    });
  }

  @override
  void setupArguments(BuildContext context, Map arguments) {
    animeInfo = ValueChangeNotifier(arguments['animeDetail']);
    resourceInfo = ValueChangeNotifier(arguments['item']);
    final playTheRecord = arguments['playTheRecord'];
    // 初始化
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // 选择当前视频(如果用户传入了播放记录则代表需要立即跳转到指定位置)
      changeVideo(resourceInfo.value, playTheRecord)
          .catchError((_) => router.router.pop());
    });
  }

  // 选择资源/视频
  Future<void> changeVideo(ResourceItemModel item,
      [bool playTheRecord = true]) async {
    if (isLoading) return;
    final resources = animeInfo.value.resources;
    if (resources.isEmpty) return;
    return Loading.show(loadFuture: Future(() async {
      try {
        loading.setValue(true);
        resourceInfo.setValue(item);
        nextResourceInfo.setValue(_findNextResourceItem(item));
        // 暂停现有播放器
        await controller.pause();
        // 根据当前资源获取播放记录
        final record = await db.getPlayRecord(animeInfo.value.url);
        // 根据资源与视频下标切换视频播放地址
        final result = await parserHandle.getAnimeVideoCache([item]);
        if (result.isEmpty) throw Exception('视频地址解析失败');
        final playUrl = result.first.playUrl;
        final downloadRecord = await db.getDownloadRecord(playUrl,
            status: [DownloadRecordStatus.complete]);
        // 解析完成之后实现视频播放
        final dataSource = downloadRecord != null
            ? DataSource(
                type: DataSourceType.file, file: downloadRecord.playFile)
            : DataSource(type: DataSourceType.network, source: playUrl);
        final seekTo = playTheRecord && record != null
            ? Duration(milliseconds: record.progress)
            : Duration.zero;
        await controller.setDataSource(dataSource, seekTo: seekTo);
        if (!playTheRecord) playRecord.setValue(record);
      } catch (e) {
        SnackTool.showMessage(message: '获取播放地址失败，请重试~');
        rethrow;
      } finally {
        loading.setValue(false);
      }
    }));
  }

  // 创建视频播放器控制器
  static MeeduPlayerController _createVideoController() {
    const errorText = '视频加载失败，请重试~';
    return MeeduPlayerController(
      controlsStyle: ControlsStyle.primary,
      enabledButtons: const EnabledButtons(
        rewindAndfastForward: false,
        playPauseAndRepeat: true,
        playBackSpeed: false,
        muteAndSound: true,
        lockControls: true,
        fullscreen: false,
        videoFit: false,
        pip: false,
      ),
      screenManager: const ScreenManager(
        orientations: [
          DeviceOrientation.landscapeRight,
          DeviceOrientation.landscapeLeft,
        ],
        systemUiMode: SystemUiMode.immersiveSticky,
      ),
      initialFit: BoxFit.fitHeight,
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

  // 退出播放页面设置(恢复布局并显示状态栏)
  void quitPlayer() {
    SystemChrome.setPreferredOrientations(DeviceOrientation.values);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  }

  // 一定时间后关闭播放记录弹窗
  void time2CloseRecord() => Debounce.c(
        () => playRecord.setValue(null),
        'time2CloseRecord',
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
    // 关闭计时器
    _timer.cancel();
    // 退出播放器状态
    quitPlayer();
    // 销毁控制器
    controller.dispose();
    super.dispose();
  }
}
