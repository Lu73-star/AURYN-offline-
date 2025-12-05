// short_term_memory.dart
// Short-term memory module for awareness flow
// Compatible with Dart/Flutter 3.x

/// {@template short_term_memory}
/// Maintains short-term cache of interactions and events.
/// {@endtemplate}
abstract class ShortTermMemory {
  /// Store an item in STM
  void storeItem(Map<String, dynamic> item); // TODO: Implement STM storage

  /// Retrieve recent items
  List<Map<String, dynamic>> getRecentItems({int limit = 10}); // TODO: Return latest STM items
}
