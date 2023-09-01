import 'package:flutter/material.dart';
import 'package:jtech_anime/common/common.dart';
import 'package:jtech_anime/widget/mask_view.dart';
import 'package:lottie/lottie.dart';
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
    final screenSize = MediaQuery.of(context).size;
    final maskSize = Size.square(screenSize.width * 0.6);
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        alignment: Alignment.topLeft,
        children: [
          _buildScanner(screenSize),
          _buildAnimaMask(screenSize, maskSize),
          _buildScannerAnima(maskSize),
          _buildBackButton(),
        ],
      ),
    );
  }

  // 构建扫描器
  Widget _buildScanner(Size screenSize) {
    const previewSize = Size(1080, 1920);
    return QRCodeDartScanView(
      formats: formats,
      typeScan: TypeScan.live,
      scanInvertedQRCode: true,
      widthPreview: previewSize.width,
      heightPreview: previewSize.height,
      resolutionPreset: QRCodeDartScanResolutionPreset.veryHigh,
      onCapture: (result) => Navigator.pop(context, result.text),
    );
  }

  // 构建扫码动画遮罩层
  Widget _buildAnimaMask(Size screenSize, Size maskSize) {
    return MaskView(
      maskViewSize: screenSize,
      color: Colors.transparent,
      backgroundColor: Colors.black45,
      rRect: RRect.fromRectAndRadius(
        Rect.fromLTWH(
          (screenSize.width - maskSize.width) / 2,
          (screenSize.height - maskSize.height) / 2,
          maskSize.width,
          maskSize.height,
        ),
        const Radius.circular(8),
      ),
    );
  }

  // 构建扫码动画
  Widget _buildScannerAnima(Size maskSize) {
    return Center(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Lottie.asset(
          Common.qrCodeScannerAsset,
          frameRate: FrameRate.max,
          height: maskSize.height,
          width: maskSize.width,
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  // 构建后退按钮
  Widget _buildBackButton() {
    return const SafeArea(
      child: Align(
        alignment: Alignment.topLeft,
        child: Padding(
          padding: EdgeInsets.all(14),
          child: BackButton(),
        ),
      ),
    );
  }
}
