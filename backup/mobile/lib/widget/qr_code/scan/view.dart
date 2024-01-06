import 'package:camera/camera.dart';
import 'package:flutter/widgets.dart';
import 'package:jtech_anime_base/base.dart';
import 'controller.dart';
import 'iso.dart';

/// create a scan widget to capture and show camera
class CustomScanView extends StatefulWidget {
  /// constructor
  const CustomScanView({
    super.key,
    this.child,
    this.autoStart = true,
    this.flashMode = FlashMode.off,
    this.onError,
    this.onResult,
    this.controller,
  });

  /// child element to cover camera view
  final Widget? child;

  /// auto start capture and decode
  final bool autoStart;

  /// flash Mode
  final FlashMode flashMode;

  /// error callback
  final Function(dynamic)? onError;

  /// result callback
  final Function(String)? onResult;

  /// capture controller
  final CustomScanController? controller;

  @override
  State<CustomScanView> createState() => _CustomScanViewState();
}

class _CustomScanViewState extends State<CustomScanView> implements ScanState {
  CameraController? _controller;
  List<CameraDescription>? _cameras;
  final _isoController = IsolateController();
  bool isDetectedCamera = false;
  bool isStop = false;

  @override
  void initState() {
    super.initState();
    widget.controller?.attach(this);
    Future.wait([
      initCamera(),
      _isoController.start(),
      Future.delayed(const Duration(seconds: 1)),
    ]).then((value) {
      if (widget.autoStart) start();
    });
  }

  Future<void> initCamera() async {
    try {
      _cameras = await availableCameras();
      var camera = _cameras!.first;
      for (var c in _cameras!) {
        if (c.lensDirection == CameraLensDirection.back) {
          camera = c;
        }
      }
      if (_cameras!.isNotEmpty) {
        _controller = CameraController(
          camera,
          enableAudio: false,
          ResolutionPreset.veryHigh,
          imageFormatGroup: ImageFormatGroup.yuv420,
        );
        await _controller!.initialize();
        if (!mounted) return;
        await _controller!.setFlashMode(widget.flashMode);
      } else {
        widget.onError?.call(Exception('Undetected camera'));
      }
    } catch (e) {
      widget.onError?.call(e);
    } finally {
      setState(() => isDetectedCamera = true);
    }
  }

  bool _isStart = false;

  @override
  Future<void> start() async {
    if (_isStart || !mounted) return;
    _isStart = true;
    await _controller!.startImageStream((image) {
      if (!mounted || isStop) return;
      Throttle.c(
        delay: const Duration(milliseconds: 300),
        () => tryDecodeImage(image),
        'tryDecodeImage',
      );
    });
  }

  @override
  Future<void> stop() async {
    if (!_isStart) return;
    _isStart = false;
    await _controller!.stopImageStream();
  }

  @override
  Future<void> setFlashMode(FlashMode mode) async {
    return _controller?.setFlashMode(mode);
  }

  Future<void> tryDecodeImage(CameraImage image) async {
    if (!mounted) return;
    final results = await _isoController.setPlanes(image.planes);
    if (!mounted) return;
    final result = results.first.text;
    widget.onResult?.call(result);
    widget.controller?.value = result;
    await stop();
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      child: _controller == null
          ? Center(
              child: Text(
                isDetectedCamera ? '未检测到摄像头' : '正在检测摄像头',
              ),
            )
          : CameraPreview(
              _controller!,
              child: widget.child,
            ),
    );
  }
}
