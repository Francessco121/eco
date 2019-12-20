import 'dart:async';
import 'dart:collection';

import 'parsing/parse_exception.dart';
import 'runtime/standard_library/standard_library.dart';
import 'runtime/built_in_library.dart';
import 'runtime/library_environment.dart';
import 'runtime/runtime_value.dart';
import 'library.dart';
import 'source.dart';
import 'source_resolver.dart';
import 'source_tree.dart';
import 'user_library.dart';

class Program {
  /// A map of all built-in libraries available to this program.
  /// 
  /// Map keys are the ID of the library.
  UnmodifiableMapView<String, BuiltInLibrary> get builtInLibraries => _builtInLibrariesView;

  /// A list of built-in library IDs which are implicitly imported
  /// for all libraries ran by this program.
  UnmodifiableListView<String> get implicitImports => _implicitImportsView;

  /// A map of all libraries that have been loaded by this program.
  UnmodifiableMapView<Uri, Library> get libraries => _librariesView;

  /// The resolver used to load sources.
  final SourceResolver sourceResolver;

  /// The entire dependency tree of the program.
  final sourceTree = new SourceTree();

  UnmodifiableMapView<String, BuiltInLibrary> _builtInLibrariesView;
  UnmodifiableListView<String> _implicitImportsView;
  UnmodifiableMapView<Uri, Library> _librariesView;

  final Map<String, BuiltInLibrary> _builtInLibraries = {};
  final List<String> _implicitImports = [];
  final Map<Uri, Source> _loadedSources = {};
  final Map<Source, UserLibrary> _cachedUserLibraries = {};
  final Map<Library, LibraryEnvironment> _cachedEnvironments = {};
  final Map<Uri, Library> _libraries = {};

  Program({
    SourceResolver sourceResolver,
    StandardLibraryOptions standardLibraryOptions
  })
    : this.sourceResolver = sourceResolver ?? FileSourceResolver() {

    _builtInLibrariesView = UnmodifiableMapView(_builtInLibraries);
    _implicitImportsView = UnmodifiableListView(_implicitImports);
    _librariesView = UnmodifiableMapView(_libraries);

    // Add standard library
    standardLibraryOptions ??= new StandardLibraryOptions(
      systemPrintCallback: print
    );

    // Implicit standard libraries
    addLibrary(new SystemLibrary(standardLibraryOptions), importImplicitly: true);
    addLibrary(new StringLibrary(), importImplicitly: true);
    addLibrary(new ObjectLibrary(), importImplicitly: true);

    // Other standard libraries
    addLibrary(new AssertLibrary());
  }

  /// Makes the built-in [library] available to this program.
  /// 
  /// If [importImplicitly] is `true`, the library will be automatically
  /// imported before normal library code is ran.
  void addLibrary(BuiltInLibrary library, {bool importImplicitly = false}) {
    _builtInLibraries[library.id] = library;

    if (importImplicitly) {
      _implicitImports.add(library.id);
    }

    final uri = new Uri(scheme: 'eco', path: library.id);

    _libraries[uri] = library;
  }

  Future<LibraryEnvironment> run(Source source) async {
    // Cache the source
    _loadedSources[source.uri] = source;

    // Create a new root source tree node
    final treeNode = sourceTree.addRoot(source.uri);

    // Create and cache the user library
    final library = await UserLibrary.create(this, treeNode, source.sourceSpan);
    _cachedUserLibraries[source] = library;

    if (library.parseErrors.isNotEmpty) {
      throw ParseException(library.parseErrors);
    }

    // Create an environment
    var environment = new LibraryEnvironment(library);

    // Add implicit imports
    _addImplicitImports(environment);

    // Run the library to finalize the environment
    library.run(this, environment);

    // All set!
    return environment;
  }
  
  Future<Source> loadSource(Uri uri) async {
    Source source = _loadedSources[uri];

    if (source == null) {
      source = await sourceResolver.load(uri);

      if (source != null) {
        _loadedSources[uri] = source;
      }
    }

    return source;
  }

  Future<UserLibrary> loadUserLibrary(Source source, SourceTreeNode treeNode) async {
    UserLibrary library = _cachedUserLibraries[source];

    if (library == null) {
      library = await UserLibrary.create(this, treeNode, source.sourceSpan);

      _cachedUserLibraries[source] = library;
      _libraries[source.uri] = library;
    }

    return library;
  }

  LibraryEnvironment loadEnvironment(Library library) {
    LibraryEnvironment environment = _cachedEnvironments[library];

    if (environment == null) {
      environment = _createEnvironment(library);

      _cachedEnvironments[library] = environment;
    }

    return environment;
  }

  LibraryEnvironment _createEnvironment(Library library) {
    final environment = new LibraryEnvironment(library);

    // Only add implicit imports for user libraries
    if (library is UserLibrary) {
      // Add implicit imports
      _addImplicitImports(environment);
    }

    // Load the library
    library.run(this, environment);

    // All set
    return environment;
  }

  void _addImplicitImports(LibraryEnvironment environment) {
    for (final String id in _implicitImports) {
      // Get the built-in library
      final BuiltInLibrary builtInLibrary = _builtInLibraries[id];

      // Create an environment for the built-in library
      final LibraryEnvironment builtInLibraryEnvironment = 
        loadEnvironment(builtInLibrary);

      // Define the built-in library with the default identifier
      environment.libraryScope.define(
        builtInLibrary.defaultImportIdentifier, 
        new RuntimeValue.fromLibrary(builtInLibraryEnvironment)
      );
    }
  }
}