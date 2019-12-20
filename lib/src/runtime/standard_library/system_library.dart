import '../built_in_function.dart';
import '../built_in_library.dart';
import '../function_parameter.dart';
import 'standard_library_options.dart';

class SystemLibrary extends BuiltInLibrary {
  @override
  final String id = 'system';

  @override
  final String defaultImportIdentifier = 'System';

  SystemLibrary(StandardLibraryOptions options) {
    // print
    defineFunction(BuiltInFunction(
      (_, args) {
        if (options.systemPrintCallback != null) {
          options.systemPrintCallback(args['message'].toString() ?? 'null');
        }

        return null;
      },
      parameters: [
        FunctionParameter('message')
      ],
      name: 'print'
    ));
  }
}