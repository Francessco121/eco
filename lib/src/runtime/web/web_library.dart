import '../../view_compiler_internal.dart';
import '../built_in_function.dart';
import '../built_in_function_exception.dart';
import '../built_in_library.dart';
import '../callable.dart';
import '../function_parameter.dart';
import '../library_environment.dart';
import '../runtime_value.dart';
import '../runtime_value_type.dart';
import 'view.dart';

class WebLibrary extends BuiltInLibrary {
  @override
  final String id = 'web';

  @override
  final String defaultImportIdentifier = 'Web';

  final ViewCompilerInternal _viewCompiler;

  WebLibrary(this._viewCompiler) {
    // layout
    defineFunction(BuiltInFunction(
      (context, args) {
        final RuntimeValue key = args['key'];

        final View view = _viewCompiler.getView(context.callingLibrary);
        
        if (view.child != null && view.child.layoutValues != null) {
          return view.child.layoutValues[key] ?? RuntimeValue.fromNull();
        } else {
          return RuntimeValue.fromNull();
        }
      },
      parameters: [
        FunctionParameter('key')
      ],
      name: 'layout'
    ));

    // inherit
    defineFunction(BuiltInFunction(
      (context, args) {
        final LibraryEnvironment library = parseLibrary(args, 'library');
        final Map<RuntimeValue, RuntimeValue> values = parseMap(args, 'values', allowNull: true);
        
        final View view = _viewCompiler.getView(context.callingLibrary);
        final View inherittedView = _viewCompiler.getView(library.library);

        view.setParent(inherittedView, values);
        inherittedView.child = view;
      },
      parameters: [
        FunctionParameter('library'),
        FunctionParameter('values', defaultValue: RuntimeValue.fromNull())
      ],
      name: 'inherit'
    ));

    // view
    defineFunction(BuiltInFunction(
      (context, args) {
        final Callable callback = parseFunction(args, 'callback');

        final View view = _viewCompiler.getView(context.callingLibrary);
        view.contentCallback = callback;
      },
      parameters: [
        FunctionParameter('callback')
      ],
      name: 'view'
    ));

    // stack
    defineFunction(BuiltInFunction(
      (context, args) {
        final String stackName = parseString(args, 'name');
        final String content = parseString(args, 'content');
        
        final View view = _viewCompiler.getView(context.callingLibrary);
        
        view.stackViews[stackName] = content;
      },
      parameters: [
        FunctionParameter('name'),
        FunctionParameter('content')
      ],
      name: 'stack'
    ));

    // drawStack
    defineFunction(BuiltInFunction(
      (context, args) {
        final String stackName = parseString(args, 'name');

        View view = _viewCompiler.getView(context.callingLibrary);

        // Follow the view hierarchy to build
        final buffer = new StringBuffer();

        void addStackViews(View view) {
          final String content = view.stackViews[stackName];

          if (content != null) {
            buffer.write(content);
          }

          if (view.child != null) {
            addStackViews(view.child);
          }
        }

        addStackViews(view);

        return RuntimeValue.fromString(buffer.toString());
      },
      parameters: [
        FunctionParameter('name')
      ],
      name: 'drawStack'
    ));

    // drawView
    defineFunction(BuiltInFunction(
      (context, args) {
        final View view = _viewCompiler.getView(context.callingLibrary);

        if (view.child != null && view.child.contentCallback != null) {
          final Callable contentCallback = view.child.contentCallback;
          final RuntimeValue viewResult = contentCallback.call(context, {});

          return RuntimeValue.fromString(viewResult.toString());
        } else {
          return RuntimeValue.fromString('');
        }
      },
      parameters: [],
      name: 'drawView'
    ));

    // makeStyle
    defineFunction(BuiltInFunction(
      (_, args) {
        final Map<RuntimeValue, RuntimeValue> map = parseMap(args, 'map');

        final buffer = new StringBuffer();

        map.forEach((key, value) {
          if (value.type != RuntimeValueType.$null) {
            if (buffer.length > 0) {
              buffer.write(' ');
            }

            buffer.write(key);
            buffer.write(': ');
            buffer.write(value);
            buffer.write(';');
          }
        });

        return RuntimeValue.fromString(buffer.toString());
      },
      parameters: [
        FunctionParameter('map')
      ],
      name: 'makeStyle'
    ));

    // makeClass
    defineFunction(BuiltInFunction(
      (_, args) {
        final Map<RuntimeValue, RuntimeValue> map = parseMap(args, 'map');

        final buffer = new StringBuffer();
        int pair = 0;

        map.forEach((className, condition) {
          if (condition.type != RuntimeValueType.boolean) {
            throw BuiltInFunctionException(
              "Expected pair #$pair's value to evaluate to a boolean "
              'but got ${condition.toTypeString()}.'
            );
          }

          if (condition.boolean) {
            if (pair > 0) {
              buffer.write(' ');
            }

            buffer.write(className);
          }

          pair++;
        });

        return RuntimeValue.fromString(buffer.toString());
      },
      parameters: [
        FunctionParameter('map')
      ],
      name: 'makeClass'
    ));
  }
}