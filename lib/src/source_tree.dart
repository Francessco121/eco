import 'dart:collection';

class SourceTree {
  UnmodifiableMapView<Uri, SourceTreeNode> get roots => _rootsView;
  late final UnmodifiableMapView<Uri, SourceTreeNode> _rootsView;

  final Map<Uri, SourceTreeNode> _roots = {};

  SourceTree() {
    _rootsView = UnmodifiableMapView(_roots);
  }

  SourceTreeNode addRoot(Uri uri) {
    final node = new SourceTreeNode(uri);
    _roots[uri] = node;

    return node;
  }
}

class SourceTreeNode {
  final Uri? uri;
  final SourceTreeNode? parent;

  UnmodifiableListView<SourceTreeNode> get children => _childrenView;
  late final UnmodifiableListView<SourceTreeNode> _childrenView;

  final List<SourceTreeNode> _children = [];

  SourceTreeNode(this.uri, {this.parent}) {
    _childrenView = UnmodifiableListView(_children);
  }

  SourceTreeNode addChild(Uri childSourceUri) {
    final child = SourceTreeNode(childSourceUri, parent: this);
    _children.add(child);

    return child;
  }

  SourceTreeNode? getAncestor(Uri sourceUri) {
    SourceTreeNode? parent = this.parent;
    while (parent != null) {
      if (parent.uri == sourceUri) {
        return parent;
      }

      parent = parent.parent;
    }

    return null;
  }

  List<SourceTreeNode> getAncestors({Uri? untilSourceUri}) {
    final List<SourceTreeNode> ancestors = [];

    SourceTreeNode? parent = this.parent;
    while (parent != null) {
      if (parent.uri == untilSourceUri) {
        break;
      }

      ancestors.add(parent);
      parent = parent.parent;
    }

    return ancestors;
  }
}