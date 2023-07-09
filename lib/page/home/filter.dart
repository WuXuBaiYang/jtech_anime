import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:jtech_anime/common/notifier.dart';
import 'package:jtech_anime/manage/parser.dart';
import 'package:jtech_anime/manage/theme.dart';
import 'package:jtech_anime/model/filter.dart';
import 'package:jtech_anime/tool/tool.dart';

/*
* 番剧过滤条件配置
* @author wuxubaiyang
* @Time 2023/7/7 15:27
*/
class AnimeFilterConfigFAB extends StatefulWidget {
  // 过滤条件配置
  final MapValueChangeNotifier<String, dynamic> filterConfig;

  // 过滤配置条件回调
  final VoidCallback complete;

  const AnimeFilterConfigFAB(
      {super.key, required this.filterConfig, required this.complete});

  @override
  State<StatefulWidget> createState() => _AnimeFilterConfigFABState();
}

class _AnimeFilterConfigFABState extends State<AnimeFilterConfigFAB> {
  // 动画时长
  final duration = const Duration(milliseconds: 200);

  // 状态切换
  CrossFadeState fadeState = CrossFadeState.showFirst;

  // 是否展示过滤配置表
  bool showFilterConfig = false;

  @override
  Widget build(BuildContext context) {
    final screenWidth = Tool.getScreenWidth(context);
    return Theme(
      data: _theme,
      child: AnimatedContainer(
        duration: duration,
        decoration: _decoration,
        curve: Curves.fastOutSlowIn,
        height: _showButton ? 65 : 350,
        width: _showButton ? 65 : screenWidth - 14 * 2,
        padding: const EdgeInsets.all(14).copyWith(bottom: 0),
        onEnd: () {
          if (!_showButton) setState(() => showFilterConfig = true);
        },
        child: AnimatedCrossFade(
          duration: duration,
          crossFadeState: fadeState,
          firstChild: _buildFAButton(),
          secondChild: _buildFilterConfig(),
        ),
      ),
    );
  }

  // 判断是否展示button
  bool get _showButton => fadeState == CrossFadeState.showFirst;

  // 获取容器装饰
  BoxDecoration get _decoration => BoxDecoration(
        borderRadius: BorderRadius.circular(_showButton ? 14 : 8),
        color: kPrimaryColor,
        boxShadow: const [
          BoxShadow(
            offset: Offset(2, 2),
            color: Colors.black26,
            spreadRadius: 1,
            blurRadius: 4,
          ),
        ],
      );

  // 样式管理
  ThemeData get _theme => ThemeData(
        colorScheme: const ColorScheme.dark(),
      );

  // 构建按钮
  Widget _buildFAButton() {
    return IconButton(
      icon: const Icon(FontAwesomeIcons.filter),
      onPressed: () => setState(() {
        fadeState = CrossFadeState.showSecond;
        showFilterConfig = false;
      }),
    );
  }

  // 构建过滤配置
  Widget _buildFilterConfig() {
    if (!showFilterConfig) return const SizedBox();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(child: _buildFilterConfigList()),
        Divider(color: Colors.white.withOpacity(0.2), thickness: 1, height: 1),
        Row(
          children: [
            Text('选择过滤条件',
                style: TextStyle(color: Colors.white.withOpacity(0.6))),
            const Spacer(),
            IconButton(
              icon: const Icon(FontAwesomeIcons.check),
              onPressed: () => setState(() {
                parserHandle.cacheFilterConfig(widget.filterConfig.value);
                fadeState = CrossFadeState.showFirst;
                showFilterConfig = false;
                widget.complete();
              }),
            ),
          ],
        ),
      ],
    );
  }

  // 构建过滤配置列表
  Widget _buildFilterConfigList() {
    const textStyle = TextStyle(color: Colors.white);
    return FutureBuilder<List<AnimeFilterModel>>(
      future: parserHandle.loadFilterList(),
      builder: (_, snap) {
        if (snap.hasData) {
          final dataList = snap.data!;
          return ValueListenableBuilder<Map<String, dynamic>>(
            valueListenable: widget.filterConfig,
            builder: (_, configMap, __) {
              return ListView.builder(
                itemBuilder: (_, i) {
                  final item = dataList[i];
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 12),
                        child: SizedBox(
                            width: 50,
                            child: Text(
                              item.name,
                              textAlign: TextAlign.right,
                              style: textStyle,
                            )),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: _buildFilterConfigListTags(item, configMap),
                      ),
                    ],
                  );
                },
                itemCount: dataList.length,
              );
            },
          );
        }
        return const Center(child: CircularProgressIndicator());
      },
    );
  }

  // 构建过滤配置列表标签集合
  Widget _buildFilterConfigListTags(
      AnimeFilterModel item, Map<String, dynamic> configMap) {
    return Wrap(
      spacing: 8,
      children: List.generate(item.items.length, (i) {
        final it = item.items[i];
        final selects = configMap[item.key];
        if (selects?.contains(it.value) ?? false) {
          return ElevatedButton(
            child: Text(it.name),
            onPressed: () => setState(() {
              final result = (selects ?? [])..remove(it.value);
              widget.filterConfig.putValue(item.key, result);
            }),
          );
        }
        return OutlinedButton(
          child: Text(it.name),
          onPressed: () => setState(() {
            final result = (selects ?? []);
            if (item.maxSelected == 1) {
              widget.filterConfig.putValue(item.key, [it.value]);
            } else if (result.length < item.maxSelected) {
              widget.filterConfig.putValue(item.key, result..add(it.value));
            }
          }),
        );
      }),
    );
  }
}
