/// lib/auryn_core/personality/behavior_shaping.dart
/// Map (Emotion + Personality + Context) → BehavioralDirective.
/// 
/// BehaviorShaping combines emotional state, personality traits, and context
/// to determine how AURYN should behave in a given situation.

import 'package:auryn_offline/auryn_core/emotion/emotion_state.dart';
import 'package:auryn_offline/auryn_core/personality/personality_traits.dart';
import 'package:auryn_offline/auryn_core/personality/dialog_style.dart';

/// Context information for behavioral decisions
class BehaviorContext {
  /// Type of interaction (e.g., 'casual', 'support', 'learning', 'reflection')
  final String interactionType;

  /// User's apparent energy level (0.0-1.0)
  final double userEnergy;

  /// Urgency level (0.0-1.0)
  final double urgency;

  /// Complexity of topic (0.0-1.0)
  final double topicComplexity;

  /// Additional contextual metadata
  final Map<String, dynamic> metadata;

  BehaviorContext({
    required this.interactionType,
    this.userEnergy = 0.5,
    this.urgency = 0.5,
    this.topicComplexity = 0.5,
    this.metadata = const {},
  });

  factory BehaviorContext.casual() {
    return BehaviorContext(
      interactionType: 'casual',
      userEnergy: 0.6,
      urgency: 0.3,
      topicComplexity: 0.4,
    );
  }

  factory BehaviorContext.support() {
    return BehaviorContext(
      interactionType: 'support',
      userEnergy: 0.4,
      urgency: 0.6,
      topicComplexity: 0.5,
    );
  }

  factory BehaviorContext.learning() {
    return BehaviorContext(
      interactionType: 'learning',
      userEnergy: 0.6,
      urgency: 0.4,
      topicComplexity: 0.7,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'interactionType': interactionType,
      'userEnergy': userEnergy,
      'urgency': urgency,
      'topicComplexity': topicComplexity,
      'metadata': metadata,
    };
  }
}

/// Behavioral directive that guides AURYN's response
class BehavioralDirective {
  /// Recommended dialog style
  final DialogStyle dialogStyle;

  /// Tone indicators (e.g., 'supportive', 'curious', 'reflective')
  final List<String> toneIndicators;

  /// Pacing recommendation
  final String pacing; // 'slow', 'moderate', 'fast'

  /// Response strategy (e.g., 'elaborate', 'concise', 'questioning')
  final String responseStrategy;

  /// Emotional engagement level (0.0-1.0)
  final double emotionalEngagement;

  /// Recommended response length factor (multiplier)
  final double lengthFactor;

  /// Should include emotional acknowledgment?
  final bool acknowledgeEmotion;

  /// Priority aspects to address
  final List<String> priorityAspects;

  BehavioralDirective({
    required this.dialogStyle,
    required this.toneIndicators,
    required this.pacing,
    required this.responseStrategy,
    this.emotionalEngagement = 0.5,
    this.lengthFactor = 1.0,
    this.acknowledgeEmotion = false,
    this.priorityAspects = const [],
  });

  Map<String, dynamic> toMap() {
    return {
      'dialogStyle': dialogStyle.toMap(),
      'toneIndicators': toneIndicators,
      'pacing': pacing,
      'responseStrategy': responseStrategy,
      'emotionalEngagement': emotionalEngagement,
      'lengthFactor': lengthFactor,
      'acknowledgeEmotion': acknowledgeEmotion,
      'priorityAspects': priorityAspects,
    };
  }

  @override
  String toString() {
    return 'BehavioralDirective('
        'pacing: $pacing, '
        'strategy: $responseStrategy, '
        'tones: ${toneIndicators.join(", ")}, '
        'engagement: ${emotionalEngagement.toStringAsFixed(2)})';
  }
}

/// Shapes behavior based on emotion, personality, and context
class BehaviorShaping {
  /// Compute behavioral directive from inputs
  static BehavioralDirective computeDirective({
    required EmotionState emotionState,
    required PersonalityTraits traits,
    required BehaviorContext context,
  }) {
    // Start with base dialog style adjusted for personality
    DialogStyle dialogStyle = _computeBaseDialogStyle(traits);

    // Adjust for emotional state
    dialogStyle = dialogStyle.adjustForMood(emotionState.mood);
    dialogStyle = dialogStyle.adjustForIntensity(emotionState.intensity);

    // Determine tone indicators
    final toneIndicators = _computeToneIndicators(
      emotionState: emotionState,
      traits: traits,
      context: context,
    );

    // Determine pacing
    final pacing = _computePacing(
      emotionState: emotionState,
      traits: traits,
      context: context,
    );

    // Determine response strategy
    final responseStrategy = _computeResponseStrategy(
      emotionState: emotionState,
      traits: traits,
      context: context,
    );

    // Calculate emotional engagement
    final emotionalEngagement = _computeEmotionalEngagement(
      emotionState: emotionState,
      traits: traits,
      context: context,
    );

    // Calculate length factor
    final lengthFactor = _computeLengthFactor(
      traits: traits,
      context: context,
    );

    // Determine if emotion should be acknowledged
    final acknowledgeEmotion = emotionState.intensity >= 2 ||
        (emotionState.isNegative && context.interactionType == 'support');

    // Determine priority aspects
    final priorityAspects = _computePriorityAspects(
      emotionState: emotionState,
      context: context,
    );

    return BehavioralDirective(
      dialogStyle: dialogStyle,
      toneIndicators: toneIndicators,
      pacing: pacing,
      responseStrategy: responseStrategy,
      emotionalEngagement: emotionalEngagement,
      lengthFactor: lengthFactor,
      acknowledgeEmotion: acknowledgeEmotion,
      priorityAspects: priorityAspects,
    );
  }

  /// Compute base dialog style from personality traits
  static DialogStyle _computeBaseDialogStyle(PersonalityTraits traits) {
    return DialogStyle(
      warmth: traits.agreeableness * 0.7 + traits.extraversion * 0.3,
      precision: traits.conscientiousness * 0.6 + traits.intellectualism * 0.4,
      cadence: traits.extraversion * 0.5 + (1.0 - traits.neuroticism) * 0.3,
      expressiveness: traits.extraversion * 0.4 + traits.playfulness * 0.4 +
          traits.openness * 0.2,
      formality: traits.conscientiousness * 0.5 + (1.0 - traits.playfulness) * 0.3,
      verbosity: traits.intellectualism * 0.5 + traits.conscientiousness * 0.3,
    );
  }

  /// Compute tone indicators
  static List<String> _computeToneIndicators({
    required EmotionState emotionState,
    required PersonalityTraits traits,
    required BehaviorContext context,
  }) {
    final tones = <String>[];

    // Emotion-based tones
    if (emotionState.isPositive) {
      if (traits.playfulness > 0.6) tones.add('playful');
      if (traits.agreeableness > 0.7) tones.add('warm');
    } else if (emotionState.isNegative) {
      if (traits.agreeableness > 0.7) tones.add('supportive');
      if (traits.intellectualism > 0.6) tones.add('understanding');
    }

    // Context-based tones
    if (context.interactionType == 'support') {
      tones.add('compassionate');
      if (traits.agreeableness > 0.8) tones.add('reassuring');
    } else if (context.interactionType == 'learning') {
      tones.add('instructive');
      if (traits.intellectualism > 0.7) tones.add('thoughtful');
    }

    // Personality-based tones
    if (traits.openness > 0.7) tones.add('curious');
    if (traits.intellectualism > 0.75) tones.add('reflective');
    if (traits.assertiveness > 0.7) tones.add('direct');

    // Ensure at least one tone
    if (tones.isEmpty) tones.add('balanced');

    return tones.take(3).toList(); // Limit to top 3
  }

  /// Compute pacing
  static String _computePacing({
    required EmotionState emotionState,
    required PersonalityTraits traits,
    required BehaviorContext context,
  }) {
    // Calculate pacing score
    double pacingScore = traits.extraversion * 0.4;
    pacingScore += context.urgency * 0.3;
    pacingScore += (emotionState.arousal / 3.0) * 0.3;

    if (pacingScore < 0.35) return 'slow';
    if (pacingScore < 0.65) return 'moderate';
    return 'fast';
  }

  /// Compute response strategy
  static String _computeResponseStrategy({
    required EmotionState emotionState,
    required PersonalityTraits traits,
    required BehaviorContext context,
  }) {
    // Support contexts need different strategies
    if (context.interactionType == 'support' && emotionState.isNegative) {
      return traits.agreeableness > 0.7 ? 'empathetic' : 'practical';
    }

    // Learning contexts
    if (context.interactionType == 'learning') {
      if (context.topicComplexity > 0.6) {
        return traits.intellectualism > 0.7 ? 'elaborate' : 'structured';
      }
      return 'concise';
    }

    // Default strategy based on traits
    if (traits.intellectualism > 0.7 && context.topicComplexity > 0.5) {
      return 'elaborate';
    }
    if (traits.openness > 0.7) {
      return 'questioning';
    }
    if (traits.conscientiousness > 0.7) {
      return 'structured';
    }

    return 'balanced';
  }

  /// Compute emotional engagement level
  static double _computeEmotionalEngagement({
    required EmotionState emotionState,
    required PersonalityTraits traits,
    required BehaviorContext context,
  }) {
    double engagement = traits.agreeableness * 0.4;
    engagement += traits.extraversion * 0.2;
    engagement += (emotionState.intensity / 3.0) * 0.3;
    engagement += (context.interactionType == 'support' ? 0.1 : 0.0);

    return engagement.clamp(0.0, 1.0);
  }

  /// Compute length factor
  static double _computeLengthFactor({
    required PersonalityTraits traits,
    required BehaviorContext context,
  }) {
    double factor = 1.0;
    
    // Adjust for verbosity traits
    factor *= (0.7 + (traits.intellectualism * 0.6));
    factor *= (0.8 + (traits.conscientiousness * 0.4));
    
    // Adjust for context
    factor *= (0.8 + (context.topicComplexity * 0.4));
    
    // Urgency reduces length
    if (context.urgency > 0.7) {
      factor *= 0.7;
    }

    return factor.clamp(0.5, 1.5);
  }

  /// Compute priority aspects
  static List<String> _computePriorityAspects({
    required EmotionState emotionState,
    required BehaviorContext context,
  }) {
    final priorities = <String>[];

    // Emotional priorities
    if (emotionState.isNegative && emotionState.intensity >= 2) {
      priorities.add('emotional_support');
    }

    // Context priorities
    if (context.urgency > 0.7) {
      priorities.add('direct_answer');
    }
    if (context.topicComplexity > 0.7) {
      priorities.add('clarity');
    }

    // Interaction type priorities
    switch (context.interactionType) {
      case 'support':
        priorities.add('validation');
        break;
      case 'learning':
        priorities.add('education');
        break;
      case 'reflection':
        priorities.add('depth');
        break;
    }

    return priorities;
  }
}
