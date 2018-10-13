import 'package:test/test.dart';

import 'utils.dart';

void main() {
  test('equality', () async {
    await runScript('''
      Assert.isTrue(true == true, "Equality operator test failed.");
    ''');
  });

  test('not equality', () async {
    await runScript('''
      Assert.isTrue(true != false, "Not equality operator test failed.");
    ''');
  });

  test('less than', () async {
    await runScript('''
      Assert.isTrue(10 < 11, "Less than operator test failed.");
    ''');
  });

  test('less than or equal to', () async {
    await runScript('''
      Assert.isTrue(10 <= 10, "Less than or equal to operator test failed.");
    ''');
  });

  test('null coalesce with null value', () async {
    await runScript('''
      Assert.isTrue((null ?? 10) == 10);
    ''');
  });

  test('null coalesce with non null value', () async {
    await runScript('''
      Assert.isTrue((4 ?? 10) == 4);
    ''');
  });

  test('null coalesce only runs right expression when left is null', () async {
    await runScript('''
      var variable = 5;

      var temp = 2 ?? (variable = 4);

      Assert.isTrue(variable == 5);
    ''');
  });
}
