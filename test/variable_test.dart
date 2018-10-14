import 'package:eco/eco.dart';
import 'package:test/test.dart';

import 'utils.dart';

void main() {
  test('variable default value', () async {
    await runScript('''
      var test;

      Assert.isNull(test);
    ''');
  });

  test('variable initializer', () async {
    await runScript('''
      var test = 3;

      Assert.areEqual(3, test);
    ''');
  });

  test('variable assignment', () async {
    await runScript('''
      var test = 3;

      test = 2;

      Assert.areEqual(2, test);
    ''');
  });

  test('variable re-declaration in same scope should fail', () async {
    try {
      await runScript('''
        var a = 3;
        var a = 2;
      ''');
    } on Exception catch (ex) {
      if (ex is ParseException) {
        return;
      }

      rethrow;
    }

    fail('Test should have failed.');
  });

  test('variable re-declaration in different scopes', () async {
    await runScript('''
      var a = 3;

      {
        var a = 2;

        Assert.areEqual(2, a);
      }

      Assert.areEqual(3, a);
    ''');
  });
}