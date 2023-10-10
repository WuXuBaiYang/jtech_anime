import 'dart:ui' as ui;
import 'package:flutter/rendering.dart';
import 'dart:async';
import 'dart:io';
import 'dart:isolate';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:zxing_lib/common.dart';
import 'package:zxing_lib/multi.dart';
import 'package:zxing_lib/zxing.dart';

/*
* 二维码/条码
* @author wuxubaiyang
* @Time 2023/9/19 11:24
*/
class QRCode {
  // 拍摄照片并解析二维码
  static Future<String?> decodeFromCamera({int maxSize = 600}) async {
    final image = await ImagePicker().pickImage(source: ImageSource.camera);
    if (image == null) return null;
    return decode(image.path, maxSize: maxSize);
  }

  // 本地选择文件并解析二维码
  static Future<String?> decodeFromGallery({int maxSize = 600}) async {
    final image = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (image == null) return null;
    return decode(image.path, maxSize: maxSize);
  }

  // 从本地路径的文件中解析二维码信息
  static Future<String?> decode(String path, {int maxSize = 600}) async {
    final file = File(path);
    if (!file.existsSync()) return null;
    final bytes = await file.readAsBytes();
    final ui.Image image = await decodeImageFromList(bytes);
    final byteData = await image.toByteData();
    if (byteData == null) return null;
    final results = await _decodeImageInIsolate(
      byteData.buffer.asUint8List(),
      image.width,
      image.height,
      maxSize: maxSize,
    );
    if (results == null || results.isEmpty) return null;
    return results.first.text;
  }

  /// decode image in an isolate(except web).
  static Future<List<Result>?> _decodeImageInIsolate(
    Uint8List image,
    int width,
    int height, {
    bool isRgb = true,
    int maxSize = 600,
  }) async {
    if (kIsWeb) {
      return isRgb
          ? _decodeImage(_IsoMessage(null, image, width, height, maxSize))
          : _decodeCamera(_IsoMessage(null, image, width, height, maxSize));
    }
    final complete = Completer<List<Result>?>();
    final port = ReceivePort();
    port.listen(
      (message) {
        if (!complete.isCompleted) {
          complete.complete(message as List<Result>?);
        }
        port.close();
      },
      onDone: () {},
      onError: (error) {},
    );

    final message = _IsoMessage(port.sendPort, image, width, height, maxSize);
    if (isRgb) {
      Isolate.spawn<_IsoMessage>(_decodeImage, message,
          debugName: 'decodeImage');
    } else {
      Isolate.spawn<_IsoMessage>(
        _decodeCamera,
        message,
        debugName: 'decodeCamera',
      );
    }

    return complete.future;
  }

  static Uint8List _scaleDown(
    Uint8List data,
    int width,
    int height,
    int newWidth,
    int newHeight,
    double scale,
  ) {
    final scaleCeil = scale.ceil();
    final newBuffer = Uint8List(newWidth * newHeight);
    final colors = List<int?>.filled(scaleCeil * scaleCeil, null);
    for (int y = 0; y < newHeight; y++) {
      for (int x = 0; x < newWidth; x++) {
        int count = 0;
        colors.fillRange(0, colors.length, null);
        final startY = (y * scale).round();
        final startX = (x * scale).round();
        final endY = startY + scaleCeil;
        final endX = startX + scaleCeil;
        for (int sy = startY; sy < endY; sy++) {
          if (sy >= height) break;
          for (int sx = startX; sx < endX; sx++) {
            if (sx >= width) break;
            count++;
            final pos = sy * width + sx;
            if (pos < data.length) {
              colors[(sy - startY) * scaleCeil + sx - startX] = data[pos];
            }
          }
        }
        if (count < 1) break;

        int newColor = 0;
        for (int? color in colors) {
          if (color != null) {
            newColor += color;
          }
        }
        newBuffer[y * newWidth + x] = (newColor / count).round();
      }
    }
    return newBuffer;
  }

  static int _getLuminanceSourcePixel(List<int> byte, int index) {
    if (byte.length <= index + 3) {
      return 0xff;
    }
    final r = byte[index] & 0xff; // red
    final g2 = (byte[index + 1] << 1) & 0x1fe; // 2 * green
    final b = byte[index + 2]; // blue
    // Calculate green-favouring average cheaply
    return ((r + g2 + b) ~/ 4);
  }

  static List<Result>? _decodeImage(_IsoMessage message) {
    var pixels = Uint8List(message.width * message.height);
    for (int i = 0; i < pixels.length; i++) {
      pixels[i] = _getLuminanceSourcePixel(message.byteData, i * 4);
    }

    int width = message.width;
    int height = message.height;
    if (width > message.maxSize || height > message.maxSize) {
      final scale = min(width / message.maxSize, height / message.maxSize);
      final newWidth = (width / scale).ceil();
      final newHeight = (height / scale).ceil();
      pixels = _scaleDown(pixels, width, height, newWidth, newHeight, scale);
      width = newWidth;
      height = newHeight;
    }

    final imageSource = RGBLuminanceSource.orig(
      width,
      height,
      pixels,
    );

    final bitmap = BinaryBitmap(HybridBinarizer(imageSource));

    final reader = GenericMultipleBarcodeReader(MultiFormatReader());
    try {
      final results = reader.decodeMultiple(
        bitmap,
        const DecodeHint(tryHarder: true, alsoInverted: true),
      );

      message.sendPort?.send(results);
      return results;
    } on NotFoundException catch (_) {
      message.sendPort?.send(null);
    }
    return null;
  }

  static List<Result>? _decodeCamera(_IsoMessage message) {
    final imageSource = PlanarYUVLuminanceSource(
      message.byteData.buffer.asUint8List(),
      message.width,
      message.height,
    );

    final bitmap = BinaryBitmap(HybridBinarizer(imageSource));
    final reader = GenericMultipleBarcodeReader(MultiFormatReader());
    try {
      final results = reader.decodeMultiple(
        bitmap,
        const DecodeHint(tryHarder: false, alsoInverted: false),
      );
      message.sendPort?.send(results);
      return results;
    } on NotFoundException catch (_) {
      try {
        final results = reader.decodeMultiple(
          bitmap,
          const DecodeHint(tryHarder: true, alsoInverted: true),
        );
        message.sendPort?.send(results);
        return results;
      } on NotFoundException catch (_) {
        message.sendPort?.send(null);
      }
    }
    return null;
  }
}

class _IsoMessage {
  final SendPort? sendPort;
  final Uint8List byteData;
  final int width;
  final int height;
  final int maxSize;

  _IsoMessage(
    this.sendPort,
    this.byteData,
    this.width,
    this.height, [
    this.maxSize = 600,
  ]);
}
