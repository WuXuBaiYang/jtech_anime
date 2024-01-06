import 'dart:async';
import 'dart:convert';
import 'package:jtech_anime/common/manage.dart';
import 'package:shared_preferences/shared_preferences.dart';

/*
* 缓存管理
* @author wuxubaiyang
* @Time 2022/3/29 10:29
*/
class CacheManage extends BaseManage {
  // 时效字段后缀
  final String _expirationSuffix = 'expiration';

  static final CacheManage _instance = CacheManage._internal();

  factory CacheManage() => _instance;

  CacheManage._internal();

  // sp对象
  late SharedPreferences _sp;

  @override
  Future<void> initialize() async {
    _sp = await SharedPreferences.getInstance();
  }

  // 获取int类型
  int? getInt(String key) {
    if (!_check(key)) return null;
    return _sp.getInt(key);
  }

  // 获取bool类型
  bool? getBool(String key) {
    if (!_check(key)) return null;
    return _sp.getBool(key);
  }

  // 获取double类型
  double? getDouble(String key) {
    if (!_check(key)) return null;
    return _sp.getDouble(key);
  }

  // 获取String类型
  String? getString(String key) {
    if (!_check(key)) return null;
    return _sp.getString(key);
  }

  // 获取StringList类型
  List<String>? getStringList(String key) {
    if (!_check(key)) return null;
    return _sp.getStringList(key);
  }

  // 获取json类型
  T? getJson<T>(String key) {
    try {
      if (!_check(key)) return null;
      final json = _sp.getString(key);
      if (json != null) return jsonDecode(json) as T;
    } catch (_) {}
    return null;
  }

  // 设置int类型
  Future<bool> setInt(String key, int value, {Duration? expiration}) async {
    if (!await _setExpiration(key, expiration)) return false;
    return _sp.setInt(key, value);
  }

  // 设置double类型
  Future<bool> setDouble(String key, double value,
      {Duration? expiration}) async {
    if (!await _setExpiration(key, expiration)) return false;
    return _sp.setDouble(key, value);
  }

  // 设置bool类型
  Future<bool> setBool(String key, bool value, {Duration? expiration}) async {
    if (!await _setExpiration(key, expiration)) return false;
    return _sp.setBool(key, value);
  }

  // 设置string类型
  Future<bool> setString(String key, String value,
      {Duration? expiration}) async {
    if (!await _setExpiration(key, expiration)) return false;
    return _sp.setString(key, value);
  }

  // 设置List<string>类型
  Future<bool> setStringList(String key, List<String> value,
      {Duration? expiration}) async {
    if (!await _setExpiration(key, expiration)) return false;
    return _sp.setStringList(key, value);
  }

  // 设置Json类型(List/Map)泛型必须为基础类型
  Future<bool> setJson(String key, dynamic json, {Duration? expiration}) async {
    try {
      if (!await _setExpiration(key, expiration)) return false;
      return _sp.setString(key, jsonEncode(json));
    } catch (_) {
      await _removeExpiration(key);
    }
    return false;
  }

  // 移除字段
  Future<bool> remove(String key) async => _sp.remove(key);

  // 清空缓存的所有字段
  Future<bool> removeAll() async => _sp.clear();

  // 检查有效期
  bool _check(String key) {
    final expirationKey = _genExpirationKey(key);
    if (!_sp.containsKey(expirationKey)) return false;
    final expirationTime =
        DateTime.fromMillisecondsSinceEpoch(_sp.getInt(expirationKey) ?? 0);
    if (expirationTime.isBefore(DateTime.now())) {
      remove(expirationKey);
      remove(key);
      return false;
    }
    return true;
  }

  // 设置有效期
  Future<bool> _setExpiration(String key, [Duration? expiration]) async {
    if (null == expiration) return true;
    final inTime = DateTime.now().add(expiration).millisecondsSinceEpoch;
    return _sp.setInt(_genExpirationKey(key), inTime);
  }

  // 移除有效期key
  Future<bool> _removeExpiration(String key) async =>
      _sp.remove(_genExpirationKey(key));

  // 生成有效期存储字段
  String _genExpirationKey(String key) => '${key}_$_expirationSuffix';
}

// 单例调用
final cache = CacheManage();
