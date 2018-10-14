import 'package:test/test.dart';

import 'utils.dart';

void main() {
  // While loop
  test('while loop', () async {
    await runScript('''
      var counter = 0;
      while counter < 10 {
        counter++;
      }
        
      Assert.isTrue(counter == 10);
    ''');
  });

  test('while loop with break', () async {
    await runScript('''
      var value;
      var i = 0;
      
      while i < 10 {
        if i++ == 5 {
          break;
        }
          
        value = i;
      }

      Assert.isTrue(value == 5);
    ''');
  });

  test('while loop with continue', () async {
    await runScript('''
      var list = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10];
      var copy = [];

      var i = 0;
      while i < #list {
        var value = list[i++];
        
        if value == 5 {
          continue;
        }
          
        copy[i - 1] = value;
      }

      Assert.isTrue(copy[5] == 6);
      Assert.isNull(copy[4]);
    ''');
  });

  // For loop
  test('for loop', () async {
    await runScript('''
      var counter = 0;
      for var i = 0; i < 10; i++ {
        counter = i + 1;
      }

      Assert.isTrue(counter == 10);
    ''');
  });

  test('for loop with break', () async {
    await runScript('''
      var value;
      for var i = 0; i < 10; i++ {
        if i == 5 {
          break;
        }
          
        value = i;
      }

      Assert.isTrue(value == 4);
    ''');
  });

  test('for loop with continue', () async {
    await runScript('''
      var list = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10];
      var copy = [];

      for var i = 0; i < #list; i++ {
        var value = list[i];
        
        if value == 5 {
          continue;
        }
          
        copy[i] = value;
      }

      Assert.isTrue(copy[5] == 6);
      Assert.isNull(copy[4]);
    ''');
  });

  test('for loop scoping', () async {
    await runScript('''
      var outer = 5;
      var i = 8;
      for var i = 0; i < 1; i++ {
        Assert.isTrue(outer == 5, 'For-loop scope inheritance test failed.');
        Assert.isTrue(i == 0, 'For-loop clause scope test failed.');
      }

      Assert.isTrue(i == 8, 'For-loop scope test failed.');
    ''');
  });

  // Foreach loop
  test('foreach loop on list', () async {
    await runScript('''
      var array = [1, 2, 3];
      var map = { "key": "value" };

      var reverse = [];
      foreach i, value in array {
        reverse[#array - i - 1] = value;
      }

      Assert.isTrue(reverse[0] == 3);
    ''');
  });

  test('foreach loop on map', () async {
    await runScript('''
      var map = { "key": "value", "key2": "value2" };
      var reverse = {};

      foreach key, value in map {
        reverse[value] = key;
      }

      Assert.isTrue(reverse["value"] == "key");
      Assert.isTrue(reverse["value2"] == "key2");
    ''');
  });

  test('foreach loop with break', () async {
    await runScript('''
      var value;
      var list = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10];
      foreach _, item in list {
        if item == 5 {
          break;
        }
        
        value = item;
      }

      Assert.isTrue(value == 4);
    ''');
  });

  test('foreach loop with continue', () async {
    await runScript('''
      var list = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10];
      var copy = [];

      foreach i, value in list {
        if value == 5 {
          continue;
        }
          
        copy[i] = value;
      }

      Assert.isTrue(copy[5] == 6);
      Assert.isNull(copy[4]);
    ''');
  });
}