import 'package:flutter/material.dart';
import 'package:jtech_anime_base/base.dart';

/*
* 动漫详情信息
* @author wuxubaiyang
* @Time 2023/7/12 10:00
*/
class AnimeDetailInfo extends StatelessWidget {
  // 番剧信息
  final AnimeModel animeInfo;

  // 继续播放按钮
  final Widget? continueButton;

  // 是否可以展开
  final bool expanded;

  const AnimeDetailInfo({
    super.key,
    required this.animeInfo,
    this.continueButton,
    this.expanded = false,
  });

  // 展示为sheet
  static Future<void> show(
    BuildContext context, {
    required AnimeModel animeInfo,
    Widget? continueButton,
  }) {
    return showModalBottomSheet(
      context: context,
      builder: (_) {
        return SingleChildScrollView(
          child: AnimeDetailInfo(
            expanded: true,
            animeInfo: animeInfo,
            continueButton: continueButton,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      clipBehavior: Clip.antiAlias,
      child: Stack(
        fit: expanded ? StackFit.loose : StackFit.expand,
        children: [
          if (!expanded) _buildInfoBackground(),
          _buildInfo(),
        ],
      ),
    );
  }

  // 构建背景图
  Widget _buildInfoBackground() {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 1, end: 20),
      duration: const Duration(milliseconds: 800),
      builder: (_, value, child) {
        return BlurView(
          blur: value,
          color: Colors.white,
          child: child ?? const SizedBox(),
        );
      },
      child: ImageView.net(
        animeInfo.cover,
        fit: BoxFit.cover,
        width: double.maxFinite,
        height: double.maxFinite,
      ),
    );
  }

  // 文本样式
  final textStyle = const TextStyle(
    color: Colors.black54,
    fontSize: 14,
  );

  // 间距
  final padding = const EdgeInsets.symmetric(horizontal: 14);

  // 构建信息部分
  Widget _buildInfo() {
    return SafeArea(
      child: DefaultTextStyle(
        style: textStyle,
        maxLines: expanded ? 999 : 1,
        overflow: TextOverflow.ellipsis,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!expanded) const SizedBox(height: kToolbarHeight),
            Padding(
              padding: padding,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInfoCover(),
                  const SizedBox(width: 14),
                  Expanded(child: _buildInfoText()),
                ],
              ),
            ),
            Padding(
              padding: padding.copyWith(bottom: 0, top: 14),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                      child: Text('简介：${animeInfo.intro}',
                          maxLines: expanded ? null : 3)),
                  if (continueButton != null && !expanded) ...[
                    const SizedBox(width: 14),
                    continueButton!,
                  ],
                ],
              ),
            ),
            if (expanded) const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  // 构建封面
  Widget _buildInfoCover() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: ImageView.net(animeInfo.cover,
          width: 110, height: 150, fit: BoxFit.cover),
    );
  }

  // 构建消息文本部分
  _buildInfoText() {
    final lines = <String>[
      animeInfo.status,
      animeInfo.updateTime,
      animeInfo.types.join('/'),
      animeInfo.region,
    ];
    final nameStyle = textStyle.copyWith(color: Colors.black, fontSize: 20);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 8),
        expanded
            ? Text(animeInfo.name, style: nameStyle)
            : CustomScrollText.slow(animeInfo.name, style: nameStyle),
        const SizedBox(height: 4),
        ...lines
            .where((e) => e.isNotEmpty)
            .map<Widget>((e) => Text(e))
            .expand((e) => [const SizedBox(height: 4), e])
            .toList(),
      ],
    );
  }
}
