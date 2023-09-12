import 'package:desktop/common/route.dart';
import 'package:flutter/material.dart';
import 'package:jtech_anime_base/base.dart';

/*
* 番剧浏览记录页面
* @author wuxubaiyang
* @Time 2023/9/11 14:48
*/
class HomeRecordPage extends StatefulWidget {
  const HomeRecordPage({super.key});

  @override
  State<StatefulWidget> createState() => _HomeRecordPageState();
}

/*
* 番剧浏览记录页面-状态
* @author wuxubaiyang
* @Time 2023/9/11 14:48
*/
class _HomeRecordPageState
    extends LogicState<HomeRecordPage, _HomeRecordLogic> {
  @override
  _HomeRecordLogic initLogic() => _HomeRecordLogic();

  @override
  Widget buildWidget(BuildContext context) {
    return Scaffold(
      body: _buildRecords(),
      floatingActionButton: _buildPlayFAB(),
    );
  }

  // 构建播放按钮
  Widget _buildPlayFAB() {
    return ValueListenableBuilder<List<PlayRecord>>(
      valueListenable: logic.playRecords,
      builder: (_, playRecords, ___) {
        if (playRecords.isEmpty) return const SizedBox();
        return FloatingActionButton(
          child: const Icon(FontAwesomeIcons.play),
          onPressed: () => logic.goLatestDetail(),
        );
      },
    );
  }

  // 构建播放记录列表
  Widget _buildRecords() {
    return ValueListenableBuilder<List<PlayRecord>>(
      valueListenable: logic.playRecords,
      builder: (_, playRecords, __) {
        return CustomRefreshView(
          enableRefresh: true,
          enableLoadMore: true,
          header: CustomRefreshViewHeader.classic,
          onRefresh: (loadMore) => logic.loadPlayRecords(loadMore),
          child: Stack(
            children: [
              if (playRecords.isEmpty)
                const Center(
                  child: StatusBox(
                    animSize: 100,
                    title: Text('还没有浏览记录~'),
                    status: StatusBoxStatus.empty,
                  ),
                ),
              ListView.builder(
                itemCount: playRecords.length,
                padding: const EdgeInsets.only(bottom: kToolbarHeight * 1.5),
                itemBuilder: (_, i) {
                  final item = playRecords[i];
                  return _buildRecordsItem(item);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // 构建播放记录项
  Widget _buildRecordsItem(PlayRecord item) {
    final progress = Duration(milliseconds: item.progress);
    const titleStyle = TextStyle(fontSize: 16, color: Colors.black87);
    const subTitleStyle = TextStyle(fontSize: 12, color: Colors.black38);
    return InkWell(
      child: DefaultTextStyle(
        maxLines: 2,
        style: subTitleStyle,
        overflow: TextOverflow.ellipsis,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: ImageView.net(item.cover,
                    width: 80, height: 100, fit: BoxFit.cover),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(item.name, style: titleStyle),
                    const SizedBox(height: 8),
                    Text.rich(TextSpan(text: '播放至：', children: [
                      TextSpan(
                        text: progress.format(DurationPattern.fullTime),
                        style: TextStyle(color: kPrimaryColor),
                      )
                    ])),
                    const SizedBox(height: 4),
                    Text(item.resName, style: TextStyle(color: kPrimaryColor)),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
              Icon(FontAwesomeIcons.play, color: kPrimaryColor),
              const SizedBox(width: 14),
            ],
          ),
        ),
      ),
      onTap: () => logic.goDetail(item),
    );
  }
}

/*
* 番剧浏览记录页面-逻辑
* @author wuxubaiyang
* @Time 2023/9/11 14:48
*/
class _HomeRecordLogic extends BaseLogic {
  // 播放记录列表
  final playRecords = ListValueChangeNotifier<PlayRecord>.empty();

  // 分页下标
  int _pageIndex = 1;

  @override
  void init() {
    super.init();
    // 初始化加载收藏列表
    loadPlayRecords(false);
  }

  // 加载播放记录
  Future<void> loadPlayRecords(bool loadMore) async {
    if (isLoading) return;
    try {
      loading.setValue(true);
      final index = loadMore ? _pageIndex + 1 : 1;
      final source = animeParser.currentSource;
      if (source == null) throw Exception('数据源不存在');
      final result = await db.getPlayRecordList(source, pageIndex: index);
      if (result.isNotEmpty) {
        _pageIndex = index;
        return loadMore
            ? playRecords.addValues(result)
            : playRecords.setValue(result);
      }
    } catch (e) {
      SnackTool.showMessage(message: '播放记录加载失败，请重试~');
    } finally {
      loading.setValue(false);
    }
  }

  // 跳转到详情页
  Future<void>? goDetail(PlayRecord item) async {
    await router.pushNamed(RoutePath.animeDetail, arguments: {
      'animeDetail': AnimeModel(
        url: item.url,
        name: item.name,
        cover: item.cover,
      ),
      'playTheRecord': true,
    });
    final it = await db.getPlayRecord(item.url);
    if (it == null) return;
    if (it.updateTime.compareTo(item.updateTime) > 1) {
      if (playRecords.removeValue(item, notify: false)) {
        playRecords.insertValues(0, [it]);
      }
    }
  }

  // 跳转到最新一条视频的播放
  Future<void>? goLatestDetail() async {
    if (playRecords.isEmpty) return;
    return goDetail(playRecords.value.first);
  }
}
