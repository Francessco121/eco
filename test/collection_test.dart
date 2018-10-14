import 'package:test/test.dart';

import 'utils.dart';

void main() {
  test('lists', () async {
    await runScript('''
      var list = [0, 3, 4, 6];

      Assert.isTrue(list[0] == 0);
      Assert.isTrue(list[1] == 3);
    ''');
  });

  test('map index', () async {
    await runScript('''
      var map = {
        "key": true,
        10 + 1: {
          "inner": fn() { }
        }
      };

      Assert.isTrue(map["key"] == true);
      Assert.isNotNull(map[11]["inner"]);
    ''');
  });

  test('map get', () async {
    await runScript('''
      var programming = {
        is: {
          fun: true
        }
      };

      Assert.isTrue(programming.is.fun == true);
    ''');
  });
}