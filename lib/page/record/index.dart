import 'package:flutter/material.dart';
import 'package:jtech_anime/common/logic.dart';
import 'package:jtech_anime/common/notifier.dart';
import 'package:jtech_anime/common/route.dart';
import 'package:jtech_anime/manage/db.dart';
import 'package:jtech_anime/manage/parser.dart';
import 'package:jtech_anime/manage/router.dart';
import 'package:jtech_anime/manage/theme.dart';
import 'package:jtech_anime/model/anime.dart';
import 'package:jtech_anime/model/database/play_record.dart';
import 'package:jtech_anime/tool/date.dart';
import 'package:jtech_anime/tool/snack.dart';
import 'package:jtech_anime/widget/image.dart';
import 'package:jtech_anime/widget/status_box.dart';

/*
* 播放记录页
* @author wuxubaiyang
* @Time 2023/7/13 17:31
*/
class PlayRecordPage extends StatefulWidget {
  const PlayRecordPage({super.key});

  @override
  State<StatefulWidget> createState() => _PlayRecordPageState();
}

/*
* 播放记录页-状态
* @author wuxubaiyang
* @Time 2023/7/13 17:31
*/
class _PlayRecordPageState
    extends LogicState<PlayRecordPage, _PlayRecordLogic> {
  @override
  _PlayRecordLogic initLogic() => _PlayRecordLogic();

  @override
  void initState() {
    super.initState();
    // 初始化设置
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // 初始化加载
      logic.loadPlayRecords(context, false);
      // 判断是否滚动到底部
      logic.scrollController.addListener(() {
        if (logic.scrollController.offset >=
            logic.scrollController.position.maxScrollExtent) {
          logic.loadPlayRecords(context, true);
        }
      });
    });
  }

  @override
  Widget buildWidget(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('播放记录'),
      ),
      body: _buildPlayRecords(context),
    );
  }

  // 构建播放记录列表
  Widget _buildPlayRecords(BuildContext context) {
    return ValueListenableBuilder<List<PlayRecord>>(
      valueListenable: logic.playRecords,
      builder: (_, playRecords, __) {
        return Stack(
          children: [
            if (playRecords.isEmpty)
              const Center(
                child: StatusBox(
                  status: StatusBoxStatus.empty,
                  title: Text('还没有播放记录~'),
                ),
              ),
            ListView.builder(
              controller: logic.scrollController,
              itemCount: playRecords.length,
              itemBuilder: (_, i) {
                final item = playRecords[i];
                return _buildPlayRecordsItem(context, item);
              },
            ),
          ],
        );
      },
    );
  }

  // 标题文本样式
  final titleStyle = const TextStyle(fontSize: 14, color: Colors.black87);

  // 内容文本样式
  final subTitleStyle = const TextStyle(fontSize: 12, color: Colors.black38);

  // 构建播放记录项
  Widget _buildPlayRecordsItem(BuildContext context, PlayRecord item) {
    final progress = Duration(seconds: item.progress);
    return InkWell(
      child: DefaultTextStyle(
        maxLines: 2,
        style: subTitleStyle,
        overflow: TextOverflow.ellipsis,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
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
                    const SizedBox(height: 8),
                    Text(item.name, style: titleStyle),
                    const SizedBox(height: 18),
                    Text(item.resName, style: TextStyle(color: kPrimaryColor)),
                    const SizedBox(height: 8),
                    Text('播放至：${progress.format(DurationPattern.fullTime)}'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      onTap: () => router.pushNamed(RoutePath.animeDetail, arguments: {
        'animeDetail': AnimeModel(
          url: item.url,
          name: item.name,
          cover: item.cover,
        ),
        'playTheRecord': true,
      })?.then((_) => logic.loadPlayRecords(context, false)),
    );
  }
}

/*
* 播放记录页-逻辑
* @author wuxubaiyang
* @Time 2023/7/13 17:31
*/
class _PlayRecordLogic extends BaseLogic {
  // 播放记录列表
  final playRecords = ListValueChangeNotifier<PlayRecord>.empty();

  // 当前页码
  var _pageIndex = 1;

  // 分页数据量
  final _pageSize = 25;

  // 滚动控制器
  final scrollController = ScrollController();

  // 加载播放记录
  Future<void> loadPlayRecords(BuildContext context, bool loadMore) async {
    if (isLoading) return;
    try {
      loading.setValue(true);
      final index = loadMore ? _pageIndex + 1 : 1;
      final result = await db.getPlayRecordList(
        parserHandle.currentSource,
        pageSize: _pageSize,
        pageIndex: index,
      );
      if (result.isNotEmpty) {
        _pageIndex = index;
        return loadMore
            ? playRecords.addValues(result)
            : playRecords.setValue(result);
      }
    } catch (e) {
      SnackTool.showMessage(context, message: '播放记录加载失败，请重试~');
    } finally {
      loading.setValue(false);
    }
  }
}
