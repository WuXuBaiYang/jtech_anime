import 'package:flutter_test/flutter_test.dart';
import 'package:logger/logger.dart';

void main() {
  test('test', () async {
    Logger logger = Logger();
    logger.i({'name':'荒唐哥','sex':'unknown'});
  });
}
