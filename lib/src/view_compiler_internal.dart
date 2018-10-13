import 'dart:async';
import 'dart:collection';

import 'package:meta/meta.dart';
import 'package:source_span/source_span.dart';

import 'parsing/parse_error.dart';
import 'parsing/parse_exception.dart';
import 'runtime/standard_library/standard_library.dart';
import 'runtime/web/view.dart';
import 'runtime/web/web_library.dart';
import 'runtime/library_environment.dart';
import 'library.dart';
import 'program.dart';
import 'source.dart';
import 'source_resolver.dart';
import 'source_tree.dart';
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
      View finalView = view;

      // Keep processing views until we have reached a root view
      while (finalView.parentViewPath != null) {
        // Load the parent view
        final Source parentSource = await _loadParentViewSource(finalView);

        final SourceTreeNode treeNode = program.sourceTree.addRoot(parentSource.uri);
        final Library parentLibrary = await program.loadUserLibrary(parentSource, treeNode);

        // Create the view data ahead of time and set the child to the current 'final view'
        final View parentView = getView(parentLibrary);
        parentView.child = finalView;

        // Run the parent view
        program.loadEnvironment(parentLibrary);

        // Continue using the parent view as the new 'final view'
        finalView = parentView;
      }

      return finalView.content;
    }
    
    // No view was created...
    return '';
  }

  /// Gets an existing or creates a view for the given [library].
  View getView(Library library) {
    View view = _views[library];

    if (view == null) {
      view = new View(library);
      _views[library] = view;
    }

    return view;
  }

  Future<Source> _loadParentViewSource(View fromView) async {
    // Resolve a path to the parent view
    final Uri uri = program.sourceResolver.resolvePath(
      fromView.parentViewPath,
      fromView.library.uri
    );

    // Ensure the view isn't inheriting itself
    if (uri == fromView.library.uri) {
      _throwParseError(fromView.library.uri, 
        'View cannot inherit itself. Uri: $uri'
      );
    }

    // Load the source
    final Source source = await program.loadSource(uri);

    if (source == null) {
      _throwParseError(fromView.library.uri, 
        'Could not find view to inherit from path: $uri'
      );
    }

    // Check for cyclic inheritance
    final View cyclicChild = fromView.getDescendant(uri);
    if (cyclicChild != null) {
      _throwCyclicInheritanceError(fromView, cyclicChild);
    }

    return source;
  }

  @alwaysThrows
  void _throwCyclicInheritanceError(View view, View cyclicChild) {
    final buffer = StringBuffer();
    buffer.writeln('Inheritance would result in cyclic dependencies because');

    final Iterable<View> descendants = view
      .getDescendants(untilUri: cyclicChild.library.uri);

    bool first = true;
    for (final View descendant in descendants) {
      if (first) {
        buffer.write('the view ');
        first = false;
      } else {
        buffer.writeln(',');
        buffer.write('which ');
      }

      buffer.write('is inherited from ${descendant.library.uri}');
    }

    buffer.write('.');

    _throwParseError(view.library.uri, buffer.toString());
  }

  @alwaysThrows
  void _throwParseError(Uri fileUri, String message) {
    final location = SourceLocation(0, sourceUrl: fileUri);

    final error = ParseError(
      SourceSpan(location, location, ''),
      message
    );

    throw ParseException(UnmodifiableListView([error]));
  }
}