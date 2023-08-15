import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test('test', () async {
    final b = DateTime.now().toIso8601String();
    final a = DateTime.tryParse(b);
    print('');
  });
}
