/// lib/auryn_core/personality/personality_events.dart
/// Events: OnTraitAdjustment, OnProfileShift, OnBehaviorComputed.
/// 
/// PersonalityEvents provides a hook system for responding to personality-related
/// changes, enabling reactive integrations with other AURYN systems.

import 'package:auryn_offline/auryn_core/personality/personality_profile.dart';
import 'package:auryn_offline/auryn_core/personality/behavior_shaping.dart';

/// Event types
enum PersonalityEventType {
  traitAdjustment,
  profileShift,
  behaviorComputed,
}

/// Base class for personality events
abstract class PersonalityEvent {
  final PersonalityEventType type;
  final DateTime timestamp;

  PersonalityEvent(this.type) : timestamp = DateTime.now();
}

/// Event fired when a trait is adjusted
class OnTraitAdjustment extends PersonalityEvent {
  final String profileId;
  final String traitName;
  final double oldValue;
  final double newValue;
  final double delta;

  OnTraitAdjustment({
    required this.profileId,
    required this.traitName,
    required this.oldValue,
    required this.newValue,
    required this.delta,
  }) : super(PersonalityEventType.traitAdjustment);

  @override
  String toString() {
    return 'OnTraitAdjustment('
        'profile: $profileId, '
        'trait: $traitName, '
        '$oldValue → $newValue '
        '(${delta >= 0 ? "+" : ""}${delta.toStringAsFixed(2)}))';
  }
}

/// Event fired when personality profile is switched
class OnProfileShift extends PersonalityEvent {
  final PersonalityProfile? previousProfile;
  final PersonalityProfile newProfile;
  final String reason;

  OnProfileShift({
    required this.previousProfile,
    required this.newProfile,
    this.reason = 'manual',
  }) : super(PersonalityEventType.profileShift);

  @override
  String toString() {
    final prevName = previousProfile?.name ?? 'None';
    return 'OnProfileShift('
        '$prevName → ${newProfile.name}, '
        'reason: $reason)';
  }
}

/// Event fired when behavioral directive is computed
class OnBehaviorComputed extends PersonalityEvent {
  final BehavioralDirective directive;
  final String emotionMood;
  final String profileName;
  final String contextType;

  OnBehaviorComputed({
    required this.directive,
    required this.emotionMood,
    required this.profileName,
    required this.contextType,
  }) : super(PersonalityEventType.behaviorComputed);

  @override
  String toString() {
    return 'OnBehaviorComputed('
        'profile: $profileName, '
        'emotion: $emotionMood, '
        'context: $contextType, '
        'strategy: ${directive.responseStrategy})';
  }
}

/// Callback types
typedef TraitAdjustmentCallback = void Function(OnTraitAdjustment event);
typedef ProfileShiftCallback = void Function(OnProfileShift event);
typedef BehaviorComputedCallback = void Function(OnBehaviorComputed event);
typedef GeneralEventCallback = void Function(PersonalityEvent event);

/// Hook system for personality events
class PersonalityHooks {
  final List<TraitAdjustmentCallback> _traitCallbacks = [];
  final List<ProfileShiftCallback> _profileCallbacks = [];
  final List<BehaviorComputedCallback> _behaviorCallbacks = [];
  final List<GeneralEventCallback> _generalCallbacks = [];

  /// Register callback for trait adjustments
  void onTraitAdjustment(TraitAdjustmentCallback callback) {
    _traitCallbacks.add(callback);
  }

  /// Register callback for profile shifts
  void onProfileShift(ProfileShiftCallback callback) {
    _profileCallbacks.add(callback);
  }

  /// Register callback for behavior computation
  void onBehaviorComputed(BehaviorComputedCallback callback) {
    _behaviorCallbacks.add(callback);
  }

  /// Register callback for all events
  void onAnyEvent(GeneralEventCallback callback) {
    _generalCallbacks.add(callback);
  }

  /// Notify trait adjustment
  void notifyTraitAdjustment(OnTraitAdjustment event) {
    for (final callback in _traitCallbacks) {
      try {
        callback(event);
      } catch (e) {
        print('[PersonalityHooks] Error in trait callback: $e');
      }
    }
    _notifyGeneral(event);
  }

  /// Notify profile shift
  void notifyProfileShift(OnProfileShift event) {
    for (final callback in _profileCallbacks) {
      try {
        callback(event);
      } catch (e) {
        print('[PersonalityHooks] Error in profile callback: $e');
      }
    }
    _notifyGeneral(event);
  }

  /// Notify behavior computed
  void notifyBehaviorComputed(OnBehaviorComputed event) {
    for (final callback in _behaviorCallbacks) {
      try {
        callback(event);
      } catch (e) {
        print('[PersonalityHooks] Error in behavior callback: $e');
      }
    }
    _notifyGeneral(event);
  }

  /// Notify all general callbacks
  void _notifyGeneral(PersonalityEvent event) {
    for (final callback in _generalCallbacks) {
      try {
        callback(event);
      } catch (e) {
        print('[PersonalityHooks] Error in general callback: $e');
      }
    }
  }

  /// Clear all callbacks
  void clearAllCallbacks() {
    _traitCallbacks.clear();
    _profileCallbacks.clear();
    _behaviorCallbacks.clear();
    _generalCallbacks.clear();
  }

  /// Get callback counts
  Map<String, int> get callbackCounts => {
        'trait': _traitCallbacks.length,
        'profile': _profileCallbacks.length,
        'behavior': _behaviorCallbacks.length,
        'general': _generalCallbacks.length,
      };
}

/// Preset hooks for common use cases
class PersonalityHookPresets {
  /// Logging hook for trait adjustments
  static void loggingTraitHook(OnTraitAdjustment event) {
    print('[Personality] $event');
  }

  /// Logging hook for profile shifts
  static void loggingProfileHook(OnProfileShift event) {
    print('[Personality] $event');
  }

  /// Logging hook for behavior computation
  static void loggingBehaviorHook(OnBehaviorComputed event) {
    print('[Personality] $event');
  }

  /// Logging hook for all events
  static void loggingHook(PersonalityEvent event) {
    print('[Personality] ${event.runtimeType}: $event');
  }

  /// Debug hook that prints detailed information
  static void debugHook(PersonalityEvent event) {
    print('═══ Personality Event ═══');
    print('Type: ${event.type}');
    print('Time: ${event.timestamp}');
    print('Details: $event');
    print('═════════════════════════');
  }
}
