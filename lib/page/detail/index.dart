import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:jtech_anime/common/logic.dart';
import 'package:jtech_anime/common/notifier.dart';
import 'package:jtech_anime/common/route.dart';
import 'package:jtech_anime/manage/parser.dart';
import 'package:jtech_anime/manage/router.dart';
import 'package:jtech_anime/model/anime.dart';
import 'package:jtech_anime/page/detail/info.dart';
import 'package:jtech_anime/tool/snack.dart';
import 'package:jtech_anime/tool/tool.dart';
import 'package:jtech_anime/widget/status_box.dart';

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
  void initState() {
    super.initState();
    // 初始化加载
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // 初始化加载动漫详情
      logic.loadAnimeDetail(context);
    });
  }

  @override
  Widget buildWidget(BuildContext context) {
    return Scaffold(
      body: PrimaryScrollController(
        controller: logic.scrollController,
        child: ValueListenableBuilder<AnimeModel>(
          valueListenable: logic.animeDetail,
          builder: (_, animeDetail, __) {
            return DefaultTabController(
              length: animeDetail.resources.length,
              child: NestedScrollView(
                headerSliverBuilder: (_, __) {
                  return [_buildAppbar(animeDetail)];
                },
                body: _buildAnimeResources(animeDetail.resources),
              ),
            );
          },
        ),
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
              child: AnimeDetailInfo(
                animeInfo: item,
              ),
            ),
          ),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(kToolbarHeight),
            child: _buildAppbarBottom(item.resources.length),
          ),
        );
      },
    );
  }

  // 构建标题栏底部
  Widget _buildAppbarBottom(int length) {
    return Row(
      children: [
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
            border: Border.all(
              color: Colors.black26,
            )),
        child: Text(
          item.name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      onTap: () => router.pushNamed(RoutePath.player, arguments: {
        'animeDetail': logic.animeDetail.value,
        'item': item,
      }),
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

  // 加载状态
  final loading = ValueChangeNotifier<bool>(false);

  // 滚动控制器
  final scrollController = ScrollController();

  // 是否展示标题状态
  final showAppbar = ValueChangeNotifier<bool>(false);

  // 当前展示的资源列表下标
  final resourceIndex = ValueChangeNotifier<int>(0);

  @override
  void init() {
    super.init();
    // 监听滚动控制
    scrollController.addListener(() {
      // 修改标题栏展示状态
      showAppbar.setValue(
        scrollController.offset > expandedHeight - kToolbarHeight - 50,
      );
    });
  }

  @override
  void setupArguments(BuildContext context, Map arguments) {
    // 设置传入的番剧信息
    animeDetail = ValueChangeNotifier(arguments['animeDetail']);
  }

  // 加载番剧详情
  Future<void> loadAnimeDetail(BuildContext context) async {
    if (loading.value) return;
    final animeUrl = animeDetail.value.url;
    if (animeUrl.isEmpty) return;
    return Tool.showLoading(context, loadFuture: Future(() async {
      loading.setValue(true);
      try {
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
