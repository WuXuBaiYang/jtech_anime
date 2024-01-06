import 'package:flutter/material.dart';
import 'dart:async';

/*
* 加载弹窗动画
* @author wuxubaiyang
* @Time 2023/7/19 16:43
*/
class Loading {
  // 加载弹窗dialog缓存
  static Future? _loading;

  // 展示加载弹窗
  static Future<T?> show<T>(
    BuildContext context, {
    required Future<T?> loadFuture,
    bool dismissible = true,
    Stream<double>? inputStream,
  }) async {
    final buildFlag = Completer<bool>();
    final navigator = Navigator.of(context);
    try {
      if (_loading != null) navigator.maybePop();
      _loading = showDialog<void>(
          context: context,
          barrierDismissible: dismissible,
          builder: (_) {
            WidgetsBinding.instance
                .addPostFrameCallback((_) => buildFlag.complete(false));
            return _buildLoading(context, inputStream);
          })
        ..whenComplete(() => _loading = null);
      return await loadFuture;
    } catch (e) {
      rethrow;
    } finally {
      await buildFlag.future;
      if (_loading != null) await navigator.maybePop();
    }
  }

  // 构建加载视图
  static Widget _buildLoading(
      BuildContext context, Stream<double>? inputStream) {
    final textStyle = Theme.of(context).textTheme.bodySmall;
    final constraints = BoxConstraints.tight(const Size.square(80));
    return Center(
      child: Card(
        child: Container(
          constraints: constraints,
          padding: const EdgeInsets.all(8),
          child: StreamBuilder<double>(
            stream: inputStream,
            builder: (_, snap) {
              final progress = snap.data;
              return Stack(alignment: Alignment.center, children: [
                CircularProgressIndicator(value: progress),
                if (progress != null)
                  Text('${(progress * 100).toInt()}%',
                      style: textStyle?.copyWith(fontSize: 10)),
              ]);
            },
          ),
        ),
      ),
    );
  }
}

// 扩展future方法实现loading
extension LoadingFuture<T> on Future<T> {
  Future<T?> loading(BuildContext context,
          {bool dismissible = true, Stream<double>? inputStream}) =>
      Loading.show(context,
          loadFuture: this, dismissible: dismissible, inputStream: inputStream);
}
