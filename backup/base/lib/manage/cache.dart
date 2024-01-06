import 'dart:async';
import 'dart:convert';
import 'package:jtech_anime_base/common/manage.dart';
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

  // sp存储方法
  SharedPreferences? _sp;

  @override
  Future<void> init() async {
    _sp ??= await SharedPreferences.getInstance();
  }

  // 获取int类型
  int? getInt(String key) {
    if (_checkExpiration(key)) return _sp?.getInt(key);
    return null;
  }

  // 获取bool类型
  bool? getBool(String key) {
    if (_checkExpiration(key)) return _sp?.getBool(key);
    return null;
  }

  // 获取double类型
  double? getDouble(String key) {
    if (_checkExpiration(key)) return _sp?.getDouble(key);
    return null;
  }

  // 获取String类型
  String? getString(String key) {
    if (_checkExpiration(key)) return _sp?.getString(key);
    return null;
  }

  // 获取StringList类型
  List<String>? getStringList(String key) {
    if (_checkExpiration(key)) return _sp?.getStringList(key);
    return null;
  }

  // 获取json类型
  dynamic getJson(String key) {
    if (_checkExpiration(key)) {
      final value = _sp?.getString(key);
      if (value != null) return jsonDecode(value);
    }
    return null;
  }

  // 设置int类型
  Future<bool> setInt(
    String key,
    int value, {
    Duration? expiration,
  }) async {
    if (!await _setupExpiration(key, expiration: expiration)) return false;
    return (await _sp?.setInt(key, value)) ?? false;
  }

  // 设置double类型
  Future<bool> setDouble(
    String key,
    double value, {
    Duration? expiration,
  }) async {
    if (!await _setupExpiration(key, expiration: expiration)) return false;
    return (await _sp?.setDouble(key, value)) ?? false;
  }

  // 设置bool类型
  Future<bool> setBool(
    String key,
    bool value, {
    Duration? expiration,
  }) async {
    if (!await _setupExpiration(key, expiration: expiration)) return false;
    return (await _sp?.setBool(key, value)) ?? false;
  }

  // 设置string类型
  Future<bool> setString(
    String key,
    String value, {
    Duration? expiration,
  }) async {
    if (!await _setupExpiration(key, expiration: expiration)) return false;
    return (await _sp?.setString(key, value)) ?? false;
  }

  // 设置List<string>类型
  Future<bool> setStringList(
    String key,
    List<String> value, {
    Duration? expiration,
  }) async {
    if (!await _setupExpiration(key, expiration: expiration)) return false;
    return (await _sp?.setStringList(key, value)) ?? false;
  }

  // 设置JsonMap类型
  Future<bool> setJsonMap<K, V>(
    String key,
    Map<K, V> value, {
    Duration? expiration,
  }) async {
    if (!await _setupExpiration(key, expiration: expiration)) return false;
    return (await _sp?.setString(key, jsonEncode(value))) ?? false;
  }

  // 设置JsonList类型
  Future<bool> setJsonList<V>(
    String key,
    List<V> value, {
    Duration? expiration,
  }) async {
    if (!await _setupExpiration(key, expiration: expiration)) return false;
    return (await _sp?.setString(key, jsonEncode(value))) ?? false;
  }

  // 移除字段
  Future<bool> remove(String key) async {
    return (await _sp?.remove(key)) ?? false;
  }

  // 清空缓存的所有字段
  Future<bool> removeAll() async {
    return (await _sp?.clear()) ?? false;
  }

  // 检查有效期
  bool _checkExpiration(String key) {
    final expirationKey = _getExpirationKey(key);
    if (_sp?.containsKey(expirationKey) ?? false) {
      final expirationTime =
          DateTime.fromMillisecondsSinceEpoch(_sp?.getInt(expirationKey) ?? 0);
      if (expirationTime.isBefore(DateTime.now())) {
        remove(expirationKey);
        remove(key);
        return false;
      }
    }
    return true;
  }

  // 设置有效期
  Future<bool> _setupExpiration(String key, {Duration? expiration}) async {
    if (null == expiration) return true;
    final expirationKey = _getExpirationKey(key);
    final inTime = DateTime.now().add(expiration).millisecondsSinceEpoch;
    return (await _sp?.setInt(expirationKey, inTime)) ?? false;
  }

  // 获取有效期的存储字段
  String _getExpirationKey(String key) => '${key}_$_expirationSuffix';
}

// 单例调用
final cache = CacheManage();
