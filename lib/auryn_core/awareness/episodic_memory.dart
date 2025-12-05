// episodic_memory.dart
// Episodic memory for storing sequences of experiences
// Compatible with Dart/Flutter 3.x

/// {@template episodic_memory}
/// Stores and retrieves sequences of experiences/events.
/// {@endtemplate}
abstract class EpisodicMemory {
  /// Add a new episode
  void addEpisode(Map<String, dynamic> episode); // TODO: Implement episodic memory addition

  /// Retrieve episodes by criteria
  List<Map<String, dynamic>> getEpisodes({Map<String, dynamic>? criteria}); // TODO: Implement retrieval by filter
}
