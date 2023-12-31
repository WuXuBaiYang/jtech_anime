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
export 'manage/config.dart';
export 'manage/proxy.dart';

/// 数据对象-database
export 'model/database/collect.dart';
export 'model/database/download_record.dart';
export 'model/database/filter_select.dart';
export 'model/database/play_record.dart';
export 'model/database/search_record.dart';
export 'model/database/source.dart';
export 'model/database/video_cache.dart';
export 'model/database/proxy.dart';

/// 数据对象
export 'model/anime.dart';
export 'model/download.dart';
export 'model/download_group.dart';
export 'model/filter.dart';
export 'model/time_table.dart';
export 'model/version.dart';
export 'model/config.dart';

/// 工具
export 'tool/date.dart';
export 'tool/debounce.dart';
export 'tool/file.dart';
export 'tool/loading.dart';
export 'tool/log.dart';
export 'tool/snack.dart';
export 'tool/throttle.dart';
export 'tool/tool.dart';
export 'tool/js_runtime.dart';
export 'tool/qrcode.dart';
export 'tool/version.dart';
export 'tool/screen_type.dart';

///自定义组件
export 'widget/player/controller.dart';
export 'widget/player/player.dart';
export 'widget/player/controls/controls_desktop.dart';
export 'widget/player/controls/controls_mobile.dart';
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
export 'widget/lottie.dart';
export 'widget/blur.dart';
export 'widget/download/list.dart';
export 'widget/timer.dart';
export 'widget/vertical_progress.dart';
export 'widget/source_import.dart';
export 'widget/mask_view.dart';
export 'widget/proxy/proxy.dart';
export 'widget/anime_list/anime_list.dart';
export 'widget/keep_alive.dart';
export 'widget/focus/tile.dart';
export 'widget/focus/view.dart';

/// 第三方库
export 'package:font_awesome_flutter/font_awesome_flutter.dart';
export 'package:url_launcher/url_launcher.dart';
export 'package:collection/collection.dart';
export 'package:dio/dio.dart';
export 'package:path/path.dart' show join, basename;
export 'package:path_provider/path_provider.dart';

// 初始化核心方法
Future<void> ensureInitializedCore({
  required JTechConfig config,
  required JTechThemeData themeData,
  required Map<String, ThemeData> systemTheme,
}) async {
  // 初始化视频播放器
  MediaKit.ensureInitialized();
  // 部署全局配置
  rootConfig.setup(config, themeData);
  // 部署系统样式
  theme.setup(systemTheme);
  // 初始化各种manage
  await rootConfig.init(); // 全局配置
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
  // 记录版本号，如果版本号发生变化则更新默认配置文件
  const versionKey = 'version_update_key';
  final buildNumber = await Tool.buildNumber;
  if (cache.getString(versionKey) != buildNumber) {
    cache.setString(versionKey, buildNumber);
    animeParser.updateDefaultSource();
  }
}

// 数据库自动生成id
const int dbAutoIncrementId = Isar.autoIncrement;
