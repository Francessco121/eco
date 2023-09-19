import 'dart:async';

import 'runtime/standard_library/standard_library.dart';
import 'program.dart';
import 'source.dart';
import 'source_resolver.dart';
import 'view_compiler_internal.dart';

abstract class ViewCompiler {
  /// The underlying progam which runs the views.
  Program get program;

  /// Compiles a view from its [source].
  Future<String> compile(Source source);

  factory ViewCompiler({
    SourceResolver? sourceResolver,
    StandardLibraryOptions? standardLibraryOptions
  }) {
    return ViewCompilerInternal(
      sourceResolver: sourceResolver,
      standardLibraryOptions: standardLibraryOptions
    );
  }
}