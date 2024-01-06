import 'package:flutter_js/flutter_js.dart';

/*
* js运行时方法封装
* @author wuxubaiyang
* @Time 2023/9/6 16:37
*/
class JSRuntime {
  // 持有js运行时对象
  final _jsRuntime = getJavascriptRuntime();

  // 执行js方法
  Future<String> eval(String code) async {
    final result = await _jsRuntime.evaluateAsync(code);
    _jsRuntime.executePendingJob();
    final evalResult = await _jsRuntime.handlePromise(result);
    return evalResult.stringResult;
  }

  // 监听自定义消息
  void onMessage(String channelName, dynamic Function(dynamic args) fn) {
    _jsRuntime.onMessage(channelName, fn);
  }
}
