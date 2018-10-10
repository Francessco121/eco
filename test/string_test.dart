import 'package:test/test.dart';

import 'utils.dart';

void main() {
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
}