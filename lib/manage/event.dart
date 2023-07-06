import 'dart:async';
import 'package:jtech_anime/common/manage.dart';
import 'package:jtech_anime/common/model.dart';

/*
* 消息总线管理
* @author wuxubaiyang
* @Time 2022/3/17 14:14
*/
class EventManage extends BaseManage {
  static final EventManage _instance = EventManage._internal();

  factory EventManage() => _instance;

  // 流控制器
  final StreamController _streamController;

  EventManage._internal()
      : _streamController = StreamController.broadcast(sync: false);

  // 注册事件
  Stream<T> on<T extends EventModel>() {
    if (T == EventModel) {
      return _streamController.stream as Stream<T>;
    } else {
      return _streamController.stream.where((event) => event is T).cast<T>();
    }
  }

  // 发送事件
  void send<T extends EventModel>(T event) => _streamController.add(event);

  // 销毁消息总线
  void destroy() => _streamController.close();
}

// 单例调用
final event = EventManage();

/*
* 消息总线对象基类
* @author wuxubaiyang
* @Time 2022/3/17 14:15
*/
abstract class EventModel extends BaseModel {
  const EventModel();
}
