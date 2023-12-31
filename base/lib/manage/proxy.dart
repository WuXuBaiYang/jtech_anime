import 'dart:io';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:jtech_anime_base/common/manage.dart';
import 'package:jtech_anime_base/manage/cache.dart';
import 'package:jtech_anime_base/manage/db.dart';
import 'package:jtech_anime_base/manage/event.dart';
import 'package:jtech_anime_base/model/database/proxy.dart';
import 'package:jtech_anime_base/tool/log.dart';

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

  // 判断当前是否存在代理
  bool get hasProxy => currentProxy != null;

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
        client.findProxy = (_) => 'PROXY $proxy';
        return client;
      };
  }

  // 验证当前选中的代理是否有效
  Future<bool> checkProxy() async {
    if (!hasProxy) return false;
    try {
      // 通过访问百度判断代理是否可用
      final dio = Dio(
        BaseOptions(
          maxRedirects: 0,
          followRedirects: false,
          baseUrl: 'https://www.google.com',
          responseType: ResponseType.plain,
          validateStatus: (status) => true,
          headers: {'User-Agent': 'Mozilla/5.0'},
          connectTimeout: const Duration(seconds: 2),
          receiveTimeout: const Duration(seconds: 2),
        ),
      );
      dio.httpClientAdapter = createProxyHttpAdapter();
      final resp = await dio.get('/');
      return resp.statusCode == 200;
    } catch (e) {
      LogTool.w('代理不可用', error: e);
    }
    return false;
  }

  // 获取代理列表
  Future<List<ProxyRecord>> getProxyList() => db.getProxyList();

  // 添加/更新代理
  Future<ProxyRecord?> updateProxy(ProxyRecord record) async {
    final result = await db.updateProxy(record);
    if (result != null) {
      // 如果设置的是当前代理或代理列表为空则设置
      if (currentProxy?.proxy == result.proxy ||
          (await getProxyList()).length == 1) {
        await setCurrentProxy(result);
      }
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
