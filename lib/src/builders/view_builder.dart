import 'dart:async';

import 'package:build/build.dart';
import 'package:path/path.dart' as path;

import '../parsing/parse_exception.dart';
import '../runtime/runtime_exception.dart';
import '../source.dart';
import '../source_resolver.dart';
import '../view_compiler.dart';

class ViewBuilder implements Builder {
  @override
  final buildExtensions = {'.view.eco': ['.html']};

  @override
  Future<void> build(BuildStep buildStep) async {
    final String viewScript = await buildStep.readAsString(buildStep.inputId);

    final source = new Source(buildStep.inputId.uri, viewScript);
    final compiler = new ViewCompiler(
      sourceResolver: BuildSourceResolver(buildStep)
    );

    try {
      final String html = await compiler.compile(source);

      final String outPath = path.withoutExtension(
        path.withoutExtension(buildStep.inputId.path)
      ) + '.html';

      final AssetId outId = AssetId(buildStep.inputId.package, outPath);
      
      await buildStep.writeAsString(outId, html);
    } on ParseException catch (ex) {
      log.severe(ex);
    } on RuntimeException catch (ex) {
      log.severe(ex);
    }
  }
}