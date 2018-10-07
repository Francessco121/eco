import '../built_in_function.dart';
import '../built_in_library.dart';
import 'standard_library_options.dart';

class SystemLibrary extends BuiltInLibrary {
  @override
  final String id = 'system';

  @override
  final String defaultImportIdentifier = 'System';

  SystemLibrary(StandardLibraryOptions options) {
    // print
    defineFunction(BuiltInFunction(
      (args) {
        if (options.systemPrintCallback != null) {
          options.systemPrintCallback(args[0]?.toString() ?? 'null');
        }
      },
      arity: 1,
      name: 'print'
    ));
  }
}