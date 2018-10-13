import '../../library.dart';
import '../runtime_value.dart';

class View {
  /// A path to this view's parent or `null` if this is a top-level view.
  String parentViewPath;

  /// The model that should be passed to this view's parent or `null` if
  /// the view never specified a model.
  RuntimeValue parentModel;

  /// This view's child or `null` if this is an entry view.
  View child;

  /// The compiled HTML content of the view or `null` if the view never
  /// specified its output content.
  String content;

  /// A map of all stack entries by name to their view content.
  final Map<String, String> stackViews = {};

  /// The library which created this view.
  final Library library;

  View(this.library) {
    if (library == null) throw ArgumentError.notNull('library');
  }

  /// Returns a descendant view with the given [uri] or `null`
  /// if no descendant is from that `uri`.
  View getDescendant(Uri uri) {
    View child = this.child;

    while (child != null) {
      if (child.library.uri == uri) {
        return child;
      }

      child = child.child;
    }

    return null;
  }

  /// Returns a list of descendants.
  /// 
  /// If [untilUri] is specified, only descendants up to and including
  /// that URI will be returned.
  List<View> getDescendants({Uri untilUri}) {
    final List<View> descendants = [];

    View child = this.child;

    while (child != null) {
      descendants.add(child);

      if (untilUri != null && child.library.uri == untilUri) {
        break;
      }

      child = child.child;
    }

    return descendants;
  }
}