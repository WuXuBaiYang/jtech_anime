import 'package:flutter_test/flutter_test.dart';

void main() {
  int absoluteIndex(String s) {
    s = s.replaceAll('.ts', '');
    final length = s.length;
    if (length != 17 || int.tryParse(s.substring(11, length)) == null) {
      return -1;
    }
    var ret = 0;
    for (int i = s.runes.length - 10; i < s.runes.length; i++) {
      var ascii = s.codeUnitAt(i);
      if (ascii >= 97) {
        ascii -= 87;
      } else {
        ascii -= 48;
      }
      ret = ret * 10 + ascii;
    }
    return ret;
  }

  test('test', () async {
    const name = 'adqweadsfqwas000032.ts';
    print(absoluteIndex(name));
  });
}
