import 'package:test/test.dart';

import 'utils.dart';

void main() {
  test('single-line comments', () async {
    await runScript('''
      var a = 5;

      // a = 4;

      Assert.isTrue(a == 5);
    ''');
  });

  test('multi-line comments', () async {
    await runScript('''
      var a = 5;

      /*a = 3;
      a = 4;*/

      /* hello */ a/* world */=/* aaaa */6/* eeeee */;

      Assert.isTrue(a == 6);
    ''');
  });
}