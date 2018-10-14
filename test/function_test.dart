import 'package:eco/eco.dart';
import 'package:test/test.dart';

import 'utils.dart';

void main() {
  test('function statement', () async {
    await runScript('''
      fn normalFunc() {
        return "normal";
      }

      Assert.isTrue(normalFunc() == "normal");
    ''');
  });

  test('function expression', () async {
    await runScript('''
      var anonFunc = fn() {
        return "anon";
      };

      Assert.isTrue(anonFunc() == "anon");
    ''');
  });

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

  test('required parameters with named arguments', () async {
    try {
      await runScript('''
        fn function(a, b) { }

        function(b: true);
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

  test('named arguments', () async {
    await runScript('''
      fn function(a, b) {
        Assert.isTrue(a == 1);
        Assert.isTrue(b == 2);
      }

      function(a: 1, b: 2);
    ''');
  });

  test('named arguments in different order than parameters', () async {
    await runScript('''
      fn function(a, b) {
        Assert.isTrue(a == 1);
        Assert.isTrue(b == 2);
      }

      function(b: 2, a: 1);
    ''');
  });

  test('named arguments with positional', () async {
    await runScript('''
      fn function(a, b, c) {
        Assert.isTrue(a == 1);
        Assert.isTrue(b == 2);
        Assert.isTrue(c == 3);
      }

      function(1, c: 3, b: 2);
    ''');
  });

  test('named arguments must be last', () async {
    try {
      await runScript('''
        fn function(a, b, c, d) { }

        function(c: 3, 1, b: 2, 4);
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