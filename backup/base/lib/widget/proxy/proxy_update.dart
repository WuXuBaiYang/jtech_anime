import 'package:flutter/material.dart';
import 'package:jtech_anime_base/model/database/proxy.dart';
import 'package:jtech_anime_base/widget/proxy/proxy_update_desktop.dart';
import 'package:jtech_anime_base/widget/proxy/proxy_update_mobile.dart';
import 'package:jtech_anime_base/widget/screen_builder.dart';

/*
* 代理配置编辑/新增
* @author wuxubaiyang
* @Time 2023/11/14 10:29
*/
abstract class AnimeSourceProxyUpdateSheet extends StatefulWidget {
  // 代理记录
  final ProxyRecord? record;

  const AnimeSourceProxyUpdateSheet({super.key, this.record});

  static Future<ProxyRecord?> show(BuildContext context,
      {ProxyRecord? record}) {
    return showModalBottomSheet<ProxyRecord>(
      context: context,
      isScrollControlled: true,
      builder: (_) => ScreenBuilder(
        builder: (_) => DesktopAnimeSourceProxyUpdateSheet(record: record),
        mobile: (_) => MobileAnimeSourceProxyUpdateSheet(record: record),
      ),
    );
  }
}
