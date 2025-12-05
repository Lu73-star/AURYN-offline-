// episodic_memory.dart
// Episodic memory for storing sequences of experiences
// Compatible with Dart/Flutter 3.x

/// {@template episodic_memory}
/// Stores and retrieves sequences of experiences/events.
///
/// Episodic memory maintains a record of past interactions
/// and events for learning and context building.
///
/// **PRIVACY & OPT-IN REQUIREMENT**:
/// - Episodic memory recording is OPT-IN ONLY
/// - User must explicitly enable this feature
/// - All data is stored locally only
/// - No external transmission under any circumstances
/// - User can clear episodic memory at any time
///
/// Before using episodic memory in production:
/// 1. Obtain explicit user consent
/// 2. Inform users about what is being recorded
/// 3. Provide clear controls to disable/clear recordings
/// 4. Document data retention policies
/// {@endtemplate}
abstract class EpisodicMemory {
  /// Check if episodic memory is enabled (opt-in status)
  bool get isEnabled;

  /// Enable episodic memory recording (requires user consent)
  void enable();

  /// Disable episodic memory recording
  void disable();

  /// Add a new episode
  /// Only records if [isEnabled] is true
  /// [episode] - The episode data to store
  void addEpisode(Map<String, dynamic> episode);

  /// Retrieve episodes by criteria
  /// [criteria] - Optional filter criteria for episodes
  /// Returns matching episodes in chronological order
  List<Map<String, dynamic>> getEpisodes({Map<String, dynamic>? criteria});

  /// Clear all stored episodes
  /// User should be able to invoke this at any time
  void clearAllEpisodes();

  /// Get total number of stored episodes
  int get episodeCount;
}

/// {@template episodic_memory_impl}
/// Default implementation of [EpisodicMemory]
/// Stores episodes in memory with opt-in protection
/// {@endtemplate}
class EpisodicMemoryImpl implements EpisodicMemory {
  final List<Map<String, dynamic>> _episodes = [];
  bool _enabled = false; // Default to disabled (opt-in)

  @override
  bool get isEnabled => _enabled;

  @override
  void enable() {
    _enabled = true;
  }

  @override
  void disable() {
    _enabled = false;
  }

  @override
  void addEpisode(Map<String, dynamic> episode) {
    if (!_enabled) {
      // Silently ignore if not enabled - respect opt-in
      return;
    }

    final enrichedEpisode = {
      ...episode,
      'recordedAt': DateTime.now().toIso8601String(),
    };
    _episodes.add(enrichedEpisode);
  }

  @override
  List<Map<String, dynamic>> getEpisodes({Map<String, dynamic>? criteria}) {
    if (criteria == null || criteria.isEmpty) {
      return List.from(_episodes);
    }

    // Simple filtering by matching criteria keys
    return _episodes.where((episode) {
      return criteria.entries.every((criterion) {
        return episode[criterion.key] == criterion.value;
      });
    }).toList();
  }

  @override
  void clearAllEpisodes() {
    _episodes.clear();
  }

  @override
  int get episodeCount => _episodes.length;
}
