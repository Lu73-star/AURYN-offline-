// awareness.dart
// Barrel export file for AURYN awareness layer
// Compatible with Dart/Flutter 3.x

/// AURYN Awareness Layer
///
/// This module provides the awareness system for AURYN,
/// including context management, memory systems, personality
/// control, and intent processing.
///
/// ## Privacy & Data Protection
///
/// - All processing is performed locally
/// - No data is transmitted to external servers
/// - Episodic memory recording requires explicit opt-in
/// - Users have full control over their data
///
/// ## Usage Example
///
/// ```dart
/// import 'package:auryn_offline/auryn_core/awareness/awareness.dart';
///
/// final awareness = AwarenessCoreImpl();
/// awareness.initialize();
///
/// // Get current context
/// final context = awareness.contextManager.getCurrentContext();
///
/// // Handle an intent
/// awareness.handleIntent('voice_input', {'text': 'Hello'});
///
/// // Access short-term memory
/// final recentItems = awareness.shortTermMemory.getRecentItems(limit: 5);
/// ```
///
/// ## Module Structure
///
/// - [AwarenessCore] - Main coordinator
/// - [ContextManager] - Context state management
/// - [ShortTermMemory] - Volatile recent memory
/// - [EpisodicMemory] - Persistent memory (opt-in)
/// - [PersonalityController] - Personality traits
/// - [IntentFilter] - Intent classification
/// - [VoiceHooks] - Voice interaction events

library awareness;

export 'awareness_core.dart';
export 'context_manager.dart';
export 'short_term_memory.dart';
export 'episodic_memory.dart';
export 'personality_controller.dart';
export 'intent_filter.dart';
export 'voice_hooks.dart';
