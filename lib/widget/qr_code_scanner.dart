import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:qr_code_dart_scan/qr_code_dart_scan.dart';

/*
* 二维码扫描组件
* @author wuxubaiyang
* @Time 2023/8/17 10:31
*/
class QRCodeScanner extends StatefulWidget {
  const QRCodeScanner({super.key});

  // 启动扫码页面
  static Future<String?> start(BuildContext context) {
    return Navigator.push<String>(context, MaterialPageRoute(
      builder: (_) {
        return const QRCodeScanner();
      },
    ));
  }

  @override
  State<StatefulWidget> createState() => _QRCodeScannerState();
}

/*
* 二维码扫描组件-状态
* @author wuxubaiyang
* @Time 2023/8/17 10:32
*/
class _QRCodeScannerState extends State<QRCodeScanner> {
  // 扫码类型限制
  final formats = const [
    BarcodeFormat.QR_CODE,
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        alignment: Alignment.topLeft,
        children: [
          QRCodeDartScanView(
            formats: formats,
            typeScan: TypeScan.live,
            scanInvertedQRCode: true,
            onCapture: (result) {
              Navigator.pop(context, result.text);
            },
          ),
          SafeArea(
            child: IconButton(
              icon: const Icon(FontAwesomeIcons.xmark),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ],
      ),
    );
  }
}
