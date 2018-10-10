import '../callable.dart';
import '../runtime_value.dart';

class View {
  /// The parent view or `null` if this is a root view.
  View get parent => _parent;

  /// A map of values passed onto the parent view or `null`
  /// if this is a root view or this view isn't passing any values.
  Map<RuntimeValue, RuntimeValue> get layoutValues => _layoutValues;

  /// The child view or `null` if this is a starting view.
  View child;

  /// The callback to generate the view content or `null` if the view
  /// never set it.
  Callable contentCallback;

  /// A map of all stack entries by name to their view content.
  final Map<String, String> stackViews = {};

  View _parent;
  Map<RuntimeValue, RuntimeValue> _layoutValues;

  /// Sets this view to have the given [parent], giving it the given [values].
  void setParent(View parent, Map<RuntimeValue, RuntimeValue> values) {
    if (parent == null) throw ArgumentError.notNull('parent');

    _parent = parent;
    _layoutValues = values;
  }
}