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

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: expanded ? StackFit.loose : StackFit.expand,
      children: [
        if (!expanded) _buildInfoBackground(),
        _buildInfo(),
      ],
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

  // 构建信息部分
  Widget _buildInfo() {
    return DefaultTextStyle(
      style: const TextStyle(
        color: Colors.black54,
        fontSize: 14,
      ),
      maxLines: expanded ? 999 : 1,
      overflow: TextOverflow.ellipsis,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Expanded(child: _buildInfoText()),
            const SizedBox(width: 24),
            _buildInfoCover(),
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
          width: 200, height: 260, fit: BoxFit.cover),
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
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Text(
            animeInfo.name,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 20,
            ),
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: lines
                        .where((e) => e.isNotEmpty)
                        .map<Widget>((e) => Text(e))
                        .expand((e) => [const SizedBox(height: 4), e])
                        .toList(),
                  ),
                ),
                if (continueButton != null && !expanded) continueButton!,
              ],
            ),
          ),
        ),
        Text(
          '简介：${animeInfo.intro}',
          maxLines: expanded ? null : 5,
        ),
      ],
    );
  }
}
