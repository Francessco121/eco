import '../../view_compiler_internal.dart';
import '../built_in_function.dart';
import '../built_in_function_exception.dart';
import '../built_in_library.dart';
import '../function_parameter.dart';
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
    // getModel
    defineFunction(BuiltInFunction(
      (context, args) {
        final View view = _viewCompiler.getView(context.callingLibrary);
        
        if (view.child != null && view.child!.parentModel != null) {
          return view.child!.parentModel!;
        } else {
          return RuntimeValue.fromNull();
        }
      },
      parameters: [],
      name: 'getModel'
    ));

    // inherit
    defineFunction(BuiltInFunction(
      (context, args) {
        final String parentViewPath = parseString(args, 'path')!;
        final RuntimeValue? model = args['model'];
        
        final View view = _viewCompiler.getView(context.callingLibrary);
        view.parentViewPath = parentViewPath;
        view.parentModel = model;

        return null;
      },
      parameters: [
        FunctionParameter('path'),
        FunctionParameter('model', defaultValue: RuntimeValue.fromNull())
      ],
      name: 'inherit'
    ));

    // view
    defineFunction(BuiltInFunction(
      (context, args) {
        final String content = parseString(args, 'content')!;

        final View view = _viewCompiler.getView(context.callingLibrary);
        view.content = content;

        return null;
      },
      parameters: [
        FunctionParameter('content')
      ],
      name: 'view'
    ));

    // stack
    defineFunction(BuiltInFunction(
      (context, args) {
        final String stackName = parseString(args, 'name')!;
        final String content = parseString(args, 'content')!;
        
        final View view = _viewCompiler.getView(context.callingLibrary);
        
        view.stackViews[stackName] = content;

        return null;
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
        final String stackName = parseString(args, 'name')!;

        View view = _viewCompiler.getView(context.callingLibrary);

        // Follow the view hierarchy to build
        final buffer = new StringBuffer();

        void addStackViews(View view) {
          final String? content = view.stackViews[stackName];

          if (content != null) {
            buffer.write(content);
          }

          if (view.child != null) {
            addStackViews(view.child!);
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

        if (view.child != null && view.child!.content != null) {
          return RuntimeValue.fromString(view.child!.content!);
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
        final Map<RuntimeValue, RuntimeValue> map = parseMap(args, 'map')!;

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
        final Map<RuntimeValue, RuntimeValue> map = parseMap(args, 'map')!;

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