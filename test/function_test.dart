import 'package:test/test.dart';

import 'utils.dart';

void main() {
  test('optional parameters', () async {
    await runScript('''
      fn function(required, optional = 10) {
        Assert.isTrue(required == true);
        Assert.isTrue(optional == 10);
      }

      function(true);
    ''');
  });

  test('required parameters', () async {
    try {
      await runScript('''
        fn function(required) { }

        function();
      ''');
    } on Exception catch (ex) {
      if (ex is RuntimeException) {
        return;
      }

      rethrow;
    }

    fail('Test should have failed.');
  });
}