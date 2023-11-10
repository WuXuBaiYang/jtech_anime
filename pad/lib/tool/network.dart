import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:jtech_anime_base/base.dart';

/*
* 网络状态
* @author wuxubaiyang
* @Time 2023/9/6 13:21
*/
class Network {
  // 缓存key
  static const String checkNetworkStatusKey = 'check_network_status';

  // 检查当前网络是否处于流量状态
  static Future<bool> checkNetworkInMobile() async {
    final result = await Connectivity().checkConnectivity();
    return result == ConnectivityResult.mobile;
  }

  // 检查网络状态(检查通过)
  static Future<bool> checkNetwork(BuildContext context,
      [ValueChangeNotifier<bool>? checkNetwork]) async {
    if (!(checkNetwork?.value ?? false)) return true;
    return checkNetworkInMobile().then((v) {
      if (!v) return true;
      return showNetworkStatusDialog(context, checkNetwork);
    });
  }

  // 展示网络状态提示dialog
  static Future<bool> showNetworkStatusDialog(BuildContext context,
      [ValueChangeNotifier<bool>? checkNetwork]) {
    return MessageDialog.show<bool>(
      context,
      title: const Text('流量提醒'),
      actionsAlignment: MainAxisAlignment.spaceBetween,
      content: const Text('当前正在使用手机流量下载，是否继续？'),
      actionLeft: TextButton(
        child: const Text('不再提醒'),
        onPressed: () {
          cache.setBool(checkNetworkStatusKey, false);
          checkNetwork?.setValue(false);
          router.pop(true);
        },
      ),
      actionMiddle: TextButton(
        child: const Text('取消'),
        onPressed: () => router.pop(false),
      ),
      actionRight: TextButton(
        child: const Text('继续下载'),
        onPressed: () {
          checkNetwork?.setValue(false);
          router.pop(true);
        },
      ),
    ).then((v) => v ?? false);
  }
}
