import 'package:ffmpeg_helper/ffmpeg_helper.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import 'package:media_kit/media_kit.dart';
import 'base.dart';

/// 通用方法
export 'common/common.dart';
export 'common/controller.dart';
export 'common/logic.dart';
export 'common/manage.dart';
export 'common/model.dart';
export 'common/notifier.dart';

/// 管理方法
export 'manage/anime_parser/functions.dart';
export 'manage/anime_parser/parser.dart';
export 'manage/download/download.dart';
export 'manage/download/parser.dart';
export 'manage/cache.dart';
export 'manage/db.dart';
export 'manage/event.dart';
export 'manage/router.dart';
export 'manage/theme.dart';

/// 数据对象-database
export 'model/database/collect.dart';
export 'model/database/download_record.dart';
export 'model/database/filter_select.dart';
export 'model/database/play_record.dart';
export 'model/database/search_record.dart';
export 'model/database/source.dart';
export 'model/database/video_cache.dart';

/// 数据对象
export 'model/anime.dart';
export 'model/download.dart';
export 'model/download_group.dart';
export 'model/filter.dart';
export 'model/time_table.dart';

/// 工具
export 'tool/date.dart';
export 'tool/debounce.dart';
export 'tool/file.dart';
export 'tool/loading.dart';
export 'tool/log.dart';
export 'tool/snack.dart';
export 'tool/throttle.dart';
export 'tool/tool.dart';
export 'tool/volume.dart';
export 'tool/js_runtime.dart';

///自定义组件
export 'widget/player/controller.dart';
export 'widget/player/player.dart';
export 'widget/refresh/controller.dart';
export 'widget/refresh/refresh_view.dart';
export 'widget/future_builder.dart';
export 'widget/image.dart';
export 'widget/listenable_builders.dart';
export 'widget/material.dart';
export 'widget/message_dialog.dart';
export 'widget/source_logo.dart';
export 'widget/status_box.dart';
export 'widget/stream_view.dart';
export 'widget/tab.dart';
export 'widget/text_scroll.dart';
export 'widget/lottie.dart';
export 'widget/blur.dart';
export 'tool/qrcode.dart';

/// 第三方库
export 'package:font_awesome_flutter/font_awesome_flutter.dart';
export 'package:url_launcher/url_launcher.dart';
export 'package:collection/collection.dart';
export 'package:dio/dio.dart';

// 初始化核心方法
Future<void> ensureInitializedCore({
  Map<Brightness, ThemeData>? themeDataMap,
  bool noPictureMode = false,
}) async {
  // 设置是否为无图模式
  ImageView.noPictureMode = noPictureMode;
  // 设置初始化样式
  if (themeDataMap != null) theme.setup(themeDataMap);
  // 设置音量控制
  VolumeTool.setup();
  // 初始化视频播放器
  MediaKit.ensureInitialized();
  // 初始化ffmpeg
  await FFMpegHelper.instance.initialize();
  // 初始化各种manage
  await router.init(); // 路由服务
  await cache.init(); // 缓存服务
  await event.init(); // 事件服务
  await db.init(); // 数据库
  await download.init(); // 下载管理
  await animeParser.init(); // 番剧解析器
  // 监听解析源切换
  event.on<SourceChangeEvent>().listen((event) {
    // 暂停当前所有的下载任务
    download.stopAllTasks();
  });
}

// 数据库自动生成id
int dbAutoIncrementId = Isar.autoIncrement;
