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

  // 名称后的操作按钮
  final List<Widget> nameActions;

  const AnimeDetailInfo({
    super.key,
    required this.animeInfo,
    this.continueButton,
    this.nameActions = const [],
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
      maxLines: 1,
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
            Stack(
              alignment: Alignment.bottomCenter,
              children: [
                _buildInfoCover(),
                Transform.translate(
                  offset: const Offset(0, 14),
                  child: continueButton ?? const SizedBox(),
                ),
              ],
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
          width: 200, height: 250, fit: BoxFit.cover),
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
        Row(
          children: [
            Expanded(
              child: Text(
                maxLines: 2,
                animeInfo.name,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 24,
                ),
              ),
            ),
            const SizedBox(width: 14),
            ...nameActions,
          ],
        ),
        const SizedBox(height: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: lines
                .where((e) => e.isNotEmpty)
                .map<Widget>((e) => Text(e))
                .expand((e) => [const SizedBox(height: 4), e])
                .toList(),
          ),
        ),
        Text('简介：${animeInfo.intro}', maxLines: 5),
      ],
    );
  }
}
