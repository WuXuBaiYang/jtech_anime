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

  const AnimeDetailInfo(
      {super.key, required this.animeInfo, this.continueButton});

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Stack(
        fit: StackFit.expand,
        children: [
          _buildInfoBackground(),
          _buildInfo(),
        ],
      ),
    );
  }

  // 构建背景图
  Widget _buildInfoBackground() {
    return BlurView(
      blur: 20,
      color: Colors.white,
      child: Image.network(
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
        maxLines: 1,
        style: textStyle,
        overflow: TextOverflow.ellipsis,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const BackButton(),
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
                  Expanded(child: Text('简介：${animeInfo.intro}', maxLines: 3)),
                  if (continueButton != null) ...[
                    const SizedBox(width: 14),
                    continueButton!,
                  ],
                ],
              ),
            ),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 8),
        CustomScrollText.slow(
          animeInfo.name,
          style: textStyle.copyWith(color: Colors.black, fontSize: 20),
        ),
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
