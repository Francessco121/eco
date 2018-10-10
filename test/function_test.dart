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
}