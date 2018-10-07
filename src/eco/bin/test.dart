import 'dart:async';
import 'dart:io' as io;

import 'package:eco/eco.dart';

void main(List<String> args) {
  const String filePath = 'bin/test.eco';

  _runFile(filePath);
}

Future<void> _runFile(String filePath) async {
  // Open the file
  final file = new io.File(filePath);
  final String content = await file.readAsString();

  await _runString(file.uri, content);
}

Future<void> _runString(Uri uri, String content) async {
  final source = new Source(uri, content);
  final program = new Program();

  try {
    await program.run(source);
  } on ParseException catch (ex) {
    for (final error in ex.parseErrors) {
      print(error.sourceSpan.message(error.message));
    }
  } on RuntimeException catch (ex) {
    print(ex.sourceSpan.message(ex.message));
  }
}