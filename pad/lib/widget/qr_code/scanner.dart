import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pad/widget/qr_code/mask_view.dart';
import 'package:jtech_anime_base/base.dart';
import 'package:camera/camera.dart';
import 'package:pad/widget/qr_code/scan/view.dart';

import 'scan/controller.dart';

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
  // 动画-扫码
  static const String qrCodeScannerAsset = 'assets/anime/qrcode_scanner.json';

  // 闪光灯模式
  final flashMode = ValueChangeNotifier<FlashMode>(FlashMode.off);

  // 扫码控制器
  final controller = CustomScanController();

  @override
  void initState() {
    super.initState();
    // 隐藏全部状态栏
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenSize = MediaQuery.of(context).size;
    final pixelRatio = mediaQuery.devicePixelRatio;
    final ratio = screenSize.width / (1080 / pixelRatio);
    final previewSize = Size(screenSize.width, (1920 / pixelRatio) * ratio);
    final maskSize = Size.square(previewSize.width * 0.6);
    final bottomSize = Size.fromHeight(screenSize.height -
        previewSize.height -
        kToolbarHeight -
        mediaQuery.padding.top);
    final maskRect = Rect.fromLTWH(
      (previewSize.width - maskSize.width) / 2,
      (previewSize.height - maskSize.height) / 2,
      maskSize.width,
      maskSize.height,
    );
    return Theme(
      data: ThemeData.dark(useMaterial3: true),
      child: Scaffold(
        appBar: AppBar(
          title: widget.title,
        ),
        backgroundColor: Colors.black,
        bottomNavigationBar: SizedBox.fromSize(
          size: bottomSize,
          child: _buildBottomActions(),
        ),
        body: SizedBox.fromSize(
          size: previewSize,
          child: Stack(
            children: [
              _buildScanner(previewSize),
              _buildAnimaMask(previewSize, maskRect),
              _buildScannerAnima(maskRect),
            ],
          ),
        ),
      ),
    );
  }

  // 构建扫描器
  Widget _buildScanner(Size previewSize) {
    return Positioned.fill(
      child: CustomScanView(
        autoStart: true,
        controller: controller,
        onResult: (result) {
          Navigator.pop(context, result);
        },
      ),
    );
  }

  // 构建扫码动画遮罩层
  Widget _buildAnimaMask(Size previewSize, Rect maskRect) {
    return MaskView(
      color: Colors.transparent,
      maskViewSize: previewSize,
      backgroundColor: Colors.black45,
      rRect: RRect.fromRectAndRadius(
        maskRect,
        const Radius.circular(8),
      ),
    );
  }

  // 构建扫码动画
  Widget _buildScannerAnima(Rect maskRect) {
    return Positioned.fromRect(
      rect: maskRect,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: LottieView(
          qrCodeScannerAsset,
          fit: BoxFit.cover,
          width: maskRect.width,
          height: maskRect.height,
        ),
      ),
    );
  }

  // 构建底部操作按钮集合
  Widget _buildBottomActions() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ValueListenableBuilder<FlashMode>(
          valueListenable: flashMode,
          builder: (_, mode, __) {
            final torchLight = mode == FlashMode.torch;
            return IconButton.outlined(
              color: torchLight ? kPrimaryColor : Colors.white,
              icon: const Icon(FontAwesomeIcons.boltLightning),
              onPressed: () {
                mode = torchLight ? FlashMode.off : FlashMode.torch;
                controller.setFlashMode(mode);
                flashMode.setValue(mode);
              },
            );
          },
        ),
      ],
    );
  }

  @override
  void dispose() {
    // 关闭闪光灯
    controller.setFlashMode(FlashMode.off);
    // 恢复屏幕状态
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: SystemUiOverlay.values);
    super.dispose();
  }
}
