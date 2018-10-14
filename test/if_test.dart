import 'package:test/test.dart';

import 'utils.dart';

void main() {
  test('if true then', () async {
    await runScript('''
      var selection;
      if true {
        selection = 'then';
      }
        
      Assert.areEqual('then', selection);
    ''');
  });

  test('if false then', () async {
    await runScript('''
      var selection;
      if false {
        selection = 'then';
      }
        
      Assert.isNull(selection);
    ''');
  });

  test('if true then with else', () async {
    await runScript('''
      var selection;
      if true {
        selection = 'then';
      } else {
        selection = 'else';
      }
        
      Assert.areEqual('then', selection);
    ''');
  });

  test('if false then with else', () async {
    await runScript('''
      var selection;
      if false {
        selection = 'then';
      } else {
        selection = 'else';
      }
        
      Assert.areEqual('else', selection);
    ''');
  });
}