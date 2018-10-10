import 'package:eco/eco.dart';
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

  test('optional parameters must be last', () async {
    try {
      await runScript('''
        fn function(optional = null, required) { }
      ''');
    } on Exception catch (ex) {
      if (ex is ParseException && ex.parseErrors.length == 1) {
        return;
      }

      rethrow;
    }

    fail('Test should have failed.');
  });

  test('optional parameters must be last in anonymous function', () async {
    try {
      await runScript('''
        function = fn (optional = null, required) { }
      ''');
    } on Exception catch (ex) {
      if (ex is ParseException && ex.parseErrors.length == 1) {
        return;
      }

      rethrow;
    }

    fail('Test should have failed.');
  });
}