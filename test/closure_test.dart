import 'package:test/test.dart';

import 'utils.dart';

void main() {
  test('closure', () async {
    await runScript('''
      fn closureTest() {
        var innerVar = "test";
        
        return fn() {
          return innerVar;
        };
      }

      Assert.isTrue(closureTest()() == "test");
    ''');
  });

  test('closure lexical scoping', () async {
    await runScript('''
      var i = 4;

      {
        fn test() {
          return i;
        }

        var i = 2;
        Assert.isTrue(test() == 4);
      }
    ''');
  });
}