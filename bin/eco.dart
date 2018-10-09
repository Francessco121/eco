import 'dart:async';
import 'dart:io' as io;

import 'package:eco/eco.dart';

Future<int> main(List<String> args) async {
  if (args.isEmpty) {
    print('Usage: eco <file path>');
    return 1;
  }

  final bool success = await _runFile(args[0]);

  return success ? 0 : 1;
}

Future<bool> _runFile(String filePath) async {
  // Open the file
  final file = new io.File(filePath);
  final String content = await file.readAsString();

  return await _runString(file.uri, content);
}

Future<bool> _runString(Uri uri, String content) async {
  final source = new Source(uri, content);
  final program = new Program();

  try {
    await program.run(source);

    return true;
  } on ParseException catch (ex) {
    print(ex);

    return false;
  } on RuntimeException catch (ex) {
    print(ex);

    return false;
  }
}