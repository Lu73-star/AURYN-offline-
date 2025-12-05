// context_manager.dart
// Context management for AURYN awareness system
// Compatible with Dart/Flutter 3.x

/// {@template context_manager}
/// Manages dynamic context information for awareness modules.
///
/// The context manager maintains a snapshot of the current state
/// including user preferences, environment conditions, and
/// interaction history.
///
/// **Privacy Note**: Context data is stored locally only.
/// No external transmission occurs.
/// {@endtemplate}
abstract class ContextManager {
  /// Get current context snapshot
  /// Returns a copy of the current context state
  Map<String, dynamic> getCurrentContext();

  /// Update context information
  /// [changes] - Key-value pairs to merge into current context
  void updateContext(Map<String, dynamic> changes);

  /// Clear all context data
  void clearContext();

  /// Get a specific context value
  /// Returns null if key doesn't exist
  dynamic getContextValue(String key);
}

/// {@template context_manager_impl}
/// Default implementation of [ContextManager]
/// Stores context in memory with basic CRUD operations
/// {@endtemplate}
class ContextManagerImpl implements ContextManager {
  final Map<String, dynamic> _context = {};

  @override
  Map<String, dynamic> getCurrentContext() {
    // Return a copy to prevent external modifications
    return Map<String, dynamic>.from(_context);
  }

  @override
  void updateContext(Map<String, dynamic> changes) {
    _context.addAll(changes);
  }

  @override
  void clearContext() {
    _context.clear();
  }

  @override
  dynamic getContextValue(String key) {
    return _context[key];
  }
}
