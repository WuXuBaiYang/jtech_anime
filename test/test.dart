import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test('test', () async {
    final m = {1: 'a', 2: 'b', 3: 'c'};
    final a = Map.from(m);
    m.clear();
    print(a);
  });
}
