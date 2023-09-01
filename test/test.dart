import 'package:flutter_test/flutter_test.dart';
import 'package:jtech_anime/manage/anime_parser/funtions.dart';

void main() {
  test('test', () async {
    final functions = AnimeParserFunction.values.map((v) {
      final name = v.functionName;
      return '$name: typeof $name === "function"';
    }).toList();
    final a = '''
    function doJSFunction() {
    return JSON.stringify({
            ${functions.join(',')}
        })
    }
    doJSFunction()
    ''';
    print(a);
  });
}
