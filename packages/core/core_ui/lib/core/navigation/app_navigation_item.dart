import 'package:flutter/widgets.dart';
import 'app_navigation_section.dart';

/// Represents a navigation item in the application.
///
/// This class decouples the navigation structure from the UI implementation,
/// allowing modules to provide their navigation options without knowing about
/// the specific widgets used to render them.
class AppNavigationItem {
  /// A builder function that returns the localized label of the item.
  ///
  /// This is a function (instead of a simple String) to allow the label
  /// to be resolved using the [BuildContext], ensuring correct localization
  /// when the language changes or when the item is rendered.
  final String Function(BuildContext context) labelBuilder;

  /// The icon associated with this navigation item.
  final IconData icon;

  /// The named route to navigate to when this item is selected.
  ///
  /// - **Required** for simple items (leaves of the tree).
  /// - **Optional** for hierarchical items (parents with children).
  /// - **Null** means the item only groups children and has no route of its own.
  final String? route;

  /// The section this item belongs to.
  final AppNavigationSection? section;

  /// List of child items (submenu).
  ///
  /// - **Empty** (`[]`): Simple item without submenu.
  /// - **Not empty**: Hierarchical item with expandable submenu.
  ///
  /// Children can have their own children, creating infinite hierarchy.
  final List<AppNavigationItem> children;

  /// Whether the submenu should be expanded by default.
  ///
  /// - `true`: Submenu open when application loads.
  /// - `false`: Submenu closed (default).
  ///
  /// Only relevant if [children] is not empty.
  final bool defaultExpanded;

  const AppNavigationItem({
    required this.labelBuilder,
    required this.icon,
    this.route,
    this.section,
    this.children = const [],
    this.defaultExpanded = false,
  });

  /// Returns `true` if this item has children (is a parent item).
  bool get isParent => children.isNotEmpty;

  /// Returns `true` if this item has a navigation route.
  bool get hasRoute => route != null;

  /// Checks if any child in this hierarchy matches the [activeRoute].
  ///
  /// Searches recursively through all levels of children.
  bool hasActiveChild(String activeRoute) {
    for (final child in children) {
      if (child.route == activeRoute) return true;
      if (child.hasActiveChild(activeRoute)) return true;
    }
    return false;
  }
}
