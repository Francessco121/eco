import 'dart:async';
import 'dart:io' as io;

import 'package:eco/eco.dart';

Future<int> main(List<String> args) async {
  if (args.length < 2) {
    print('Usage: eco_view <view file path> <out file path>');
    return 1;
  }

  final bool success = await _compileView(args[0], args[1]);

  return success ? 0 : 1;
}

Future<bool> _compileView(String viewFilePath, String outFilePath) async {
  // Open the file
  final viewFile = new io.File(viewFilePath);
  final String viewScript = await viewFile.readAsString();

  final source = new Source(viewFile.uri, viewScript);
  final compiler = new ViewCompiler();

  try {
    final String html = await compiler.compile(source);

    final outFile = new io.File(outFilePath);
    await outFile.writeAsString(html);

    return true;
  } on ParseException catch (ex) {
    print(ex);

    return false;
  } on RuntimeException catch (ex) {
    print(ex);

    return false;
  }
}
