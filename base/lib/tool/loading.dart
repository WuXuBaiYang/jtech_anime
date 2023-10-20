import 'package:flutter/material.dart';
import 'package:jtech_anime_base/common/notifier.dart';
import 'package:jtech_anime_base/manage/config.dart';
import 'package:jtech_anime_base/manage/router.dart';
import 'package:jtech_anime_base/widget/status_box.dart';
import 'log.dart';

/*
* 加载弹窗动画
* @author wuxubaiyang
* @Time 2023/7/19 16:43
*/
class Loading {
  // 加载弹窗dialog缓存
  static Future? _loadingDialog;

  // 展示加载弹窗
  static Future<T?>? show<T>({
    required Future<T?> loadFuture,
    bool? dismissible,
    BuildContext? context,
    ValueChangeNotifier<String>? title,
  }) async {
    context ??= router.navigator?.context;
    dismissible ??= globalConfig.loadingDismissible;
    if (context == null) return null;
    final navigator = Navigator.of(context);
    try {
      if (_loadingDialog != null) navigator.maybePop();
      _loadingDialog = showDialog<void>(
        context: context,
        barrierDismissible: dismissible,
        builder: (_) => _buildLoadingView(title),
      )..whenComplete(() => _loadingDialog = null);
      final start = DateTime.now();
      const duration = Duration(milliseconds: 300);
      final result = await loadFuture;
      // 如果传入的future加载时间过短（还不够弹窗动画时间），则进行等待
      final end = DateTime.now().subtract(duration);
      if (end.compareTo(start) < 0) await Future.delayed(duration);
      return result;
    } catch (e) {
      LogTool.e('弹窗请求异常：', error: e);
      rethrow;
    } finally {
      if (_loadingDialog != null) await navigator.maybePop();
    }
  }

  // 构建加载视图
  static Widget _buildLoadingView(ValueChangeNotifier<String>? title) {
    final theme = globalConfig.theme;
    return Center(
      child: SizedBox.square(
        dimension: theme.loadingSize,
        child: Card(
          color: Colors.white,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              StatusBox(
                status: StatusBoxStatus.loading,
                statusSize: theme.loadingSize * 0.6,
              ),
              if (title != null) ...[
                const SizedBox(height: 4),
                ValueListenableBuilder<String>(
                  valueListenable: title,
                  builder: (_, text, __) {
                    return Text(text,
                        style: const TextStyle(color: Colors.black26));
                  },
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
