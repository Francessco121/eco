import 'scope.dart';

class LibraryEnvironment {
  /// The public scope of the library which may be accessed
  /// by other libraries.
  final Scope publicScope;

  /// The internal scope of the library which can only
  /// be used by the library itself.
  final Scope libraryScope;
  
  LibraryEnvironment._({
    this.publicScope,
    this.libraryScope
  });

  /// Creates a new environment for running libraries.
  factory LibraryEnvironment() {
    final publicScope = new Scope();
    final libraryScope = new Scope(publicScope);

    return LibraryEnvironment._(
      publicScope: publicScope,
      libraryScope: libraryScope
    );
  }
}