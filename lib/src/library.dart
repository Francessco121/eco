import 'runtime/library_environment.dart';
import 'program.dart';

/// An isolated piece of Eco code which can be executed in
/// various contexts as well as be imported by other libraries.
abstract class Library {
  /// A URI which identifies this library.
  Uri get uri;

  /// Runs this library for the given [program] with the given [environment].
  void run(Program program, LibraryEnvironment environment);
}