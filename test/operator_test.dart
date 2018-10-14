import 'package:test/test.dart';

import 'utils.dart';

void main() {
  // Binary operators
  test('equality', () async {
    await runScript('''
      Assert.isTrue(true == true);
    ''');
  });

  test('not equality', () async {
    await runScript('''
      Assert.isTrue(true != false);
    ''');
  });

  test('less than', () async {
    await runScript('''
      Assert.isTrue(10 < 11);
    ''');
  });

  test('less than or equal to', () async {
    await runScript('''
      Assert.isTrue(10 <= 10);
      Assert.isTrue(9 <= 10);
    ''');
  });

  test('greater than', () async {
    await runScript('''
      Assert.isTrue(11 > 10);
    ''');
  });

  test('greater than or equal to', () async {
    await runScript('''
      Assert.isTrue(10 >= 10);
      Assert.isTrue(11 >= 10);
    ''');
  });

  test('subtraction', () async {
    await runScript('''
      Assert.isTrue((10 - 4) == 6);
    ''');
  });

  test('addition', () async {
    await runScript('''
      Assert.isTrue((2 + 3) == 5);
    ''');
  });

  test('multiplication', () async {
    await runScript('''
      Assert.isTrue((3 * 4) == 12);
    ''');
  });

  test('division', () async {
    await runScript('''
      Assert.isTrue((12 / 3) == 4);
      Assert.isTrue((12 / 5) == 2.4);
    ''');
  });

  test('modulo', () async {
    await runScript('''
      Assert.isTrue((9 % 5) == 4);
    ''');
  });

  test('concatenation of lists', () async {
    await runScript('''
      var a = [1, 2, 3];
      var b = [4, 5, 6];
      var c = a .. b;

      Assert.isTrue(c[0] == 1);
      Assert.isTrue(c[1] == 2);
      Assert.isTrue(c[2] == 3);
      Assert.isTrue(c[3] == 4);
      Assert.isTrue(c[4] == 5);
      Assert.isTrue(c[5] == 6);
    ''');
  });

  test('concatenation of strings', () async {
    await runScript('''
      var str1 = 'Hello';
      var str2 = 'World!';
      var str3 = str1 .. ' ' .. str2;

      Assert.isTrue(str3 == "Hello World!");
    ''');
  });

  // Unary operators
  test('boolean negation', () async {
    await runScript('''
      Assert.isTrue(!true == false);
    ''');
  });

  test('numeric negation', () async {
    await runScript('''
      Assert.isTrue(-(-1) == 1);
      Assert.isTrue(-1 == (0 - 1));
    ''');
  });

  test('postfix increment', () async {
    await runScript('''
      var a = 5;

      Assert.isTrue(a++ == 5);
      Assert.isTrue(a == 6);
    ''');
  });

  test('postfix decrement', () async {
    await runScript('''
      var a = 5;

      Assert.isTrue(a-- == 5);
      Assert.isTrue(a == 4);
    ''');
  });

  test('length operator with list', () async {
    await runScript('''
      var list = [1, 2, 3];

      Assert.isTrue(#list == 3);
    ''');
  });

  test('length operator with map', () async {
    await runScript('''
      var map = { key: true, otherKey: false };

      Assert.isTrue(#map == 2);
    ''');
  });

  test('length operator with string', () async {
    await runScript('''
      var string = 'aaaa';

      Assert.isTrue(#string == 4);
    ''');
  });

  // Logical operators
  test('logical and', () async {
    await runScript('''
      Assert.isTrue((true and true) == true);
      Assert.isTrue((true and false) == false);
      Assert.isTrue((false and true) == false);
      Assert.isTrue((false and false) == false);
    ''');
  });

  test('logical or', () async {
    await runScript('''
      Assert.isTrue((true or true) == true);
      Assert.isTrue((true or false) == true);
      Assert.isTrue((false or true) == true);
      Assert.isTrue((false or false) == false);
    ''');
  });

  test('logical precedence', () async {
    await runScript('''
      Assert.isTrue((true or false and false) == true);
    ''');
  });

  // Ternary
  test('ternary operator', () async {
    await runScript('''
      Assert.isTrue((1 == 1 ? 'hi' : 'nooo') == 'hi');
      Assert.isTrue((1 == 2 ? 'hi' : 'nooo') == 'nooo');
    ''');
  });

  // Null coalesce
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
