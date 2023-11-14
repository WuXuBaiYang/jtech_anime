import 'package:flutter/material.dart';
import 'package:jtech_anime_base/model/anime.dart';
import 'package:jtech_anime_base/widget/refresh/controller.dart';
import 'package:jtech_anime_base/widget/refresh/refresh_view.dart';
import 'package:jtech_anime_base/widget/screen_builder.dart';
import 'anime_list_desktop.dart';
import 'anime_list_mobile.dart';

// 番剧点击事件
typedef AnimeListItemTap = void Function(AnimeModel item);

/*
* 番剧列表视图-基类
* @author wuxubaiyang
* @Time 2023/11/14 10:48
*/
abstract class BaseAnimeListView extends StatefulWidget {
  // 刷新控制器
  final CustomRefreshController? refreshController;

  // 是否启用下拉刷新
  final bool enableRefresh;

  // 是否启用上拉加载
  final bool enableLoadMore;

  // 是否初始化加载
  final bool initialRefresh;

  // 异步加载回调
  final AsyncRefreshCallback onRefresh;

  // 番剧列表
  final List<AnimeModel> animeList;

  // 空内容提示
  final Widget? emptyHint;

  // 列数
  final int columnCount;

  // 番剧点击事件
  final AnimeListItemTap? itemTap;

  // 添加头部组件
  final Widget? header;

  // 内间距
  final EdgeInsetsGeometry? padding;

  // 子项最大尺寸
  final Size? maxItemExtent;

  // 子项间距
  final double itemSpacing;

  const BaseAnimeListView({
    super.key,
    required this.animeList,
    required this.onRefresh,
    this.header,
    this.itemTap,
    this.padding,
    this.emptyHint,
    this.maxItemExtent,
    this.itemSpacing = 8,
    this.columnCount = 3,
    this.refreshController,
    this.enableRefresh = true,
    this.enableLoadMore = true,
    this.initialRefresh = false,
  });
}

/*
* 番剧列表视图
* @author wuxubaiyang
* @Time 2023/11/14 10:57
*/
class AnimeListView extends BaseAnimeListView {
  const AnimeListView({
    super.key,
    required super.animeList,
    required super.onRefresh,
    super.header,
    super.itemTap,
    super.padding,
    super.emptyHint,
    super.itemSpacing,
    super.columnCount,
    super.enableRefresh,
    super.maxItemExtent,
    super.enableLoadMore,
    super.initialRefresh,
    super.refreshController,
  });

  @override
  State<StatefulWidget> createState() => _AnimeListViewState();
}

/*
* 番剧列表-状态
* @author wuxubaiyang
* @Time 2023/8/28 16:14
*/
class _AnimeListViewState extends State<AnimeListView> {
  @override
  Widget build(BuildContext context) {
    return ScreenBuilder(
      builder: (_) => DesktopAnimeListView(
        animeList: widget.animeList,
        onRefresh: widget.onRefresh,
        header: widget.header,
        itemTap: widget.itemTap,
        padding: widget.padding,
        emptyHint: widget.emptyHint,
        maxItemExtent: widget.maxItemExtent,
        itemSpacing: widget.itemSpacing,
        refreshController: widget.refreshController,
        enableRefresh: widget.enableRefresh,
        enableLoadMore: widget.enableLoadMore,
        initialRefresh: widget.initialRefresh,
        columnCount: widget.columnCount,
      ),
      mobile: (_) => MobileAnimeListView(
        animeList: widget.animeList,
        onRefresh: widget.onRefresh,
        header: widget.header,
        itemTap: widget.itemTap,
        padding: widget.padding,
        emptyHint: widget.emptyHint,
        maxItemExtent: widget.maxItemExtent,
        itemSpacing: widget.itemSpacing,
        refreshController: widget.refreshController,
        enableRefresh: widget.enableRefresh,
        enableLoadMore: widget.enableLoadMore,
        initialRefresh: widget.initialRefresh,
      ),
    );
  }
}
