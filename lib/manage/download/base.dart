import 'dart:async';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:jtech_anime/tool/log.dart';

// 下载进度回调
typedef DownloaderProgressCallback = void Function(
    int count, int total, int speed);

/*
* 下载器基类
* @author wuxubaiyang
* @Time 2023/8/1 11:17
*/
abstract class Downloader {
  // 开始下载，成功则返回播放文件的地址
  Future<File?> start(
    String url,
    String savePath, {
    CancelToken? cancelToken,
    DownloaderProgressCallback? receiveProgress,
  });

  // 文件下载（支持断点续传）
  Future<File?> download(
    String url,
    String savePath, {
    DownloaderProgressCallback? receiveProgress,
    CancelToken? cancelToken,
    void Function()? done,
  }) async {
    final c = Completer<File?>();
    // 检查本地是否存在已存在文件并获取起始位置
    int downloadStart = 0;
    File saveFile = File(savePath);
    final canPause = await _supportPause(url);
    if (canPause && await saveFile.exists()) {
      downloadStart = saveFile.lengthSync();
    }
    // 开始下载
    final options = Options(
      responseType: ResponseType.stream,
      headers: {
        if (canPause) ..._getRange(downloadStart),
      },
      followRedirects: false,
    );
    final resp = await Dio().get<ResponseBody>(url, options: options);
    int received = downloadStart;
    int total = await _getContentLength(resp);
    // 监听下载流并执行写入、完成、异常等回调
    final raf = saveFile.openSync(
      mode: canPause ? FileMode.append : FileMode.write,
    );
    final subscription = resp.data!.stream.listen((data) {
      final speed = data.length;
      final count = received += speed;
      receiveProgress?.call(count, total, speed);
      raf.writeFromSync(data);
    }, onDone: () {
      c.complete(saveFile);
      done?.call();
      raf.close();
    }, onError: (e) {
      c.completeError(e);
      raf.close();
    }, cancelOnError: true);
    // 如果执行的cancel事件则终止文件流
    cancelToken?.whenCancel.then((_) async {
      await subscription.cancel();
      await raf.close();
      c.complete();
    });
    return c.future;
  }

  // 获取下载文件大小
  Future<int> _getContentLength(Response response) async {
    try {
      final contentLength =
          response.headers.value(HttpHeaders.contentLengthHeader);
      if (contentLength == null) return 0;
      return int.tryParse(contentLength) ?? 0;
    } catch (e) {
      LogTool.e('获取远程文件大小失败', error: e);
    }
    return 0;
  }

  // 判断是否支持断点续传
  Future<bool> _supportPause(String url) async {
    return false;
    // try {
    //   final options = Options(headers: _getRange(0, 1024));
    //   final resp = await Dio().get(url, options: options);
    //   if (resp.statusCode == 200) {
    //     final headers = resp.headers.map;
    //     return [
    //       HttpHeaders.rangeHeader,
    //       HttpHeaders.acceptRangesHeader,
    //       HttpHeaders.contentRangeHeader,
    //     ].any(headers.containsKey);
    //   }
    // } catch (e) {
    //   LogTool.e('检查断点续传失败', error: e);
    // }
    // return false;
  }

  // 生成range头部
  Map<String, String> _getRange(int start, [int? end]) =>
      {'range': '$start-${end ?? ''}'};

  // 判断是否已取消
  bool isCanceled(CancelToken? cancelToken) {
    if (cancelToken == null) return false;
    return cancelToken.isCancelled;
  }
}
