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

  const AnimeDetailInfo({
    super.key,
    required this.animeInfo,
    this.continueButton,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        _buildInfoBackground(),
        _buildInfo(),
      ],
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

  // 构建信息部分
  Widget _buildInfo() {
    return DefaultTextStyle(
      maxLines: 999,
      style: const TextStyle(
        color: Colors.black54,
        fontSize: 14,
      ),
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
                if (continueButton != null) continueButton!,
              ],
            ),
          ),
        ),
        Text('简介：${animeInfo.intro}', maxLines: 5),
      ],
    );
  }
}
