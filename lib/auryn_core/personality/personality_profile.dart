/// lib/auryn_core/personality/personality_profile.dart
/// Combine traits + emotional baseline + context, include modulateEmotion(EmotionState state).
/// 
/// PersonalityProfile is a comprehensive model that integrates personality traits,
/// emotional baseline, and contextual preferences to create a complete personality system.

import 'package:auryn_offline/auryn_core/emotion/emotion_state.dart';
import 'package:auryn_offline/auryn_core/personality/personality_traits.dart';
import 'package:auryn_offline/auryn_core/personality/dialog_style.dart';

/// Constants for emotion modulation thresholds
class _ModulationThresholds {
  static const double highNeuroticismThreshold = 0.6;
  static const double neuroticismAmplificationFactor = 2.5;
  static const double lowNeuroticismThreshold = 0.4;
  static const double highAgreeablenessThreshold = 0.7;
  static const double highExtraversionThreshold = 0.7;
  static const double lowExtraversionThreshold = 0.4;
}

class PersonalityProfile {
  /// Unique identifier for this profile
  final String id;

  /// Profile name (e.g., "Default AURYN", "Supportive Mode")
  final String name;

  /// Description of this personality profile
  final String description;

  /// Core personality traits
  final PersonalityTraits traits;

  /// Emotional baseline - default emotional state
  final EmotionState emotionalBaseline;

  /// Default dialog style
  final DialogStyle dialogStyle;

  /// Contextual preferences
  final Map<String, dynamic> contextPreferences;

  /// Timestamp of creation
  final DateTime createdAt;

  /// Timestamp of last modification
  final DateTime lastModified;

  PersonalityProfile({
    required this.id,
    required this.name,
    required this.description,
    required this.traits,
    required this.emotionalBaseline,
    required this.dialogStyle,
    this.contextPreferences = const {},
    DateTime? createdAt,
    DateTime? lastModified,
  })  : createdAt = createdAt ?? DateTime.now(),
        lastModified = lastModified ?? DateTime.now();

  /// Factory: create default AURYN personality profile
  factory PersonalityProfile.aurynDefault() {
    return PersonalityProfile(
      id: 'auryn_default',
      name: 'AURYN Default',
      description: 'The core AURYN personality: warm, thoughtful, present, and honest',
      traits: PersonalityTraits.aurynDefault(),
      emotionalBaseline: EmotionState(
        mood: 'calm',
        intensity: 1,
        valence: 1,
        arousal: 1,
      ),
      dialogStyle: DialogStyle.aurynDefault(),
      contextPreferences: {
        'default_interaction_type': 'casual',
        'prefer_depth': true,
        'prefer_honesty': true,
        'prefer_presence': true,
      },
    );
  }

  /// Factory: create supportive personality profile
  factory PersonalityProfile.supportive() {
    final baseTraits = PersonalityTraits.aurynDefault();
    return PersonalityProfile(
      id: 'supportive',
      name: 'Supportive Mode',
      description: 'Enhanced empathy and warmth for emotional support',
      traits: baseTraits.copyWith(
        agreeableness: 0.95,
        neuroticism: 0.25,
        assertiveness: 0.50,
      ),
      emotionalBaseline: EmotionState(
        mood: 'warm',
        intensity: 1,
        valence: 1,
        arousal: 1,
      ),
      dialogStyle: DialogStyle.aurynDefault().copyWith(
        warmth: 0.90,
        expressiveness: 0.70,
        verbosity: 0.65,
      ),
      contextPreferences: {
        'default_interaction_type': 'support',
        'prefer_validation': true,
        'prefer_gentle_pacing': true,
      },
    );
  }

  /// Factory: create analytical personality profile
  factory PersonalityProfile.analytical() {
    final baseTraits = PersonalityTraits.aurynDefault();
    return PersonalityProfile(
      id: 'analytical',
      name: 'Analytical Mode',
      description: 'Enhanced precision and intellectual depth',
      traits: baseTraits.copyWith(
        intellectualism: 0.90,
        conscientiousness: 0.85,
        openness: 0.85,
        agreeableness: 0.70,
      ),
      emotionalBaseline: EmotionState(
        mood: 'focused',
        intensity: 1,
        valence: 0,
        arousal: 2,
      ),
      dialogStyle: DialogStyle.aurynDefault().copyWith(
        precision: 0.85,
        verbosity: 0.75,
        formality: 0.60,
      ),
      contextPreferences: {
        'default_interaction_type': 'learning',
        'prefer_depth': true,
        'prefer_precision': true,
      },
    );
  }

  /// Factory: create from map (for deserialization)
  factory PersonalityProfile.fromMap(Map<String, dynamic> map) {
    return PersonalityProfile(
      id: map['id'] as String? ?? 'unknown',
      name: map['name'] as String? ?? 'Unknown Profile',
      description: map['description'] as String? ?? '',
      traits: PersonalityTraits.fromMap(
          map['traits'] as Map<String, dynamic>? ?? {}),
      emotionalBaseline: EmotionState.fromMap(
          map['emotionalBaseline'] as Map<String, dynamic>? ?? {}),
      dialogStyle: DialogStyle.fromMap(
          map['dialogStyle'] as Map<String, dynamic>? ?? {}),
      contextPreferences: Map<String, dynamic>.from(
          map['contextPreferences'] as Map<String, dynamic>? ?? {}),
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'] as String)
          : DateTime.now(),
      lastModified: map['lastModified'] != null
          ? DateTime.parse(map['lastModified'] as String)
          : DateTime.now(),
    );
  }

  /// Convert to map (for serialization)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'traits': traits.toMap(),
      'emotionalBaseline': emotionalBaseline.toMap(),
      'dialogStyle': dialogStyle.toMap(),
      'contextPreferences': contextPreferences,
      'createdAt': createdAt.toIso8601String(),
      'lastModified': lastModified.toIso8601String(),
    };
  }

  /// Create a copy with optionally altered values
  PersonalityProfile copyWith({
    String? id,
    String? name,
    String? description,
    PersonalityTraits? traits,
    EmotionState? emotionalBaseline,
    DialogStyle? dialogStyle,
    Map<String, dynamic>? contextPreferences,
    DateTime? lastModified,
  }) {
    return PersonalityProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      traits: traits ?? this.traits,
      emotionalBaseline: emotionalBaseline ?? this.emotionalBaseline,
      dialogStyle: dialogStyle ?? this.dialogStyle,
      contextPreferences: contextPreferences ?? this.contextPreferences,
      createdAt: createdAt,
      lastModified: lastModified ?? DateTime.now(),
    );
  }

  /// Modulate an emotion state based on this personality profile
  /// This allows the personality to influence emotional responses
  EmotionState modulateEmotion(EmotionState state) {
    // Personality traits influence how emotions are expressed/experienced
    
    // High neuroticism amplifies negative emotions
    if (state.isNegative && traits.neuroticism > _ModulationThresholds.highNeuroticismThreshold) {
      final amplification = ((traits.neuroticism - _ModulationThresholds.highNeuroticismThreshold) * 
          _ModulationThresholds.neuroticismAmplificationFactor).round();
      return state.copyWith(
        intensity: (state.intensity + amplification).clamp(0, 3),
      );
    }

    // Low neuroticism dampens extreme emotions
    if (traits.neuroticism < _ModulationThresholds.lowNeuroticismThreshold && state.intensity >= 2) {
      return state.copyWith(
        intensity: state.intensity - 1,
      );
    }

    // High agreeableness biases toward positive interpretations
    if (traits.agreeableness > _ModulationThresholds.highAgreeablenessThreshold && 
        state.valence == 0 && state.intensity <= 1) {
      return state.copyWith(valence: 1);
    }

    // High extraversion increases arousal
    if (traits.extraversion > _ModulationThresholds.highExtraversionThreshold && state.arousal < 2) {
      return state.copyWith(
        arousal: (state.arousal + 1).clamp(0, 3),
      );
    }

    // Low extraversion decreases arousal
    if (traits.extraversion < _ModulationThresholds.lowExtraversionThreshold && state.arousal > 1) {
      return state.copyWith(
        arousal: (state.arousal - 1).clamp(0, 3),
      );
    }

    // Return modulated state
    return state;
  }

  /// Adjust a specific trait and return updated profile
  PersonalityProfile adjustTrait(String traitName, double delta) {
    final newTraits = traits.adjustTrait(traitName, delta);
    return copyWith(
      traits: newTraits,
      lastModified: DateTime.now(),
    );
  }

  /// Update emotional baseline
  PersonalityProfile updateEmotionalBaseline(EmotionState newBaseline) {
    return copyWith(
      emotionalBaseline: newBaseline,
      lastModified: DateTime.now(),
    );
  }

  /// Update dialog style
  PersonalityProfile updateDialogStyle(DialogStyle newDialogStyle) {
    return copyWith(
      dialogStyle: newDialogStyle,
      lastModified: DateTime.now(),
    );
  }

  /// Get a contextual preference
  T? getPreference<T>(String key, {T? defaultValue}) {
    final value = contextPreferences[key];
    if (value is T) return value;
    return defaultValue;
  }

  /// Set a contextual preference
  PersonalityProfile setPreference(String key, dynamic value) {
    final newPreferences = Map<String, dynamic>.from(contextPreferences);
    newPreferences[key] = value;
    return copyWith(
      contextPreferences: newPreferences,
      lastModified: DateTime.now(),
    );
  }

  /// Calculate compatibility with another profile (0.0-1.0)
  double compatibilityWith(PersonalityProfile other) {
    // Trait similarity
    final traitSimilarity = traits.similarityTo(other.traits);
    
    // Emotional baseline similarity
    final emotionalSimilarity = _calculateEmotionalSimilarity(other);
    
    // Weighted average
    return (traitSimilarity * 0.7) + (emotionalSimilarity * 0.3);
  }

  /// Calculate emotional baseline similarity
  double _calculateEmotionalSimilarity(PersonalityProfile other) {
    final valenceDiff = (emotionalBaseline.valence - other.emotionalBaseline.valence).abs();
    final arousalDiff = (emotionalBaseline.arousal - other.emotionalBaseline.arousal).abs() / 3.0;
    final intensityDiff = (emotionalBaseline.intensity - other.emotionalBaseline.intensity).abs() / 3.0;
    
    final avgDiff = (valenceDiff / 2.0 + arousalDiff + intensityDiff) / 3.0;
    return 1.0 - avgDiff;
  }

  @override
  String toString() {
    return 'PersonalityProfile('
        'id: $id, '
        'name: $name, '
        'baseline: ${emotionalBaseline.mood}, '
        'agreeableness: ${traits.agreeableness.toStringAsFixed(2)})';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is PersonalityProfile && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
