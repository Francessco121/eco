import 'dart:async';

import 'runtime/standard_library/standard_library.dart';
import 'runtime/web/view.dart';
import 'runtime/web/web_library.dart';
import 'runtime/call_context.dart';
import 'runtime/callable.dart';
import 'runtime/library_environment.dart';
import 'runtime/runtime_value.dart';
import 'library.dart';
import 'program.dart';
import 'source.dart';
import 'source_resolver.dart';
import 'view_compiler.dart';

class ViewCompilerInternal implements ViewCompiler {
  @override
  final Program program;

  final Map<Library, View> _views = {};

  ViewCompilerInternal({
    SourceResolver sourceResolver,
    StandardLibraryOptions standardLibraryOptions
  })
    : program = new Program(
      sourceResolver: sourceResolver,
      standardLibraryOptions: standardLibraryOptions
    ) {
    
    // Add the web library
    program.addLibrary(new WebLibrary(this), importImplicitly: true);
  }

  @override
  Future<String> compile(Source viewSource) async {
    _views.clear();

    final LibraryEnvironment result = await program.run(viewSource);
    final View view = _views[result.library];

    if (view != null) {
      // Find the root view
      //
      // We must build the view from the ground up, rather than
      // from the starting view.
      View finalView = view;
      while (finalView.parent != null) {
        finalView = finalView.parent;
      }

      // Build the view
      final Callable contentCallback = finalView.contentCallback;

      if (contentCallback != null) {
        final RuntimeValue viewResult = contentCallback.call(
          CallContext(result.library, result), 
          {}
        );

        return viewResult.toString();
      }
    }
    
    // No view was created...
    return '';
  }

  /// Gets an existing or creates a view for the given [library].
  View getView(Library library) {
    View view = _views[library];

    if (view == null) {
      view = new View();
      _views[library] = view;
    }

    return view;
  }
}