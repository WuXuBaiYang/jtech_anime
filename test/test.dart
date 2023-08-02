import 'dart:async';

import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test('test', () async {
    final a = [
      Completer()
        ..complete(Future(() async {
          await Future.delayed(const Duration(milliseconds: 500));
          // throw Exception('异常');
        }))
    ];
    final b = await Future.any(a.map((e) => e.future));
    print('----------------------');
  });
}
