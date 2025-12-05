/// lib/auryn_core/personality/personality_traits.dart
/// Define traits, ranges, and normalization for AURYN's personality system.
/// 
/// PersonalityTraits represents the fundamental characteristics that define
/// how AURYN behaves, responds, and interacts. Each trait is normalized
/// to a 0.0-1.0 scale for consistent processing.

class PersonalityTraits {
  /// Openness: curiosity, creativity, willingness to explore
  /// 0.0 = conservative, cautious | 1.0 = highly curious, creative
  final double openness;

  /// Conscientiousness: organization, reliability, attention to detail
  /// 0.0 = spontaneous, flexible | 1.0 = methodical, precise
  final double conscientiousness;

  /// Extraversion: energy in social interaction, expressiveness
  /// 0.0 = reserved, introspective | 1.0 = outgoing, expressive
  final double extraversion;

  /// Agreeableness: empathy, cooperation, kindness
  /// 0.0 = analytical, direct | 1.0 = warm, supportive
  final double agreeableness;

  /// Neuroticism: emotional stability, stress response
  /// 0.0 = calm, stable | 1.0 = sensitive, reactive
  final double neuroticism;

  /// Assertiveness: confidence in expressing opinions
  /// 0.0 = gentle, accommodating | 1.0 = direct, assertive
  final double assertiveness;

  /// Playfulness: humor, lightness in interaction
  /// 0.0 = serious, formal | 1.0 = playful, humorous
  final double playfulness;

  /// Intellectualism: depth of reasoning, abstract thinking
  /// 0.0 = practical, concrete | 1.0 = philosophical, abstract
  final double intellectualism;

  PersonalityTraits({
    required this.openness,
    required this.conscientiousness,
    required this.extraversion,
    required this.agreeableness,
    required this.neuroticism,
    required this.assertiveness,
    required this.playfulness,
    required this.intellectualism,
  })  : assert(openness >= 0.0 && openness <= 1.0, 'Openness must be 0.0-1.0'),
        assert(conscientiousness >= 0.0 && conscientiousness <= 1.0,
            'Conscientiousness must be 0.0-1.0'),
        assert(extraversion >= 0.0 && extraversion <= 1.0,
            'Extraversion must be 0.0-1.0'),
        assert(agreeableness >= 0.0 && agreeableness <= 1.0,
            'Agreeableness must be 0.0-1.0'),
        assert(neuroticism >= 0.0 && neuroticism <= 1.0,
            'Neuroticism must be 0.0-1.0'),
        assert(assertiveness >= 0.0 && assertiveness <= 1.0,
            'Assertiveness must be 0.0-1.0'),
        assert(playfulness >= 0.0 && playfulness <= 1.0,
            'Playfulness must be 0.0-1.0'),
        assert(intellectualism >= 0.0 && intellectualism <= 1.0,
            'Intellectualism must be 0.0-1.0');

  /// Factory: default AURYN personality traits
  /// Based on AURYN's core identity: calm, present, deep, honest, supportive
  factory PersonalityTraits.aurynDefault() {
    return PersonalityTraits(
      openness: 0.75, // Curious and explorative
      conscientiousness: 0.70, // Reliable and thoughtful
      extraversion: 0.55, // Balanced presence
      agreeableness: 0.85, // Warm and supportive
      neuroticism: 0.30, // Calm and stable
      assertiveness: 0.60, // Honest but gentle
      playfulness: 0.45, // Serious with moments of lightness
      intellectualism: 0.80, // Deep and philosophical
    );
  }

  /// Factory: create from map (for deserialization)
  factory PersonalityTraits.fromMap(Map<String, dynamic> map) {
    return PersonalityTraits(
      openness: _normalizeValue(map['openness']),
      conscientiousness: _normalizeValue(map['conscientiousness']),
      extraversion: _normalizeValue(map['extraversion']),
      agreeableness: _normalizeValue(map['agreeableness']),
      neuroticism: _normalizeValue(map['neuroticism']),
      assertiveness: _normalizeValue(map['assertiveness']),
      playfulness: _normalizeValue(map['playfulness']),
      intellectualism: _normalizeValue(map['intellectualism']),
    );
  }

  /// Normalize a value to 0.0-1.0 range
  static double _normalizeValue(dynamic value) {
    if (value == null) return 0.5; // Default to neutral
    
    if (value is double) {
      return value.clamp(0.0, 1.0);
    } else if (value is int) {
      return (value.toDouble()).clamp(0.0, 1.0);
    } else if (value is String) {
      final parsed = double.tryParse(value);
      return (parsed ?? 0.5).clamp(0.0, 1.0);
    }
    
    return 0.5; // Default to neutral
  }

  /// Convert to map (for serialization)
  Map<String, dynamic> toMap() {
    return {
      'openness': openness,
      'conscientiousness': conscientiousness,
      'extraversion': extraversion,
      'agreeableness': agreeableness,
      'neuroticism': neuroticism,
      'assertiveness': assertiveness,
      'playfulness': playfulness,
      'intellectualism': intellectualism,
    };
  }

  /// Create a copy with optionally altered values
  PersonalityTraits copyWith({
    double? openness,
    double? conscientiousness,
    double? extraversion,
    double? agreeableness,
    double? neuroticism,
    double? assertiveness,
    double? playfulness,
    double? intellectualism,
  }) {
    return PersonalityTraits(
      openness: openness ?? this.openness,
      conscientiousness: conscientiousness ?? this.conscientiousness,
      extraversion: extraversion ?? this.extraversion,
      agreeableness: agreeableness ?? this.agreeableness,
      neuroticism: neuroticism ?? this.neuroticism,
      assertiveness: assertiveness ?? this.assertiveness,
      playfulness: playfulness ?? this.playfulness,
      intellectualism: intellectualism ?? this.intellectualism,
    );
  }

  /// Adjust a single trait by delta (clamped to valid range)
  PersonalityTraits adjustTrait(String traitName, double delta) {
    switch (traitName.toLowerCase()) {
      case 'openness':
        return copyWith(openness: (openness + delta).clamp(0.0, 1.0));
      case 'conscientiousness':
        return copyWith(
            conscientiousness: (conscientiousness + delta).clamp(0.0, 1.0));
      case 'extraversion':
        return copyWith(extraversion: (extraversion + delta).clamp(0.0, 1.0));
      case 'agreeableness':
        return copyWith(agreeableness: (agreeableness + delta).clamp(0.0, 1.0));
      case 'neuroticism':
        return copyWith(neuroticism: (neuroticism + delta).clamp(0.0, 1.0));
      case 'assertiveness':
        return copyWith(assertiveness: (assertiveness + delta).clamp(0.0, 1.0));
      case 'playfulness':
        return copyWith(playfulness: (playfulness + delta).clamp(0.0, 1.0));
      case 'intellectualism':
        return copyWith(
            intellectualism: (intellectualism + delta).clamp(0.0, 1.0));
      default:
        throw ArgumentError('Unknown trait: $traitName');
    }
  }

  /// Get trait value by name
  double getTrait(String traitName) {
    switch (traitName.toLowerCase()) {
      case 'openness':
        return openness;
      case 'conscientiousness':
        return conscientiousness;
      case 'extraversion':
        return extraversion;
      case 'agreeableness':
        return agreeableness;
      case 'neuroticism':
        return neuroticism;
      case 'assertiveness':
        return assertiveness;
      case 'playfulness':
        return playfulness;
      case 'intellectualism':
        return intellectualism;
      default:
        throw ArgumentError('Unknown trait: $traitName');
    }
  }

  /// Get all trait names
  static List<String> get traitNames => [
        'openness',
        'conscientiousness',
        'extraversion',
        'agreeableness',
        'neuroticism',
        'assertiveness',
        'playfulness',
        'intellectualism',
      ];

  /// Calculate similarity to another trait set (0.0-1.0)
  double similarityTo(PersonalityTraits other) {
    final diffs = [
      (openness - other.openness).abs(),
      (conscientiousness - other.conscientiousness).abs(),
      (extraversion - other.extraversion).abs(),
      (agreeableness - other.agreeableness).abs(),
      (neuroticism - other.neuroticism).abs(),
      (assertiveness - other.assertiveness).abs(),
      (playfulness - other.playfulness).abs(),
      (intellectualism - other.intellectualism).abs(),
    ];

    final avgDiff = diffs.reduce((a, b) => a + b) / diffs.length;
    return 1.0 - avgDiff; // Convert difference to similarity
  }

  @override
  String toString() {
    return 'PersonalityTraits('
        'openness: ${openness.toStringAsFixed(2)}, '
        'conscientiousness: ${conscientiousness.toStringAsFixed(2)}, '
        'extraversion: ${extraversion.toStringAsFixed(2)}, '
        'agreeableness: ${agreeableness.toStringAsFixed(2)}, '
        'neuroticism: ${neuroticism.toStringAsFixed(2)}, '
        'assertiveness: ${assertiveness.toStringAsFixed(2)}, '
        'playfulness: ${playfulness.toStringAsFixed(2)}, '
        'intellectualism: ${intellectualism.toStringAsFixed(2)})';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is PersonalityTraits &&
        other.openness == openness &&
        other.conscientiousness == conscientiousness &&
        other.extraversion == extraversion &&
        other.agreeableness == agreeableness &&
        other.neuroticism == neuroticism &&
        other.assertiveness == assertiveness &&
        other.playfulness == playfulness &&
        other.intellectualism == intellectualism;
  }

  @override
  int get hashCode {
    return openness.hashCode ^
        conscientiousness.hashCode ^
        extraversion.hashCode ^
        agreeableness.hashCode ^
        neuroticism.hashCode ^
        assertiveness.hashCode ^
        playfulness.hashCode ^
        intellectualism.hashCode;
  }
}
