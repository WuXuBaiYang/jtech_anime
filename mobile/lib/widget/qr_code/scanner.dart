import 'package:flutter/material.dart';
import 'package:mobile/widget/mask_view.dart';
import 'package:jtech_anime_base/base.dart';
import 'package:qr_code_dart_scan/qr_code_dart_scan.dart';
import 'package:camera/camera.dart';

/*
* 二维码扫描组件
* @author wuxubaiyang
* @Time 2023/8/17 10:31
*/
class QRCodeScanner extends StatefulWidget {
  // 标题
  final Widget? title;

  const QRCodeScanner({super.key, this.title});

  // 启动扫码页面
  static Future<String?> start(BuildContext context, {Widget? title}) {
    return Navigator.push<String>(context, MaterialPageRoute(
      builder: (_) {
        return QRCodeScanner(
          title: title,
        );
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
  // 闪光灯模式
  final flashMode = ValueChangeNotifier<FlashMode>(FlashMode.off);

  // 控制器
  final controller = QRCodeDartScanController();

  // 扫码类型限制
  final formats = const [
    BarcodeFormat.QR_CODE,
  ];

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final maskSize = Size.square(screenSize.width * 0.6);
    return Scaffold(
      appBar: AppBar(
        title: widget.title,
        actions: [
          _buildFlashButton(),
        ],
      ),
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        alignment: Alignment.topLeft,
        children: [
          _buildScanner(context),
          _buildAnimaMask(context, screenSize, maskSize),
          _buildScannerAnima(maskSize),
        ],
      ),
    );
  }

  // 构建扫描器
  Widget _buildScanner(BuildContext context) {
    final previewSize = _genPreviewSize(context);
    return QRCodeDartScanView(
      formats: formats,
      controller: controller,
      typeScan: TypeScan.live,
      scanInvertedQRCode: true,
      widthPreview: previewSize.width,
      heightPreview: previewSize.height,
      resolutionPreset: QRCodeDartScanResolutionPreset.veryHigh,
      onCapture: (result) => Navigator.pop(context, result.text),
    );
  }

  // 构建扫码动画遮罩层
  Widget _buildAnimaMask(BuildContext context, Size screenSize, Size maskSize) {
    final padding = MediaQuery.of(context).padding;
    final rect = Rect.fromLTWH(
      (screenSize.width - maskSize.width) / 2,
      (screenSize.height - maskSize.height - kToolbarHeight - padding.top) / 2,
      maskSize.width,
      maskSize.height,
    );
    return MaskView(
      maskViewSize: screenSize,
      color: Colors.transparent,
      backgroundColor: Colors.black45,
      rRect: RRect.fromRectAndRadius(rect, const Radius.circular(8)),
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

  // 获取预览尺寸
  Size _genPreviewSize(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final pixelRatio = mediaQuery.devicePixelRatio;
    return Size(1080 / pixelRatio, 1920 / pixelRatio);
  }

  // 闪光灯按钮
  Widget _buildFlashButton() {
    return ValueListenableBuilder<FlashMode>(
      valueListenable: flashMode,
      builder: (_, mode, __) {
        final torchLight = mode == FlashMode.torch;
        return IconButton(
          color: torchLight ? kPrimaryColor : null,
          icon: const Icon(FontAwesomeIcons.boltLightning),
          onPressed: () {
            mode = torchLight ? FlashMode.off : FlashMode.torch;
            controller.setFlashMode(mode);
            flashMode.setValue(mode);
          },
        );
      },
    );
  }

  @override
  void dispose() {
    // 关闭闪光灯
    controller.setFlashMode(FlashMode.off);
    super.dispose();
  }
}
