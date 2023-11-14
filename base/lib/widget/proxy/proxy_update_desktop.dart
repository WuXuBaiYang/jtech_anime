import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:jtech_anime_base/manage/proxy.dart';
import 'package:jtech_anime_base/manage/router.dart';
import 'package:jtech_anime_base/model/database/proxy.dart';
import 'package:jtech_anime_base/tool/log.dart';
import 'package:jtech_anime_base/tool/snack.dart';
import 'proxy_update.dart';
/*
* 代理配置编辑/新增
* @author wuxubaiyang
* @Time 2023/10/23 14:26
*/

class AnimeSourceProxyUpdateDesktopSheet extends AnimeSourceProxyUpdateSheet {
  const AnimeSourceProxyUpdateDesktopSheet({super.key, super.record});

  @override
  State<StatefulWidget> createState() =>
      _AnimeSourceProxyUpdateDesktopSheetState();
}

/*
* 代理配置编辑/新增-状态
* @author wuxubaiyang
* @Time 2023/10/23 14:27
*/
class _AnimeSourceProxyUpdateDesktopSheetState
    extends State<AnimeSourceProxyUpdateDesktopSheet> {
  // host输入控制
  late TextEditingController hostController =
      TextEditingController(text: widget.record?.host ?? '');

  // port输入控制
  late TextEditingController portController =
      TextEditingController(text: '${widget.record?.port ?? ''}');

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 14),
        child: Row(
          // crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: TextField(
                controller: hostController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: '域名(默认localhost)',
                  contentPadding: EdgeInsets.all(14),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                maxLength: 5,
                controller: portController,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                ],
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  counterText: '',
                  border: OutlineInputBorder(),
                  labelText: '端口号（默认7890）',
                  contentPadding: EdgeInsets.all(14),
                ),
              ),
            ),
            const SizedBox(width: 8),
            TextButton.icon(
              icon: const Icon(FontAwesomeIcons.check),
              label: const Text('提交'),
              onPressed: () async {
                try {
                  final host = hostController.text.isNotEmpty
                      ? hostController.text
                      : 'localhost';
                  final port = int.tryParse(portController.text) ?? 7890;
                  final record = (widget.record ?? ProxyRecord())
                    ..host = host
                    ..port = port
                    ..proxy = '$host:$port';
                  final result = await proxy.updateProxy(record);
                  if (result != null) router.pop(record);
                } catch (e) {
                  router.pop();
                  LogTool.e('代理设置失败', error: e);
                  SnackTool.showMessage(message: '代理设置失败');
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
