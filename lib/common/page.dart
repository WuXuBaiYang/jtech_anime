import 'package:flutter/material.dart';
import 'view.dart';

/*
* 页面基类
* @author wuxubaiyang
* @Time 2023/11/20 15:30
*/
abstract class ProviderPage extends ProviderView {
  const ProviderPage({super.key});

  @override
  Widget buildWidget(BuildContext context) {
    return Material(
      child: buildPage(context),
    );
  }

  // 构建页面内容
  Widget buildPage(BuildContext context);
}
