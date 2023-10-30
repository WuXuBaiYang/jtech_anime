import 'package:dart_ping/dart_ping.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('test', () async {
    Ping('www.baidu.com', count: 1).stream.listen((event) {
      print(event);
    });
  });
}
