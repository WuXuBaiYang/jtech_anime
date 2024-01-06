import 'dart:async';
import 'dart:isolate';
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:zxing_lib/common.dart';
import 'package:zxing_lib/multi.dart';
import 'package:zxing_lib/zxing.dart';

enum _IsoCommand {
  decode,
  success,
  fail,
}

class _IsoMessage {
  _IsoMessage(this.cmd, [this.data])
      : result = null,
        assert(cmd != _IsoCommand.decode || data != null);

  _IsoMessage.result(this.result)
      : cmd = _IsoCommand.success,
        data = null,
        assert(result != null);

  _IsoMessage.fail()
      : cmd = _IsoCommand.success,
        data = null,
        result = null;

  final List<Plane>? data;
  final List<Result>? result;
  final _IsoCommand cmd;
}

/// controller an isolate to executer decode command
class IsolateController extends ChangeNotifier {
  Isolate? _newIsolate;
  late ReceivePort _receivePort;
  late SendPort _newIceSP;
  Capability? _capability;

  List<Plane> _currentPlanes = <Plane>[];
  final List<List<Result>?> _currentResults = [];
  bool _created = false;
  bool _paused = false;

  /// get current data of yuv planes
  List<Plane> get currentMultiplier => _currentPlanes;

  /// isolate status: is paused
  bool get paused => _paused;

  /// isolate status: is created
  bool get created => _created;

  /// get last result
  List<List<Result>?> get currentResults => _currentResults;

  Future<void> _createIsolate() async {
    _receivePort = ReceivePort();
    _newIsolate = await Isolate.spawn(_decodeFromCamera, _receivePort.sendPort);
  }

  void _listen() {
    _receivePort.listen((dynamic message) {
      if (message is SendPort) {
        _newIceSP = message;
        if (_currentPlanes.isNotEmpty) {
          _newIceSP.send(_currentPlanes);
        }
      } else if (message is _IsoMessage) {
        if (message.cmd == _IsoCommand.success ||
            message.cmd == _IsoCommand.fail) {
          _setCurrentResults(message.result);
        }
      }
    });
  }

  /// start isolate
  Future<void> start() async {
    if (_created == false && _paused == false) {
      await _createIsolate();
      _listen();
      _created = true;
      notifyListeners();
    }
  }

  /// dispose isolate
  void terminate() {
    _newIsolate?.kill();
    _created = false;
    _currentResults.clear();
    notifyListeners();
  }

  /// pause/resume isolate
  void pausedSwitch() {
    if (_paused && _capability != null) {
      _newIsolate?.resume(_capability!);
    } else {
      _capability = _newIsolate?.pause();
    }

    _paused = !_paused;
    notifyListeners();
  }

  Completer<List<Result>>? _completer;

  /// set a yuv planes to start decode
  Future<List<Result>> setPlanes(List<Plane> planes) {
    _currentPlanes = planes;
    _completer = Completer<List<Result>>();
    _newIceSP.send(_IsoMessage(_IsoCommand.decode, _currentPlanes));
    notifyListeners();
    return _completer!.future;
  }

  void _setCurrentResults(List<Result>? result) {
    _currentResults.insert(0, result);
    notifyListeners();
    if (!(_completer?.isCompleted ?? true)) {
      if (result != null) {
        _completer?.complete(result);
      } else {
        _completer?.completeError('Decode Failed');
      }
    }
  }

  @override
  void dispose() {
    _newIsolate?.kill(priority: Isolate.immediate);
    _newIsolate = null;
    super.dispose();
  }
}

Future<void> _decodeFromCamera(SendPort callerSP) async {
  final newIceRP = ReceivePort();
  callerSP.send(newIceRP.sendPort);

  final reader = GenericMultipleBarcodeReader(MultiFormatReader());

  List<Plane>? planes;

  Completer<bool> goNext = Completer();
  newIceRP.listen((dynamic message) {
    if (message is _IsoMessage) {
      if (message.cmd == _IsoCommand.decode) {
        if (goNext.isCompleted) {
          return;
        }
        planes = message.data;

        goNext.complete(true);
      }
    }
  });

  callerSP.send(newIceRP.sendPort);

  while (true) {
    await goNext.future;
    if (planes != null) {
      final e = planes!.first;
      final width = e.bytesPerRow;
      final height = (e.bytes.length / width).round();
      final total = planes!
          .map<double>((p) => p.bytesPerPixel!.toDouble())
          .reduce((value, element) => value + 1 / element)
          .toInt();
      final data = Uint8List(width * height * total);
      int startIndex = 0;
      for (var p in planes!) {
        List.copyRange(data, startIndex, p.bytes);
        startIndex += width * height ~/ p.bytesPerPixel!;
      }

      final imageSource = PlanarYUVLuminanceSource(
        data,
        width,
        height,
      );

      final bitmap = BinaryBitmap(HybridBinarizer(imageSource));
      try {
        final results = reader.decodeMultiple(
          bitmap,
          const DecodeHint(tryHarder: false, alsoInverted: false),
        );
        callerSP.send(_IsoMessage.result(results));
      } on NotFoundException catch (_) {
        try {
          final results = reader.decodeMultiple(
            bitmap,
            const DecodeHint(tryHarder: true, alsoInverted: true),
          );
          callerSP.send(_IsoMessage.result(results));
        } on NotFoundException catch (_) {
          callerSP.send(_IsoMessage.fail());
        }
      }
    }

    goNext = Completer();
  }
}
