import 'package:flutter/material.dart';
import 'package:jtech_anime/common/notifier.dart';
import 'package:jtech_anime/manage/router.dart';
import 'package:jtech_anime/widget/status_box.dart';

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
    ValueChangeNotifier<String>? title,
    bool dismissible = false,
    BuildContext? context,
  }) async {
    context ??= router.navigator?.context;
    if (context == null) return null;
    final navigator = Navigator.of(context);
    try {
      if (_loadingDialog != null) navigator.maybePop();
      _loadingDialog = showDialog<void>(
        context: context,
        builder: (_) => _buildLoadingView(title ?? ValueChangeNotifier('加载中~')),
        barrierDismissible: dismissible,
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
  static Widget _buildLoadingView(ValueChangeNotifier<String> title) {
    return Center(
      child: Card(
        elevation: 1,
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const StatusBox(
                status: StatusBoxStatus.loading,
                animSize: 28,
              ),
              const SizedBox(height: 8),
              ValueListenableBuilder<String>(
                valueListenable: title,
                builder: (_, text, __) {
                  return Text(text,
                      style: const TextStyle(color: Colors.black26));
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
