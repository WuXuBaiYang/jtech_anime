import 'package:crypto/crypto.dart' as crypto;
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'date.dart';
import 'log.dart';

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

  // 获取屏幕宽度
  static double getScreenWidth(BuildContext context) =>
      MediaQuery.of(context).size.width;

  // 获取屏幕高度
  static double getScreenHeight(BuildContext context) =>
      MediaQuery.of(context).size.height;

  // 获取状态栏高度
  static double getStatusBarHeight(BuildContext context) =>
      MediaQuery.of(context).padding.top;

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

  // 解析字符串格式的色值
  static Color parseColor(String colorString,
      [Color defaultColor = Colors.white]) {
    try {
      if (colorString.isEmpty) return defaultColor;
      // 解析16进制格式的色值 0xffffff
      if (colorString.contains(RegExp(r'#|0x'))) {
        String hexColor = colorString.replaceAll(RegExp(r'#|0x'), '');
        if (hexColor.length == 6) hexColor = 'ff$hexColor';
        return Color(int.parse(hexColor, radix: 16));
      }
      // 解析rgb格式的色值 rgb(0,0,0)
      if (colorString.toLowerCase().contains(RegExp(r'rgb(.*)'))) {
        String valuesString = colorString.substring(4, colorString.length - 1);
        List<String> values = valuesString.split(',');
        if (values.length == 3) {
          int red = int.parse(values[0].trim());
          int green = int.parse(values[1].trim());
          int blue = int.parse(values[2].trim());
          return Color.fromARGB(255, red, green, blue);
        }
        return defaultColor;
      }
    } catch (e) {
      LogTool.e('色值格式化失败', error: e);
    }
    return defaultColor;
  }

  // 获取零点时间戳
  static DateTime getDayZero({int dayOffset = 0}) {
    if (dayOffset < 0) return DateTime.now();
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day)
        .add(Duration(days: dayOffset));
  }

  // 获取距离零点的duration
  static Duration toDayZeroDuration({int dayOffset = 1}) {
    if (dayOffset < 1) return Duration.zero;
    return getDayZero(dayOffset: dayOffset).difference(DateTime.now());
  }
}

// 计算md5
String md5(String value) => crypto.md5.convert(utf8.encode(value)).toString();

// 区间计算
T range<T extends num>(T value, T begin, T end) => max(begin, min(end, value));

// 扩展集合
extension ListExtension<T> on List<T> {
  // 交换集合中两个位置的元素
  List<T> swap(int oldIndex, int newIndex) {
    if (oldIndex == newIndex) return this;
    newIndex = newIndex > oldIndex ? newIndex - 1 : newIndex;
    final T item = removeAt(oldIndex);
    insert(newIndex, item);
    return this;
  }

  // 对集合进行分组
  Map<S, List<T>> groupBy<S>(S Function(T) key) {
    var map = <S, List<T>>{};
    for (var element in this) {
      (map[key(element)] ??= []).add(element);
    }
    return map;
  }
}
