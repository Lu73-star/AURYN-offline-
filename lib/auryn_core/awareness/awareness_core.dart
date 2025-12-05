// awareness_core.dart
// Core interface for awareness system in AURYN
// Defaults to be extended by submodules
// Compatible with Dart/Flutter 3.x

import 'context_manager.dart';
import 'short_term_memory.dart';
import 'episodic_memory.dart';
import 'personality_controller.dart';
import 'intent_filter.dart';
import 'voice_hooks.dart';

/// {@template awareness_core}
/// Central coordinator for all awareness-related modules.
/// Handles interaction between context, memory and personality.
///
/// This is the main entry point for the awareness layer.
/// It coordinates all submodules and provides a unified interface
/// for awareness-related operations.
///
/// **Privacy Note**: All memory recording is opt-in only.
/// No data is sent to external servers.
/// {@endtemplate}
abstract class AwarenessCore {
  /// Get the context manager instance
  ContextManager get contextManager;

  /// Get the short-term memory instance
  ShortTermMemory get shortTermMemory;

  /// Get the episodic memory instance (opt-in only)
  EpisodicMemory get episodicMemory;

  /// Get the personality controller instance
  PersonalityController get personalityController;

  /// Get the intent filter instance
  IntentFilter get intentFilter;

  /// Get the voice hooks instance
  VoiceHooks get voiceHooks;

  /// Initialize awareness system components
  /// Should be called once before using any awareness features
  void initialize();

  /// Update awareness state
  /// Called periodically to update internal state
  void update();

  /// Handle an intent with context
  /// [intentType] - The type of intent (e.g., 'speech', 'gesture')
  /// [data] - Additional data associated with the intent
  void handleIntent(String intentType, Map<String, dynamic> data);

  /// Dispose and clean up resources
  void dispose();
}

/// {@template awareness_core_impl}
/// Default implementation of [AwarenessCore]
/// Provides a working stub implementation for testing and development
/// {@endtemplate}
class AwarenessCoreImpl implements AwarenessCore {
  late final ContextManager _contextManager;
  late final ShortTermMemory _shortTermMemory;
  late final EpisodicMemory _episodicMemory;
  late final PersonalityController _personalityController;
  late final IntentFilter _intentFilter;
  late final VoiceHooks _voiceHooks;

  bool _initialized = false;

  @override
  ContextManager get contextManager => _contextManager;

  @override
  ShortTermMemory get shortTermMemory => _shortTermMemory;

  @override
  EpisodicMemory get episodicMemory => _episodicMemory;

  @override
  PersonalityController get personalityController => _personalityController;

  @override
  IntentFilter get intentFilter => _intentFilter;

  @override
  VoiceHooks get voiceHooks => _voiceHooks;

  @override
  void initialize() {
    if (_initialized) return;

    // Initialize all submodules
    _contextManager = ContextManagerImpl();
    _shortTermMemory = ShortTermMemoryImpl();
    _episodicMemory = EpisodicMemoryImpl();
    _personalityController = PersonalityControllerImpl();
    _intentFilter = IntentFilterImpl();
    _voiceHooks = VoiceHooksImpl();

    _initialized = true;
  }

  @override
  void update() {
    if (!_initialized) {
      throw StateError('AwarenessCore must be initialized before calling update()');
    }
    // TODO: Implement periodic state update logic
    // This will be used to sync state between modules
  }

  @override
  void handleIntent(String intentType, Map<String, dynamic> data) {
    if (!_initialized) {
      throw StateError('AwarenessCore must be initialized before handling intents');
    }

    // Classify and filter the intent
    final classified = _intentFilter.classifyIntent(intentType);

    // Update context with the new intent
    _contextManager.updateContext({
      'lastIntent': classified,
      'timestamp': DateTime.now().toIso8601String(),
    });

    // Store in short-term memory
    _shortTermMemory.storeItem({
      'intent': classified,
      'data': data,
      'timestamp': DateTime.now().toIso8601String(),
    });

    // TODO: Add more sophisticated intent handling logic
  }

  @override
  void dispose() {
    _initialized = false;
    // TODO: Clean up resources if needed
  }
}
