import 'package:test/test.dart';

import 'utils.dart';

void main() {
  test('multi-line strings', () async {
    await runScript(r'''
      var str = "Hello
      World!";

      Assert.isTrue(String.sub(str, 0, 5) == "Hello", "Multi-line string test #1 failed.");
      Assert.isTrue(String.sub(str, #str - 6, 6) == "World!", "Multi-line string test #2 failed.");

      var NEWLINE_CHAR = 10;
      var CARRIAGE_RETURN_CHAR = 13;

      var newlineChar1 = String.byte(str, 5);
      Assert.isTrue(newlineChar1 == NEWLINE_CHAR or newlineChar1 == CARRIAGE_RETURN_CHAR, 
        "Multi-line string new-line character test #1 failed.");

      // Windows (\r\n) / Classic mac (\r)
      if newlineChar1 == CARRIAGE_RETURN_CHAR {
        var newlineChar2 = String.byte(str, 6);

        Assert.isTrue(newlineChar2 == NEWLINE_CHAR or newlineChar1 == "W", 
          "Multi-line string new-line test #2 failed.");
      }
    ''');
  });

  test('html string', () async {
    await runScript('''
      var normal = '
        <span>
          Hello\\\\n World!
        </span>
      ';

      var htmlStr = `
        <span>
          Hello\\n World!
        </span>
      `;

      Assert.areEqual(normal, htmlStr);
    ''');
  });

  test('string escape sequences', () async {
    await runScript(r'''
      var SINGLE_QUOTE_CHAR = 39;
      var DOUBLE_QUOTE_CHAR = 34;
      var BACKSLASH_CHAR = 92;
      var NEWLINE_CHAR = 10;
      var CARRIAGE_RETURN_CHAR = 13;
      var HORIZONTAL_TAB_CHAR = 9;

      var escapes = "\'\\\n\r\t\"";

      Assert.isTrue(String.byte(escapes, 0) == SINGLE_QUOTE_CHAR, "String single-quote escape test failed.");
      Assert.isTrue(String.byte(escapes, 1) == BACKSLASH_CHAR, "String backslash escape test failed.");
      Assert.isTrue(String.byte(escapes, 2) == NEWLINE_CHAR, "String new-line escape test failed.");
      Assert.isTrue(String.byte(escapes, 3) == CARRIAGE_RETURN_CHAR, "String carriage return escape test failed.");
      Assert.isTrue(String.byte(escapes, 4) == HORIZONTAL_TAB_CHAR, "String horizontal tab escape test failed.");
      Assert.isTrue(String.byte(escapes, 5) == DOUBLE_QUOTE_CHAR, "String double-quote escape test failed.");
    ''');
  });
}