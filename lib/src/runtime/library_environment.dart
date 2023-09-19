import '../library.dart';
import 'scope.dart';

class LibraryEnvironment {
  /// The library this environment is for.
  final Library library;

  /// The public scope of the library which may be accessed
  /// by other libraries.
  final Scope publicScope;

  /// The internal scope of the library which can only
  /// be used by the library itself.
  final Scope libraryScope;
  
  LibraryEnvironment._({
    required this.library,
    required this.publicScope,
    required this.libraryScope
  });

  /// Creates a new environment for running the given [library].
  factory LibraryEnvironment(Library library) {
    final publicScope = new Scope();
    final libraryScope = new Scope(publicScope);

    return LibraryEnvironment._(
      library: library,
      publicScope: publicScope,
      libraryScope: libraryScope
    );
  }
}