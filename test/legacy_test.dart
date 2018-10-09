import 'dart:io' as io;

import 'package:eco/eco.dart';
import 'package:test/test.dart';

void main() {
  // Run the old language_tests.eco file.
  // Eventually this file will be separated into individual tests.

  test('language_tests.eco', () async {
    final file = new io.File('test/scripts/language_tests.eco');
    final String content = await file.readAsString();

    final program = new Program();

    await program.run(new Source(file.uri, content));
  });
}