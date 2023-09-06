import 'dart:io';
import 'package:flutter/material.dart';
import 'package:mobile/widget/qr_code/scanner.dart';
import 'package:jtech_anime_base/base.dart';
import 'package:qr_code_dart_scan/qr_code_dart_scan.dart';

/*
* 二维码扫描sheet
* @author wuxubaiyang
* @Time 2023/8/16 16:36
*/
class QRCodeSheet extends StatefulWidget {
  // 扫码标题栏
  final Widget? title;

  const QRCodeSheet({super.key, this.title});

  static Future<String?> show(BuildContext context, {Widget? title}) {
    return showModalBottomSheet<String>(
      context: context,
      showDragHandle: false,
      builder: (_) => QRCodeSheet(
        title: title,
      ),
    );
  }

  @override
  State<StatefulWidget> createState() => _QRCodeSheetState();
}

/*
* 二维码扫描sheet-状态
* @author wuxubaiyang
* @Time 2023/8/16 16:37
*/
class _QRCodeSheetState extends State<QRCodeSheet> {
  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      children: [
        if (Platform.isAndroid || Platform.isIOS)
          ListTile(
            title: const Text('扫码'),
            onTap: () async {
              try {
                router.pop(await QRCodeScanner.start(
                  context,
                  title: widget.title,
                ));
              } catch (e) {
                LogTool.e('扫码失败', error: e);
                SnackTool.showMessage(message: '二维码扫描失败');
              }
            },
          ),
        ListTile(
          title: const Text('从相册中选择'),
          onTap: () async {
            try {
              router.pop(await _decoderQRCodeFromGallery());
            } catch (e) {
              LogTool.e('二维码识别失败', error: e);
              SnackTool.showMessage(message: '二维码识别失败');
            }
          },
        ),
      ],
    );
  }

  // 选择图片并解码其中的二维码
  static Future<String?> _decoderQRCodeFromGallery() async {
    final picker = ImagePicker();
    final xFile = await picker.pickImage(source: ImageSource.gallery);
    if (xFile == null) return null;
    final decoder = QRCodeDartScanDecoder(formats: [BarcodeFormat.QR_CODE]);
    final result = await decoder.decodeFile(xFile);
    if (result == null) return null;
    return result.text;
  }
}
