import '../callable.dart';
import '../runtime_value.dart';

// TODO: clean up layoutValuesCallback

class View {
  /// The parent view or `null` if this is a root view.
  View get parent => _parent;

  Callable get layoutValuesCallback => _layoutValuesCallback;

  /// The child view or `null` if this is a starting view.
  View child;

  /// The callback to generate the view content or `null` if the view
  /// never set it.
  Callable contentCallback;

  /// A map of all stack entries by name to their view content.
  final Map<String, String> stackViews = {};

  View _parent;
  Callable _layoutValuesCallback;

  /// Sets this view to have the given [parent], giving it the given [callback].
  void setParent(View parent, Callable callback) {
    if (parent == null) throw ArgumentError.notNull('parent');

    _parent = parent;
    _layoutValuesCallback = callback;
  }
}