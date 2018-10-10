import '../built_in_function.dart';
import '../built_in_library.dart';
import 'standard_library_options.dart';
import '../runtime_parameter.dart';

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
          options.systemPrintCallback(args['message'].toString() ?? 'null');
        }
      },
      parameters: [
        RuntimeParameter('message')
      ],
      name: 'print'
    ));
  }
}