import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_js/flutter_js.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:jtech_anime/common/notifier.dart';
import 'package:jtech_anime/manage/anime_parser/funtions.dart';
import 'package:jtech_anime/model/database/source.dart';
import 'package:jtech_anime/tool/date.dart';
import 'package:jtech_anime/tool/log.dart';
import 'package:jtech_anime/tool/snack.dart';
import 'package:jtech_anime/widget/listenable_builders.dart';
import 'package:jtech_anime/widget/qr_code/sheet.dart';
import 'package:jtech_anime/widget/source/logo.dart';
import 'package:url_launcher/url_launcher.dart';

/*
* 番剧解析源导入sheet
* @author wuxubaiyang
* @Time 2023/8/31 17:09
*/
class AnimeSourceImportSheet extends StatefulWidget {
  // 获取到的解析源
  final AnimeSource source;

  const AnimeSourceImportSheet({super.key, required this.source});

  static Future<AnimeSource?> show(BuildContext context) async {
    return QRCodeSheet.show(context).then((result) {
      if (result == null) return null;
      final source = AnimeSource.from(jsonDecode(result));
      return showModalBottomSheet<AnimeSource>(
        context: context,
        builder: (_) {
          return AnimeSourceImportSheet(
            source: source,
          );
        },
      );
    });
  }

  @override
  State<StatefulWidget> createState() => _AnimeSourceImportSheetState();
}

/*
* 番剧解析源导入sheet-状态
* @author wuxubaiyang
* @Time 2023/8/31 17:10
*/
class _AnimeSourceImportSheetState extends State<AnimeSourceImportSheet> {
  // 支持得方法集合
  final supportFunctions = ListValueChangeNotifier<AnimeParserFunction>.empty();

  // 缺少的必须方法集合
  final missRequiredFunctions =
      ValueChangeNotifier<List<AnimeParserFunction>?>(null);

  // 解析源js插件内容
  final jsPlugin = ValueChangeNotifier<String>('');

  @override
  void initState() {
    super.initState();
    // 发起请求下载插件js文件
    _downloadJSPlugin();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: kToolbarHeight * 1.5),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildSourceInfo(),
            const SizedBox(height: 14),
            _buildSourceFunctions(),
          ],
        ),
      ),
      floatingActionButton: _buildSourceImportFAB(),
    );
  }

  // 构建解析源基础信息
  Widget _buildSourceInfo() {
    final source = widget.source;
    return DefaultTextStyle(
      style: const TextStyle(color: Colors.black54, fontSize: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 24),
          AnimeSourceLogo(source: source, ratio: 40),
          const SizedBox(height: 14),
          Text('${source.name} · ${source.key}',
              style: const TextStyle(fontSize: 22, color: Colors.black)),
          TextButton(
            onPressed: () => launchUrl(Uri.parse(source.homepage)),
            child: Text(source.homepage),
          ),
          Text(source.lastEditDate.format(DatePattern.fullDateZH)),
          const SizedBox(height: 4),
          Text('v${source.version}'),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (source.proxy)
                const Icon(FontAwesomeIcons.globe, size: 16, color: Colors.red),
              if (source.nsfw) ...[
                const SizedBox(width: 8),
                const Icon(FontAwesomeIcons.skullCrossbones,
                    size: 16, color: Colors.red),
              ],
            ],
          ),
        ],
      ),
    );
  }

  // 构建当前类所支持得方法集合
  Widget _buildSourceFunctions() {
    return ValueListenableBuilder2<List<AnimeParserFunction>,
        List<AnimeParserFunction>?>(
      first: supportFunctions,
      second: missRequiredFunctions,
      builder: (_, functions, missFunctions, __) {
        missFunctions ??= [];
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Wrap(
              children: List.generate(functions.length, (i) {
                final item = functions[i];
                return ChoiceChip(
                    label: Text(item.functionNameCN), selected: true);
              }),
            ),
            if (missFunctions.isNotEmpty) ...[
              const Divider(),
              Wrap(
                children: List.generate(missFunctions.length, (i) {
                  final item = missFunctions![i];
                  return ChoiceChip(
                    label: Text(item.functionNameCN),
                    backgroundColor: Colors.red,
                    selected: true,
                  );
                }),
              ),
            ],
          ],
        );
      },
    );
  }

  // 构建解析源导入fab
  Widget _buildSourceImportFAB() {
    return FloatingActionButton.extended(
      icon: const Icon(FontAwesomeIcons.fileImport, size: 24),
      extendedTextStyle: const TextStyle(fontSize: 14),
      label: const Text('导入'),
      onPressed: () {},
    );
  }

  // 下载js插件
  Future<void> _downloadJSPlugin() async {
    try {
      final resp = await Dio().get(widget.source.fileUri);
      if (resp.statusCode != 200) {
        SnackTool.showMessage(message: '插件下载失败，请重试');
        return;
      }
      jsPlugin.setValue(resp.data);
      // 验证已存在方法
      final jsRuntime = getJavascriptRuntime();
      final functionMap = {},
          functions = [],
          requiredFunctions = <AnimeParserFunction>[];
      for (final fun in AnimeParserFunction.values) {
        final key = fun.functionName;
        functions.add('$key: typeof $key === "function"');
        functionMap[key] = fun;
        if (fun.required) requiredFunctions.add(fun);
      }
      final result = await jsRuntime.evaluateAsync('''
    ${resp.data}
    function doJSFunction() {
    return JSON.stringify({
            ${functions.join(',')}
        })
    }
    doJSFunction()
    ''');
      jsRuntime.executePendingJob();
      final jsResult = await jsRuntime.handlePromise(result);
      final results = jsonDecode(jsResult.stringResult);
      // 计算得出支持方法与缺少的必须方法
      supportFunctions.setValue(results.keys
          .where((key) => results[key] ?? false)
          .map<AnimeParserFunction>((key) => functionMap[key])
          .toList());
      missRequiredFunctions.setValue(requiredFunctions.where((e) {
        return !supportFunctions.contains(e);
      }).toList());
    } catch (e) {
      LogTool.e('导入js插件失败', error: e);
      SnackTool.showMessage(message: '插件下载失败，请重试');
    }
  }
}
