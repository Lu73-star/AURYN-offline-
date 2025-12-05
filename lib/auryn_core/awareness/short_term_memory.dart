// short_term_memory.dart
// Short-term memory module for awareness flow
// Compatible with Dart/Flutter 3.x

/// {@template short_term_memory}
/// Maintains short-term cache of interactions and events.
///
/// Short-term memory stores recent interactions and events
/// for quick access. Items are kept in memory only and
/// automatically expire after a certain period.
///
/// **Privacy Note**: STM data is volatile and stored in RAM only.
/// No persistent storage or external transmission.
/// {@endtemplate}
abstract class ShortTermMemory {
  /// Store an item in STM
  /// [item] - The item to store (must contain relevant data)
  void storeItem(Map<String, dynamic> item);

  /// Retrieve recent items
  /// [limit] - Maximum number of items to return (default: 10)
  /// Returns items in reverse chronological order (newest first)
  List<Map<String, dynamic>> getRecentItems({int limit = 10});

  /// Clear all items from STM
  void clear();

  /// Get total number of items in STM
  int get itemCount;
}

/// {@template short_term_memory_impl}
/// Default implementation of [ShortTermMemory]
/// Uses a simple list-based storage with FIFO eviction
/// {@endtemplate}
class ShortTermMemoryImpl implements ShortTermMemory {
  final List<Map<String, dynamic>> _items = [];
  static const int _maxItems = 100;

  @override
  void storeItem(Map<String, dynamic> item) {
    _items.add(item);

    // Evict oldest items if we exceed capacity
    if (_items.length > _maxItems) {
      _items.removeAt(0);
    }
  }

  @override
  List<Map<String, dynamic>> getRecentItems({int limit = 10}) {
    final count = limit.clamp(0, _items.length);
    // Return newest items first
    return _items.reversed.take(count).toList();
  }

  @override
  void clear() {
    _items.clear();
  }

  @override
  int get itemCount => _items.length;
}
