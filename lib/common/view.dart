import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

/*
* provider组件视图基类
* @author wuxubaiyang
* @Time 2023/11/20 15:30
*/
abstract class ProviderView extends StatelessWidget {
  const ProviderView({super.key});

  List<SingleChildWidget> loadProviders(BuildContext context) => [];

  @override
  Widget build(BuildContext context) {
    final providers = loadProviders(context);
    if (providers.isEmpty) return buildWidget(context);
    return MultiProvider(
      providers: providers,
      builder: (context, _) {
        return buildWidget(context);
      },
    );
  }

  // 构建组件内容
  Widget buildWidget(BuildContext context);
}
