import 'runtime/library_environment.dart';
import 'program.dart';

/// An isolated piece of Eco code which can be executed in
/// various contexts as well as be imported by other libraries.
abstract class Library {
  /// Runs this library for the given [program] with the given [environment].
  void run(Program program, LibraryEnvironment environment);
}