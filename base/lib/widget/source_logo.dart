import 'package:flutter/material.dart';
import 'package:jtech_anime_base/manage/theme.dart';
import 'package:jtech_anime_base/model/database/source.dart';
import 'package:jtech_anime_base/widget/image.dart';

/*
* 番剧解析源图标
* @author wuxubaiyang
* @Time 2023/8/16 14:43
*/
class AnimeSourceLogo extends StatelessWidget {
  // 番剧解析源
  final AnimeSource source;

  // 图标尺寸
  final double ratio;

  const AnimeSourceLogo({
    super.key,
    required this.source,
    this.ratio = 20,
  });

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: ratio,
      backgroundColor: source.getColor(),
      child: _buildSourceIcon(source),
    );
  }

  // 构建数据源图标
  Widget _buildSourceIcon(AnimeSource source) {
    if (source.logoUrl.isNotEmpty) {
      return ImageView.net(source.logoUrl, size: ratio * 0.85);
    }
    final textStyle = TextStyle(color: kPrimaryColor);
    if (source.name.isNotEmpty) {
      return Text(
        source.name.substring(0, 1),
        style: textStyle,
      );
    }
    if (source.key.isNotEmpty) {
      return Text(
        source.key.substring(0, 1),
        style: textStyle,
      );
    }
    return const SizedBox();
  }
}
