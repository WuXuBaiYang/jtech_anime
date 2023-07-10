import 'package:flutter/material.dart';
import 'package:jtech_anime/common/common.dart';
import 'package:lottie/lottie.dart';
import 'cache_future_builder.dart';

/*
* 状态盒
* @author wuxubaiyang
* @Time 2023/3/16 17:35
*/
class StatusBox extends StatelessWidget {
  // 标题
  final Widget? title;

  // 副标题
  final Widget? subTitle;

  // 状态
  final StatusBoxStatus status;

  // 状态图大小
  final double animSize;

  const StatusBox({
    super.key,
    required this.status,
    this.title,
    this.subTitle,
    this.animSize = 55,
  });

  @override
  Widget build(BuildContext context) {
    final ratio = MediaQuery.of(context).devicePixelRatio;
    return DefaultTextStyle(
      style: TextStyle(color: Colors.grey.shade400, fontSize: 14),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Lottie.asset(
            status.assetsFile,
            width: animSize * ratio,
          ),
          const SizedBox(height: 24),
          title ?? const SizedBox(),
          const SizedBox(height: 6),
          DefaultTextStyle(
            style: TextStyle(fontSize: 12, color: Colors.grey.shade400),
            child: subTitle ?? const SizedBox(),
          ),
        ],
      ),
    );
  }
}

/*
* 状态盒子状态枚举
* @author wuxubaiyang
* @Time 2023/3/16 17:40
*/
enum StatusBoxStatus { loading, empty, error }

/*
* 状态盒子状态枚举扩展
* @author wuxubaiyang
* @Time 2023/3/16 17:41
*/
extension StatusBoxStatusExtension on StatusBoxStatus {
  // 获取当前状态的素材
  String get assetsFile => {
        StatusBoxStatus.loading: Common.statusLoadingAsset,
        StatusBoxStatus.empty: Common.statusEmptyAsset,
        StatusBoxStatus.error: Common.statusErrorAsset,
      }[this]!;
}

// 状态盒子构造器
typedef StatusBoxBuilder<T> = Widget? Function(T value);

/*
* 状态盒子与futureBuilder的融合组件
* 当构造器返回null的时候，则展示空数据状态
* @author wuxubaiyang
* @Time 2023/3/16 17:45
*/
class StatusBoxCacheFuture<T> extends StatelessWidget {
  // 初始化参数
  final T? initialData;

  // future
  final Future<T> Function() future;

  // 构造器
  final StatusBoxBuilder<T> builder;

  // 标题
  final Widget? title;

  // 副标题
  final Widget? subTitle;

  // 状态图大小
  final double animSize;

  // 控制器
  final CacheFutureBuilderController<T> controller;

  StatusBoxCacheFuture({
    super.key,
    required this.future,
    required this.builder,
    this.initialData,
    CacheFutureBuilderController<T>? controller,
    this.title,
    this.subTitle,
    this.animSize = 55,
  }) : controller = controller ?? CacheFutureBuilderController<T>();

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: CacheFutureBuilder<T>(
        initialData: initialData,
        controller: controller,
        future: future,
        builder: (_, snap) {
          Widget? child;
          var status = StatusBoxStatus.loading;
          if (snap.hasData) {
            child = builder(snap.data as T);
            if (child == null) status = StatusBoxStatus.empty;
          }
          if (snap.hasError) status = StatusBoxStatus.error;
          return child ?? _buildStatus(status);
        },
      ),
    );
  }

  // 构建状态
  Widget _buildStatus(StatusBoxStatus status) {
    return Center(
      child: StatusBox(
        status: status,
        title: title ??
            {
              StatusBoxStatus.empty: const Text('这里很荒芜 什么都没有'),
              StatusBoxStatus.error: OutlinedButton(
                onPressed: () => controller.refreshValue(),
                child: Text(
                  '重试一下',
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade400),
                ),
              ),
            }[status],
        subTitle: subTitle,
        animSize: animSize,
      ),
    );
  }
}
