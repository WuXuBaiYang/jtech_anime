import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:jtech_anime_base/base.dart';

/*
* 番剧代理设置弹窗
* @author wuxubaiyang
* @Time 2023/8/30 17:29
*/
class AnimeSourceProxyDialog extends StatefulWidget {
  // 是否可取消
  final bool dismissible;

  const AnimeSourceProxyDialog({
    super.key,
    this.dismissible = true,
  });

  static Future<AnimeSource?> show(BuildContext context,
      {bool dismissible = true}) {
    return showCupertinoDialog<AnimeSource>(
      context: context,
      barrierDismissible: dismissible,
      builder: (_) {
        return AnimeSourceProxyDialog(
          dismissible: dismissible,
        );
      },
    );
  }

  @override
  State<StatefulWidget> createState() => _AnimeSourceProxyDialogState();
}

/*
* 番剧解析源快速切换弹窗-状态
* @author wuxubaiyang
* @Time 2023/8/30 17:29
*/
class _AnimeSourceProxyDialogState extends State<AnimeSourceProxyDialog> {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      scrollable: true,
      clipBehavior: Clip.hardEdge,
      content: SizedBox(),
      contentPadding: const EdgeInsets.symmetric(vertical: 14),
    );
  }
}
