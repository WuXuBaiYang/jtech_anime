import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart' as crypto;
import 'package:flutter/material.dart';
import 'package:jtech_anime/tool/log.dart';
import 'package:jtech_anime/widget/status_box.dart';
import 'package:package_info_plus/package_info_plus.dart';

import 'date.dart';

/*
* 工具方法
* @author wuxubaiyang
* @Time 2022/9/8 15:09
*/
class Tool {
  // 生成id
  static String genID({int? seed}) {
    final time = DateTime.now().millisecondsSinceEpoch;
    return md5('${time}_${Random(seed ?? time).nextDouble()}');
  }

  // 生成时间戳签名
  static String genDateSign() => DateTime.now().format(DatePattern.dateSign);

  // 计算md5
  static String md5(String value) =>
      crypto.md5.convert(utf8.encode(value)).toString();

  // 获取屏幕宽度
  static double getScreenWidth(BuildContext context) =>
      MediaQuery.of(context).size.width;

  // 获取屏幕高度
  static double getScreenHeight(BuildContext context) =>
      MediaQuery.of(context).size.height;

  // 获取状态栏高度
  static double getStatusBarHeight(BuildContext context) =>
      MediaQuery.of(context).padding.top;

  // 获取应用名
  static Future<String> get appName async {
    final packageInfo = await PackageInfo.fromPlatform();
    return packageInfo.appName;
  }

  // 获取应用包名
  static Future<String> get packageName async {
    final packageInfo = await PackageInfo.fromPlatform();
    return packageInfo.packageName;
  }

  // 获取版本号
  static Future<String> get buildNumber async {
    final packageInfo = await PackageInfo.fromPlatform();
    return packageInfo.buildNumber;
  }

  // 获取版本名
  static Future<String> get version async {
    final packageInfo = await PackageInfo.fromPlatform();
    return packageInfo.version;
  }

  // 手机号校验正则
  static final _verifyPhoneRegExp =
      RegExp(r'^1(3\d|4[5-9]|5[0-35-9]|6[567]|7[0-8]|8\d|9[0-35-9])\d{8}$');

  // 校验手机号
  static bool verifyPhone(String phone) {
    return _verifyPhoneRegExp.hasMatch(phone);
  }

  // 加载弹窗dialog缓存
  static Future? _loadingDialog;

  // 展示加载弹窗
  static Future<T?> showLoading<T>(
    BuildContext context, {
    required Future<T?> loadFuture,
    bool dismissible = true,
  }) async {
    final navigator = Navigator.of(context);
    try {
      if (_loadingDialog != null) navigator.maybePop();
      _loadingDialog = showDialog<void>(
        context: context,
        barrierDismissible: dismissible,
        builder: (_) => const Center(
          child: Card(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  StatusBox(
                    status: StatusBoxStatus.loading,
                    animSize: 28,
                  ),
                  SizedBox(height: 8),
                  Text('加载中~', style: TextStyle(color: Colors.black26)),
                ],
              ),
            ),
          ),
        ),
      )..whenComplete(() => _loadingDialog = null);
      await Future.delayed(const Duration(milliseconds: 150));
      return await loadFuture;
    } catch (e) {
      LogTool.e('弹窗请求异常：', error: e);
      rethrow;
    } finally {
      if (_loadingDialog != null) await navigator.maybePop();
    }
  }
}

/*
* 自定义异常
* @author wuxubaiyang
* @Time 2023/5/29 13:45
*/
class CustomException implements Exception {
  final List<String> message;

  CustomException(this.message);

  @override
  String toString() => message.join('\n');
}
