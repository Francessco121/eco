import 'package:test/test.dart';

import 'utils.dart';

void main() {
  test('scope inheritance', () async {
    await runScript('''
      var a = 1;

      {
        Assert.areEqual(a, 1);
      }
    ''');
  });
  test('scope inheritance set', () async {
    await runScript('''
      var a = 1;

      {
        a = 2;

        Assert.areEqual(a, 2);
      }

      Assert.areEqual(a, 2);
    ''');
  });

  test('scope inheritance in initializer', () async {
    await runScript('''
      var a = 1;

      {
        var a = a;
        a++;

        Assert.areEqual(a, 2);
      }

      Assert.areEqual(a, 1);
    ''');
  });
}