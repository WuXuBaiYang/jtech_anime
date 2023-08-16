import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:jtech_anime/manage/router.dart';
import 'package:qr_code_dart_scan/qr_code_dart_scan.dart';

/*
* 二维码扫描sheet
* @author wuxubaiyang
* @Time 2023/8/16 16:36
*/
class QRCodeSheet extends StatefulWidget {
  const QRCodeSheet({super.key});

  static Future<File?> show(BuildContext context) {
    return showModalBottomSheet<File>(
      builder: (_) => const QRCodeSheet(),
      context: context,
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
    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      clipBehavior: Clip.hardEdge,
      child: ListView(
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        children: [
          if (Platform.isAndroid || Platform.isIOS)
            ListTile(title: const Text('扫码'), onTap: _scanQRCode),
          ListTile(title: const Text('从相册中选择'), onTap: _pickQRCode),
        ],
      ),
    );
  }

  // 扫描二维码
  Future<void> _scanQRCode() async {}

  // 选择二维码图片
  Future<void> _pickQRCode() async {
    final picker = ImagePicker();
    final xFile = await picker.pickImage(source: ImageSource.gallery);
    if (xFile == null) return router.pop();
    final decoder = QRCodeDartScanDecoder(formats: [BarcodeFormat.QR_CODE]);
    final result = await decoder.decodeFile(xFile);
    if (result == null) return router.pop();
    router.pop(result.text);
  }
}
