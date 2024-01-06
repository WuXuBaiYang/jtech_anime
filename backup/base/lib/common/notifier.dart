import 'package:flutter/foundation.dart';

/*
* 数据变化监听
* @author wuxubaiyang
* @Time 2022/3/31 15:27
*/
class ValueChangeNotifier<V> extends ChangeNotifier
    implements ValueListenable<V> {
  // 参数数据
  V _value;

  ValueChangeNotifier(this._value);

  @override
  V get value => _value;

  // 赋值并刷新
  void setValue(V newValue) {
    if (newValue == _value) return;
    _value = newValue;
    notifyListeners();
  }

  @override
  String toString() => '${describeIdentity(this)}($_value)';
}

/*
* 集合数据变化监听
* @author wuxubaiyang
* @Time 2022/3/31 15:27
*/
class ListValueChangeNotifier<V> extends ValueChangeNotifier<List<V>> {
  ListValueChangeNotifier(super.value);

  ListValueChangeNotifier.empty() : this([]);

  // 获取数据长度
  int get length => value.length;

  // 判断是否为空
  bool get isEmpty => value.isEmpty;

  // 判断是否非空
  bool get isNotEmpty => value.isNotEmpty;

  // 获取第一个元素
  V get first => value.first;

  // 获取最后一个元素
  V get last => value.last;

  // 清除数据
  void clear() {
    value.clear();
    notifyListeners();
  }

  // 判断是否存在该元素
  bool contains(V item) => value.contains(item);

  // 获取子项
  V? getItem(int index) {
    if (index >= 0 && value.length > index) {
      return value[index];
    }
    return null;
  }

  // 添加数据
  void addValue(V newValue, {bool notify = true}) {
    value.add(newValue);
    if (notify) notifyListeners();
  }

  // 添加数据集合
  void addValues(List<V> newValue, {bool notify = true}) {
    value.addAll(newValue);
    if (notify) notifyListeners();
  }

  // 插入数据
  void insertValues(int index, List<V> newValue, {bool notify = true}) {
    value.insertAll(index, newValue);
    if (notify) notifyListeners();
  }

  // 更新/添加数据
  void putValue(int index, V item, {bool notify = true}) {
    value[index] = item;
    if (notify) notifyListeners();
  }

  // 移除数据
  bool removeValue(V item, {bool notify = true}) {
    final result = value.remove(item);
    if (notify) notifyListeners();
    return result;
  }

  // 移除下标数据
  V? removeValueAt(int index, {bool notify = true}) {
    final result = value.removeAt(index);
    if (notify) notifyListeners();
    return result;
  }

  // 范围移除
  void removeRange(int start, int end, {bool notify = true}) {
    value.removeRange(start, end);
    if (notify) notifyListeners();
  }

  // 条件移除
  void removeWhere(bool Function(V element) test, {bool notify = true}) {
    value.removeWhere(test);
    if (notify) notifyListeners();
  }

  @override
  String toString() => '${describeIdentity(this)}($value)';

  @override
  void dispose() {
    value.clear();
    super.dispose();
  }
}

/*
* 表数据变化监听
* @author wuxubaiyang
* @Time 2022/3/31 15:27
*/
class MapValueChangeNotifier<K, V> extends ValueChangeNotifier<Map<K, V>> {
  MapValueChangeNotifier(super.value);

  MapValueChangeNotifier.empty() : this({});

  // 获取数据长度
  int get length => value.length;

  // 判断是否为空
  bool get isEmpty => value.isEmpty;

  // 判断是否非空
  bool get isNotEmpty => value.isNotEmpty;

  // 获取key集合
  Iterable<K> get keys => value.keys;

  // 获取value集合
  Iterable<V> get values => value.values;

  // 判断key是否存在
  bool contains(K k) => value.containsKey(k);

  // 获取子项
  V? getItem(K k) {
    if (contains(k)) return value[k];
    return null;
  }

  // 清除数据
  void clear() {
    value.clear();
    notifyListeners();
  }

  // 添加数据
  void putValue(K k, V v, {bool notify = true}) {
    value.addAll({k: v});
    if (notify) notifyListeners();
  }

  // 添加数据如果不存在
  void putIfAbsent(K key, V v, {bool notify = true}) {
    final hasValue = value.containsValue(v);
    value.putIfAbsent(key, () => v);
    if (!hasValue && notify) notifyListeners();
  }

  // 移除数据
  V? removeValue(K key, {bool notify = true}) {
    final result = value.remove(key);
    if (notify) notifyListeners();
    return result;
  }

  // 依据条件移除数据
  void removeWhere(bool Function(K key, V value) test, {bool notify = true}) {
    value.removeWhere(test);
    if (notify) notifyListeners();
  }

  @override
  String toString() => '${describeIdentity(this)}($value)';

  @override
  void dispose() {
    value.clear();
    super.dispose();
  }
}
