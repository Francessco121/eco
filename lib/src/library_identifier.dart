class LibraryIdentifier {
  final Uri _userLibraryUri;
  final String _builtInLibraryId;

  LibraryIdentifier.forUserLibrary(Uri uri)
    : _userLibraryUri = uri,
      _builtInLibraryId = null;

  LibraryIdentifier.forBuiltInLibrary(String id)
    : _builtInLibraryId = id,
      _userLibraryUri = null;

  @override
  int get hashCode {
    // Return the hash code of the type we are identifying.
    if (_userLibraryUri != null) {
      return _userLibraryUri.hashCode;
    } else {
      return _builtInLibraryId.hashCode;
    }
  }

  @override
  bool operator ==(other) {
    if (other is LibraryIdentifier) {
      // Only compare the type that we are identifying. If the other
      // is identifying a different type, we will be checking against
      // null and return false.
      if (_userLibraryUri != null) {
        // Compare user libraries
        return _userLibraryUri == other._userLibraryUri;
      } else {
        // Compare built-in libraries
        return _builtInLibraryId == other._builtInLibraryId;
      }
    } else {
      return false;
    }
  }
}