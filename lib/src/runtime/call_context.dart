import '../library.dart';
import 'library_environment.dart';

class CallContext {
  /// The library the call was invoked from.
  final Library callingLibrary;

  /// The current environment of the library which the call was invoked from.
  final LibraryEnvironment callingEnvironment;

  CallContext(this.callingLibrary, this.callingEnvironment);
}