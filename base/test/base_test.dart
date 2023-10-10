import 'dart:math';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('test', () {
    final a = 1.0;
    print(min(max(a, 0), 1));
  });
}
