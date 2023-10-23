import 'dart:io';

import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:jtech_anime_base/common/manage.dart';
import 'package:jtech_anime_base/manage/cache.dart';
import 'package:jtech_anime_base/manage/db.dart';
import 'package:jtech_anime_base/manage/event.dart';
import 'package:jtech_anime_base/model/database/proxy.dart';

/*
* 代理管理器
* @author wuxubaiyang
* @Time 2022/3/17 14:14
*/
class ProxyManage extends BaseManage {
  // 当前代理缓存key
  static const String _currentProxyKey = 'current_proxy';

  static final ProxyManage _instance = ProxyManage._internal();

  factory ProxyManage() => _instance;

  ProxyManage._internal();

  // 缓存当前代理
  ProxyRecord? _currentProxy;

  // 获取当前代理
  ProxyRecord? get currentProxy => _currentProxy ??= _loadCurrentProxy();

  // 从json中加载当前代理记录
  ProxyRecord? _loadCurrentProxy() {
    final json = cache.getJson(_currentProxyKey);
    if (json == null) return null;
    return ProxyRecord.from(json);
  }

  // 设置当前代理
  Future<bool> setCurrentProxy(ProxyRecord? record) async {
    _currentProxy = record;
    final result = record != null
        ? await cache.setJsonMap(_currentProxyKey, record.toJson())
        : await cache.remove(_currentProxyKey);
    event.send(ProxyChangeEvent(record));
    return result;
  }

  // 创建包含代理的httpAdapter
  HttpClientAdapter createProxyHttpAdapter() {
    final proxy = currentProxy?.proxy;
    if (proxy == null) return IOHttpClientAdapter();
    return IOHttpClientAdapter()
      ..createHttpClient = () {
        final client = HttpClient();
        client.badCertificateCallback = (_, __, ___) => true;
        client.findProxy = (_) => proxy;
        return client;
      };
  }

  // 获取代理列表
  Future<List<ProxyRecord>> getProxyList() => db.getProxyList();

  // 添加/更新代理
  Future<ProxyRecord?> updateProxy(ProxyRecord record) async {
    final result = await db.updateProxy(record);
    if (result != null && currentProxy?.proxy == result.proxy) {
      await setCurrentProxy(result);
    }
    return result;
  }

  // 删除代理
  Future<bool> deleteProxy(ProxyRecord record) async {
    final result = await db.removeProxy(record.id);
    if (result && currentProxy?.proxy == record.proxy) {
      return setCurrentProxy(null);
    }
    return result;
  }
}

// 单例调用
final proxy = ProxyManage();

/*
* 代理变化事件
* @author wuxubaiyang
* @Time 2022/3/17 14:15
*/
class ProxyChangeEvent extends EventModel {
  final ProxyRecord? record;

  ProxyChangeEvent(this.record);
}
