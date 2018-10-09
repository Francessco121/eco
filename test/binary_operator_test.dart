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
}
