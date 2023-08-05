import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:isar/isar.dart';
import 'package:jtech_anime/common/common.dart';
import 'package:jtech_anime/common/logic.dart';
import 'package:jtech_anime/common/notifier.dart';
import 'package:jtech_anime/common/route.dart';
import 'package:jtech_anime/manage/cache.dart';
import 'package:jtech_anime/manage/db.dart';
import 'package:jtech_anime/manage/parser.dart';
import 'package:jtech_anime/manage/router.dart';
import 'package:jtech_anime/manage/theme.dart';
import 'package:jtech_anime/model/anime.dart';
import 'package:jtech_anime/model/database/collect.dart';
import 'package:jtech_anime/model/database/download_record.dart';
import 'package:jtech_anime/model/database/play_record.dart';
import 'package:jtech_anime/page/detail/download.dart';
import 'package:jtech_anime/page/detail/info.dart';
import 'package:jtech_anime/tool/loading.dart';
import 'package:jtech_anime/tool/snack.dart';
import 'package:jtech_anime/widget/future_builder.dart';
import 'package:jtech_anime/widget/refresh/controller.dart';
import 'package:jtech_anime/widget/status_box.dart';
import 'package:jtech_anime/widget/text_scroll.dart';

/*
* 动漫详情页
* @author wuxubaiyang
* @Time 2023/7/12 9:07
*/
class AnimeDetailPage extends StatefulWidget {
  const AnimeDetailPage({super.key});

  @override
  State<StatefulWidget> createState() => _AnimeDetailPageState();
}

/*
* 动漫详情页-状态
* @author wuxubaiyang
* @Time 2023/7/12 9:07
*/
class _AnimeDetailPageState
    extends LogicState<AnimeDetailPage, _AnimeDetailLogic> {
  @override
  _AnimeDetailLogic initLogic() => _AnimeDetailLogic();

  @override
  Widget buildWidget(BuildContext context) {
    return Scaffold(
      body: ValueListenableBuilder<AnimeModel>(
        valueListenable: logic.animeDetail,
        builder: (_, animeDetail, __) {
          return DefaultTabController(
            length: animeDetail.resources.length,
            child: NestedScrollView(
              controller: logic.scrollController,
              headerSliverBuilder: (_, __) {
                return [_buildAppbar(animeDetail)];
              },
              body: _buildAnimeResources(animeDetail.resources),
            ),
          );
        },
      ),
    );
  }

  // 构建标题栏
  Widget _buildAppbar(AnimeModel item) {
    return ValueListenableBuilder<bool>(
      valueListenable: logic.showAppbar,
      builder: (_, showAppbar, __) {
        return SliverAppBar(
          pinned: true,
          leading: AnimatedOpacity(
            opacity: showAppbar ? 1 : 0,
            duration: const Duration(milliseconds: 200),
            child: const BackButton(),
          ),
          title: AnimatedOpacity(
            opacity: showAppbar ? 1 : 0,
            duration: const Duration(milliseconds: 200),
            child: Text(item.name),
          ),
          actions: [
            ValueListenableBuilder(
              valueListenable: logic.loading,
              builder: (_, isLoading, __) {
                return IconButton(
                  color: kPrimaryColor,
                  icon: isLoading
                      ? const SizedBox.square(
                          dimension: 20, child: CircularProgressIndicator())
                      : const Icon(FontAwesomeIcons.arrowsRotate),
                  onPressed: () => Loading.show(
                      loadFuture: logic.loadAnimeDetail(useCache: false)),
                );
              },
            ),
            ValueListenableBuilder<Collect?>(
              valueListenable: logic.collectInfo,
              builder: (_, collect, __) {
                if (collect == null) return const SizedBox();
                return IconButton(
                  color: kPrimaryColor,
                  icon: Icon(collect.collected
                      ? FontAwesomeIcons.heartCircleCheck
                      : FontAwesomeIcons.heart),
                  onPressed: () => logic.updateCollect(collect),
                );
              },
            ),
          ],
          automaticallyImplyLeading: false,
          expandedHeight: _AnimeDetailLogic.expandedHeight,
          flexibleSpace: FlexibleSpaceBar(
            background: Padding(
              padding: const EdgeInsets.only(
                bottom: kToolbarHeight,
              ),
              child: ValueListenableBuilder<PlayRecord?>(
                valueListenable: logic.playRecord,
                builder: (_, playRecord, __) {
                  return AnimeDetailInfo(
                    animeInfo: item,
                    continueButton: playRecord != null
                        ? ElevatedButton(
                            onPressed: () => logic.playTheRecord(),
                            child: const Text('继续观看'),
                          )
                        : null,
                  );
                },
              ),
            ),
          ),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(kToolbarHeight),
            child: Container(
              color: !showAppbar ? Colors.white : null,
              child: _buildAppbarBottom(item.resources),
            ),
          ),
        );
      },
    );
  }

  // 构建标题栏底部
  Widget _buildAppbarBottom(List<List<ResourceItemModel>> resources) {
    return Row(
      children: [
        if (resources.isNotEmpty)
          TabBar(
            isScrollable: true,
            onTap: logic.resourceIndex.setValue,
            tabs: List.generate(
              resources.length,
              (i) => Tab(text: '资源${i + 1}'),
            ),
          ),
        const Spacer(),
        IconButton(
          icon: const Icon(FontAwesomeIcons.download),
          onPressed: () => DownloadSheet.show(
            context,
            animeInfo: logic.animeDetail.value,
            checkNetwork: logic.checkNetwork,
          ).whenComplete(logic.cacheController.refreshValue),
        ),
      ],
    );
  }

  // 构建动漫资源列表
  Widget _buildAnimeResources(List<List<ResourceItemModel>> resources) {
    if (resources.isEmpty) {
      return const Center(
        child: StatusBox(status: StatusBoxStatus.empty),
      );
    }
    return CacheFutureBuilder<Map<String, DownloadRecord>>(
        controller: logic.cacheController,
        future: logic.loadDownloadRecord,
        builder: (_, snap) {
          if (!snap.hasData) return const SizedBox();
          final downloadMap = snap.data!;
          return ValueListenableBuilder<PlayRecord?>(
            valueListenable: logic.playRecord,
            builder: (_, playRecord, __) {
              return TabBarView(
                children: List.generate(resources.length, (i) {
                  final items = resources[i];
                  return GridView.builder(
                    itemCount: items.length,
                    padding:
                        const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      mainAxisExtent: 40,
                      crossAxisCount: 4,
                      mainAxisSpacing: 8,
                      crossAxisSpacing: 8,
                    ),
                    itemBuilder: (_, i) {
                      final item = items[i];
                      return _buildAnimeResourcesItem(
                          item, downloadMap, playRecord?.resUrl);
                    },
                  );
                }),
              );
            },
          );
        });
  }

  // 构建番剧资源子项
  Widget _buildAnimeResourcesItem(ResourceItemModel item,
      Map<String, DownloadRecord> downloadMap, String? playResUrl) {
    final downloadRecord = downloadMap[item.url];
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      child: Stack(
        children: [
          Container(
            width: double.maxFinite,
            height: double.maxFinite,
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(horizontal: 4),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.black26),
            ),
            child: playResUrl == item.url
                ? CustomScrollText.slow('上次看到 ${item.name}',
                    style: TextStyle(color: kPrimaryColor))
                : Text(item.name, maxLines: 1, overflow: TextOverflow.ellipsis),
          ),
          if (downloadRecord != null)
            Align(
              alignment: Alignment.bottomRight,
              child: Icon(
                  downloadRecord.status == DownloadRecordStatus.complete
                      ? FontAwesomeIcons.circleCheck
                      : FontAwesomeIcons.circleDown,
                  color: kPrimaryColor,
                  size: 14),
            ),
        ],
      ),
      onTap: () => logic.goPlay(item),
    );
  }
}

/*
* 动漫详情页-逻辑
* @author wuxubaiyang
* @Time 2023/7/12 9:07
*/
class _AnimeDetailLogic extends BaseLogic {
  // 折叠高度
  static const double expandedHeight = 350.0;

  // 动漫详情
  late ValueChangeNotifier<AnimeModel> animeDetail;

  // 滚动控制器
  final scrollController = ScrollController();

  // 是否展示标题状态
  final showAppbar = ValueChangeNotifier<bool>(false);

  // 当前展示的资源列表下标
  final resourceIndex = ValueChangeNotifier<int>(0);

  // 播放记录
  final playRecord = ValueChangeNotifier<PlayRecord?>(null);

  // 刷新控制器
  final controller = CustomRefreshController();

  // 收藏信息
  final collectInfo = ValueChangeNotifier<Collect?>(null);

  // 缓存控制器
  final cacheController =
      CacheFutureBuilderController<Map<String, DownloadRecord>>();

  // 是否检查网络状态
  final checkNetwork = ValueChangeNotifier<bool>(
      cache.getBool(Common.checkNetworkStatusKey) ?? true);

  @override
  void init() {
    super.init();
    // 监听滚动控制
    scrollController.addListener(() {
      // 修改标题栏展示状态
      showAppbar.setValue(
        scrollController.offset > expandedHeight - kToolbarHeight * 2,
      );
    });
  }

  @override
  void setupArguments(BuildContext context, Map arguments) {
    // 设置传入的番剧信息
    animeDetail = ValueChangeNotifier(arguments['animeDetail']);
    // 获取下载记录
    final downloadRecord = arguments['downloadRecord'];
    // 判断是否需要播放观看记录
    final play = arguments['playTheRecord'] ?? false;
    // 初始化
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // 初始化加载番剧详情
      Loading.show(loadFuture: loadAnimeDetail())?.whenComplete(() {
        // 加载完番剧详情后播放记录
        if (play) playTheRecord();
        // 如果存在下载记录则代表需要直接播放已下载视频
        if (downloadRecord != null) playTheDownload(downloadRecord);
      });
    });
  }

  // 更新收藏状态（收藏/取消收藏）
  Future<void> updateCollect(Collect item) async {
    if (isLoading) return;
    try {
      final result = await db.updateCollect(item);
      collectInfo.setValue(item.copyWith(
        id: result?.id ?? Isar.autoIncrement,
        collected: result != null,
      ));
    } catch (e) {
      SnackTool.showMessage(
          message: '${item.id != Isar.autoIncrement ? '取消收藏' : '收藏'}失败，请重试~');
    }
  }

  // 播放记录
  Future<void>? playTheRecord() {
    final record = playRecord.value;
    if (record == null) return null;
    return goPlay(
      ResourceItemModel(
        name: record.resName,
        url: record.resUrl,
      ),
      playTheRecord: true,
    );
  }

  // 播放下载内容
  Future<void>? playTheDownload(DownloadRecord record) {
    return goPlay(
      ResourceItemModel(
        name: record.name,
        url: record.resUrl,
      ),
    );
  }

  // 播放视频
  Future<void>? goPlay(ResourceItemModel item, {bool playTheRecord = false}) {
    if (animeDetail.value.resources.isEmpty) return null;
    return router.pushNamed(RoutePath.player, arguments: {
      'animeDetail': animeDetail.value,
      'playTheRecord': playTheRecord,
      'item': item,
    })?.then((_) async {
      final url = animeDetail.value.url;
      final record = await db.getPlayRecord(url);
      playRecord.setValue(record);
    });
  }

  // 加载番剧详情
  Future<void> loadAnimeDetail({bool useCache = true}) async {
    if (isLoading) return;
    final animeUrl = animeDetail.value.url;
    if (animeUrl.isEmpty) return;
    loading.setValue(true);
    try {
      // 获取播放记录
      final record = await db.getPlayRecord(animeUrl);
      playRecord.setValue(record);
      // 获取番剧详细信息，是否使用缓存加载
      final result = await parserHandle.getAnimeDetail(
        useCache: useCache,
        animeUrl,
      );
      animeDetail.setValue(result);
      // 根据番剧信息添加收藏信息
      final collect = await db.getCollect(animeUrl);
      collectInfo.setValue(collect ??
          (Collect()
            ..url = result.url
            ..name = result.name
            ..cover = result.cover
            ..source = parserHandle.currentSource
            ..collected = false));
    } catch (e) {
      SnackTool.showMessage(message: '番剧加载失败，请重试~');
    } finally {
      loading.setValue(false);
    }
  }

  // 加载下载记录
  Future<Map<String, DownloadRecord>> loadDownloadRecord() async {
    final result = await db.getDownloadRecordList(
      parserHandle.currentSource,
      animeList: [animeDetail.value.url],
    );
    return result.asMap().map((_, v) => MapEntry(v.resUrl, v));
  }
}
