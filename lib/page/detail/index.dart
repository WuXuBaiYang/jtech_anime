import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:jtech_anime/common/logic.dart';
import 'package:jtech_anime/common/notifier.dart';
import 'package:jtech_anime/common/route.dart';
import 'package:jtech_anime/manage/db.dart';
import 'package:jtech_anime/manage/parser.dart';
import 'package:jtech_anime/manage/router.dart';
import 'package:jtech_anime/manage/theme.dart';
import 'package:jtech_anime/model/anime.dart';
import 'package:jtech_anime/model/database/play_record.dart';
import 'package:jtech_anime/page/detail/info.dart';
import 'package:jtech_anime/tool/snack.dart';
import 'package:jtech_anime/tool/tool.dart';
import 'package:jtech_anime/widget/status_box.dart';
import 'package:jtech_anime/widget/text_scroll.dart';
import 'package:text_scroll/text_scroll.dart';

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
              child: _buildAppbarBottom(item.resources.length),
            ),
          ),
        );
      },
    );
  }

  // 构建标题栏底部
  Widget _buildAppbarBottom(int length) {
    return Row(
      children: [
        if (length > 0)
          TabBar(
            isScrollable: true,
            onTap: logic.resourceIndex.setValue,
            tabs: List.generate(length, (i) => Tab(text: '资源${i + 1}')),
          ),
        const Spacer(),
        IconButton(
          icon: const Icon(FontAwesomeIcons.download),
          onPressed: () {
            SnackTool.showMessage(context, message: '正在施工中~');
          },
        ),
        const SizedBox(width: 4),
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
    return TabBarView(
      children: List.generate(resources.length, (i) {
        final items = resources[i];
        return GridView.builder(
          itemCount: items.length,
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            mainAxisExtent: 40,
            crossAxisCount: 4,
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
          ),
          itemBuilder: (_, i) {
            final item = items[i];
            return _buildAnimeResourcesItem(item);
          },
        );
      }),
    );
  }

  // 构建番剧资源子项
  Widget _buildAnimeResourcesItem(ResourceItemModel item) {
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: double.maxFinite,
        height: double.maxFinite,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.black26),
        ),
        child: logic.playRecord.value?.resUrl == item.url
            ? CustomScrollText.slow('上次看到 ${item.name}',
                style: TextStyle(color: kPrimaryColor))
            : Text(item.name, maxLines: 1, overflow: TextOverflow.ellipsis),
      ),
      onTap: () => logic.play(item),
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
    // 判断是否需要播放观看记录
    final play = arguments['playTheRecord'] ?? false;
    // 初始化加载
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // 初始化加载番剧详情
      loadAnimeDetail(context).whenComplete(() {
        // 加载完番剧详情后播放记录
        if (play) playTheRecord();
      });
    });
  }

  // 播放记录
  Future<void>? playTheRecord() {
    final record = playRecord.value;
    if (record == null) return null;
    if (animeDetail.value.resources.isEmpty) return null;
    return play(ResourceItemModel(
      name: record.resName,
      url: record.resUrl,
    ));
  }

  // 播放视频
  Future<void>? play(ResourceItemModel item) {
    return router.pushNamed(RoutePath.player, arguments: {
      'animeDetail': animeDetail.value,
      'item': item,
    })?.then((v) {
      if (v is PlayRecord) playRecord.setValue;
    });
  }

  // 加载番剧详情
  Future<void> loadAnimeDetail(BuildContext context) async {
    if (isLoading) return;
    final animeUrl = animeDetail.value.url;
    if (animeUrl.isEmpty) return;
    return Tool.showLoading(context, loadFuture: Future(() async {
      loading.setValue(true);
      try {
        // 获取播放记录
        final record = await db.getPlayRecord(animeUrl);
        playRecord.setValue(record);
        // 获取番剧详细信息
        final result = await parserHandle.getAnimeDetail(animeUrl);
        animeDetail.setValue(result);
      } catch (e) {
        SnackTool.showMessage(context, message: '番剧加载失败，请重试~');
      } finally {
        loading.setValue(false);
      }
    }));
  }
}
