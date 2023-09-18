import 'package:jtech_anime_base/base.dart';

/*
* 番剧收藏事件
* @author wuxubaiyang
* @Time 2023/9/18 9:37
*/
class CollectEvent extends EventModel {
  final Collect? collect;

  CollectEvent({this.collect});
}

/*
* 播放记录事件
* @author wuxubaiyang
* @Time 2023/9/18 9:41
*/
class PlayRecordEvent extends EventModel {
  final PlayRecord? playRecord;

  PlayRecordEvent({this.playRecord});
}
