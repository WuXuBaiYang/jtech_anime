import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:jtech_anime/common/logic.dart';
import 'package:jtech_anime/common/notifier.dart';
import 'package:jtech_anime/manage/router.dart';
import 'package:jtech_anime/model/anime.dart';
import 'package:jtech_anime/model/database/video_cache.dart';
import 'package:jtech_anime/page/player/player.dart';

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
    return CustomVideoPlayer();
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

  // 当前视频播放地址
  final videoInfo = ValueChangeNotifier<VideoCache?>(null);

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
    changeVideo(context, arguments['item']).catchError((_) {
      setOrientation(true);
      router.pop();
    });
  }

  // 获取资源列表
  List<List<ResourceItemModel>> get resources => animeInfo.value.resources;

  // 设置屏幕方向
  void setOrientation(bool portraitUp) {
    SystemChrome.setPreferredOrientations([
      portraitUp
          ? DeviceOrientation.portraitUp
          : DeviceOrientation.landscapeLeft,
    ]);
  }

  // 选择资源/视频
  Future<void> changeVideo(BuildContext context, ResourceItemModel item) async {
    // if (isLoading) return;
    // final resources = animeInfo.value.resources;
    // if (resources.isEmpty) return;
    // try {
    //   loading.setValue(true);
    //   // 根据资源与视频下标切换视频播放地址
    //   final result = await parserHandle.getAnimeVideoCache([item]);
    //   if (result.isEmpty) throw Exception('视频地址解析失败');
    //   videoInfo.setValue(result.first..item = item);
    // } catch (e) {
    //   SnackTool.showMessage(context, message: '获取播放地址失败，请重试~');
    //   rethrow;
    // } finally {
    //   loading.setValue(false);
    // }
  }
}
