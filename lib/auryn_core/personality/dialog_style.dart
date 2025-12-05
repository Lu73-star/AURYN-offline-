/// lib/auryn_core/personality/dialog_style.dart
/// Define warmth, precision, cadence, and expressiveness for AURYN's dialog.
/// 
/// DialogStyle determines how AURYN communicates: the emotional tone,
/// level of detail, pacing, and expressive qualities of responses.

class DialogStyle {
  /// Warmth: emotional temperature of responses
  /// 0.0 = clinical, detached | 1.0 = warm, emotionally present
  final double warmth;

  /// Precision: level of detail and exactness
  /// 0.0 = general, approximate | 1.0 = detailed, precise
  final double precision;

  /// Cadence: pacing and rhythm of speech
  /// 0.0 = slow, deliberate | 1.0 = fast, energetic
  final double cadence;

  /// Expressiveness: use of emotional language and modifiers
  /// 0.0 = neutral, factual | 1.0 = expressive, colorful
  final double expressiveness;

  /// Formality: level of formal language use
  /// 0.0 = casual, informal | 1.0 = formal, professional
  final double formality;

  /// Verbosity: length and elaboration of responses
  /// 0.0 = concise, brief | 1.0 = elaborate, detailed
  final double verbosity;

  DialogStyle({
    required this.warmth,
    required this.precision,
    required this.cadence,
    required this.expressiveness,
    required this.formality,
    required this.verbosity,
  })  : assert(warmth >= 0.0 && warmth <= 1.0, 'Warmth must be 0.0-1.0'),
        assert(precision >= 0.0 && precision <= 1.0, 'Precision must be 0.0-1.0'),
        assert(cadence >= 0.0 && cadence <= 1.0, 'Cadence must be 0.0-1.0'),
        assert(expressiveness >= 0.0 && expressiveness <= 1.0,
            'Expressiveness must be 0.0-1.0'),
        assert(formality >= 0.0 && formality <= 1.0, 'Formality must be 0.0-1.0'),
        assert(verbosity >= 0.0 && verbosity <= 1.0, 'Verbosity must be 0.0-1.0');

  /// Factory: neutral/balanced dialog style
  factory DialogStyle.neutral() {
    return DialogStyle(
      warmth: 0.5,
      precision: 0.5,
      cadence: 0.5,
      expressiveness: 0.5,
      formality: 0.5,
      verbosity: 0.5,
    );
  }

  /// Factory: AURYN's default dialog style
  /// Warm, present, thoughtful, with moderate expressiveness
  factory DialogStyle.aurynDefault() {
    return DialogStyle(
      warmth: 0.75, // Warm and supportive
      precision: 0.65, // Thoughtful and accurate
      cadence: 0.50, // Calm, measured pace
      expressiveness: 0.60, // Emotionally present but not excessive
      formality: 0.40, // Friendly, approachable
      verbosity: 0.60, // Informative without being wordy
    );
  }

  /// Factory: create from map (for deserialization)
  factory DialogStyle.fromMap(Map<String, dynamic> map) {
    return DialogStyle(
      warmth: _normalizeValue(map['warmth']),
      precision: _normalizeValue(map['precision']),
      cadence: _normalizeValue(map['cadence']),
      expressiveness: _normalizeValue(map['expressiveness']),
      formality: _normalizeValue(map['formality']),
      verbosity: _normalizeValue(map['verbosity']),
    );
  }

  /// Normalize a value to 0.0-1.0 range
  static double _normalizeValue(dynamic value) {
    if (value == null) return 0.5;
    
    if (value is double) {
      return value.clamp(0.0, 1.0);
    } else if (value is int) {
      return (value.toDouble()).clamp(0.0, 1.0);
    } else if (value is String) {
      final parsed = double.tryParse(value);
      return (parsed ?? 0.5).clamp(0.0, 1.0);
    }
    
    return 0.5;
  }

  /// Convert to map (for serialization)
  Map<String, dynamic> toMap() {
    return {
      'warmth': warmth,
      'precision': precision,
      'cadence': cadence,
      'expressiveness': expressiveness,
      'formality': formality,
      'verbosity': verbosity,
    };
  }

  /// Create a copy with optionally altered values
  DialogStyle copyWith({
    double? warmth,
    double? precision,
    double? cadence,
    double? expressiveness,
    double? formality,
    double? verbosity,
  }) {
    return DialogStyle(
      warmth: warmth ?? this.warmth,
      precision: precision ?? this.precision,
      cadence: cadence ?? this.cadence,
      expressiveness: expressiveness ?? this.expressiveness,
      formality: formality ?? this.formality,
      verbosity: verbosity ?? this.verbosity,
    );
  }

  /// Adjust for a specific emotion mood
  /// Different emotions call for different dialog styles
  DialogStyle adjustForMood(String mood) {
    switch (mood.toLowerCase()) {
      case 'happy':
        return copyWith(
          warmth: (warmth + 0.1).clamp(0.0, 1.0),
          cadence: (cadence + 0.15).clamp(0.0, 1.0),
          expressiveness: (expressiveness + 0.15).clamp(0.0, 1.0),
        );
      case 'sad':
        return copyWith(
          warmth: (warmth + 0.2).clamp(0.0, 1.0),
          cadence: (cadence - 0.1).clamp(0.0, 1.0),
          expressiveness: (expressiveness - 0.1).clamp(0.0, 1.0),
          verbosity: (verbosity - 0.1).clamp(0.0, 1.0),
        );
      case 'calm':
        return copyWith(
          warmth: (warmth + 0.1).clamp(0.0, 1.0),
          cadence: (cadence - 0.15).clamp(0.0, 1.0),
          precision: (precision + 0.1).clamp(0.0, 1.0),
        );
      case 'anxious':
        return copyWith(
          warmth: (warmth + 0.15).clamp(0.0, 1.0),
          cadence: (cadence - 0.2).clamp(0.0, 1.0),
          precision: (precision + 0.1).clamp(0.0, 1.0),
          verbosity: (verbosity - 0.15).clamp(0.0, 1.0),
        );
      case 'excited':
        return copyWith(
          cadence: (cadence + 0.2).clamp(0.0, 1.0),
          expressiveness: (expressiveness + 0.2).clamp(0.0, 1.0),
          formality: (formality - 0.1).clamp(0.0, 1.0),
        );
      case 'reflective':
        return copyWith(
          cadence: (cadence - 0.1).clamp(0.0, 1.0),
          precision: (precision + 0.15).clamp(0.0, 1.0),
          verbosity: (verbosity + 0.1).clamp(0.0, 1.0),
        );
      default:
        return this; // Return unchanged for unknown moods
    }
  }

  /// Adjust for emotional intensity (0-3)
  DialogStyle adjustForIntensity(int intensity) {
    if (intensity <= 0) return this;

    final factor = intensity / 3.0; // Normalize to 0.0-1.0

    return copyWith(
      expressiveness: (expressiveness + (0.15 * factor)).clamp(0.0, 1.0),
      warmth: (warmth + (0.1 * factor)).clamp(0.0, 1.0),
    );
  }

  /// Get descriptive label for warmth level
  String get warmthLabel {
    if (warmth < 0.3) return 'cool';
    if (warmth < 0.6) return 'balanced';
    if (warmth < 0.8) return 'warm';
    return 'very warm';
  }

  /// Get descriptive label for cadence
  String get cadenceLabel {
    if (cadence < 0.3) return 'slow';
    if (cadence < 0.6) return 'moderate';
    if (cadence < 0.8) return 'brisk';
    return 'rapid';
  }

  /// Get descriptive label for expressiveness
  String get expressivenessLabel {
    if (expressiveness < 0.3) return 'neutral';
    if (expressiveness < 0.6) return 'balanced';
    if (expressiveness < 0.8) return 'expressive';
    return 'highly expressive';
  }

  /// Get descriptive label for precision
  String get precisionLabel {
    if (precision < 0.3) return 'general';
    if (precision < 0.6) return 'moderate';
    if (precision < 0.8) return 'precise';
    return 'very precise';
  }

  @override
  String toString() {
    return 'DialogStyle('
        'warmth: ${warmth.toStringAsFixed(2)} [$warmthLabel], '
        'precision: ${precision.toStringAsFixed(2)} [$precisionLabel], '
        'cadence: ${cadence.toStringAsFixed(2)} [$cadenceLabel], '
        'expressiveness: ${expressiveness.toStringAsFixed(2)} [$expressivenessLabel])';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is DialogStyle &&
        other.warmth == warmth &&
        other.precision == precision &&
        other.cadence == cadence &&
        other.expressiveness == expressiveness &&
        other.formality == formality &&
        other.verbosity == verbosity;
  }

  @override
  int get hashCode {
    return warmth.hashCode ^
        precision.hashCode ^
        cadence.hashCode ^
        expressiveness.hashCode ^
        formality.hashCode ^
        verbosity.hashCode;
  }
}
