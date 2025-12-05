/// lib/auryn_core/emotion/emotion_state.dart
/// Estado emocional da AURYN - representa o estado emocional momentâneo.
/// 
/// O EmotionState modela a condição emocional atual da IA, incluindo:
/// - mood (humor): qual emoção predominante
/// - intensity (intensidade): quão forte é a emoção (0-3)
/// - valence (valência): positiva, negativa ou neutra (-1, 0, 1)
/// - arousal (ativação): nível de energia/ativação (0-3)
/// - timestamp: quando o estado foi estabelecido

class EmotionState {
  /// Humor emocional atual (ex: "happy", "sad", "calm", "neutral")
  final String mood;

  /// Intensidade da emoção (0 = nenhuma, 1 = leve, 2 = moderada, 3 = forte)
  final int intensity;

  /// Valência emocional (-1 = negativa, 0 = neutra, 1 = positiva)
  final int valence;

  /// Nível de ativação/energia (0 = muito baixa, 3 = muito alta)
  final int arousal;

  /// Timestamp de quando este estado foi estabelecido
  final DateTime timestamp;

  /// Construtor principal
  EmotionState({
    required this.mood,
    required this.intensity,
    required this.valence,
    required this.arousal,
    DateTime? timestamp,
  })  : assert(intensity >= 0 && intensity <= 3, 'Intensity must be 0-3'),
        assert(valence >= -1 && valence <= 1, 'Valence must be -1, 0, or 1'),
        assert(arousal >= 0 && arousal <= 3, 'Arousal must be 0-3'),
        timestamp = timestamp ?? DateTime.now();

  /// Factory: estado neutro padrão
  factory EmotionState.neutral() {
    return EmotionState(
      mood: 'neutral',
      intensity: 0,
      valence: 0,
      arousal: 1,
    );
  }

  /// Factory: cria estado a partir de mapa (para deserialização)
  factory EmotionState.fromMap(Map<String, dynamic> map) {
    return EmotionState(
      mood: map['mood'] as String? ?? 'neutral',
      intensity: map['intensity'] as int? ?? 0,
      valence: map['valence'] as int? ?? 0,
      arousal: map['arousal'] as int? ?? 1,
      timestamp: map['timestamp'] != null
          ? DateTime.parse(map['timestamp'] as String)
          : DateTime.now(),
    );
  }

  /// Converte para mapa (para serialização)
  Map<String, dynamic> toMap() {
    return {
      'mood': mood,
      'intensity': intensity,
      'valence': valence,
      'arousal': arousal,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  /// Cria uma cópia com valores opcionalmente alterados
  EmotionState copyWith({
    String? mood,
    int? intensity,
    int? valence,
    int? arousal,
    DateTime? timestamp,
  }) {
    return EmotionState(
      mood: mood ?? this.mood,
      intensity: intensity ?? this.intensity,
      valence: valence ?? this.valence,
      arousal: arousal ?? this.arousal,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  /// Indica se o estado é positivo
  bool get isPositive => valence > 0;

  /// Indica se o estado é negativo
  bool get isNegative => valence < 0;

  /// Indica se o estado é neutro
  bool get isNeutral => valence == 0;

  /// Indica se o estado tem alta energia
  bool get isHighEnergy => arousal >= 2;

  /// Indica se o estado tem baixa energia
  bool get isLowEnergy => arousal <= 1;

  @override
  String toString() {
    return 'EmotionState(mood: $mood, intensity: $intensity, '
        'valence: $valence, arousal: $arousal, timestamp: $timestamp)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is EmotionState &&
        other.mood == mood &&
        other.intensity == intensity &&
        other.valence == valence &&
        other.arousal == arousal;
  }

  @override
  int get hashCode {
    return mood.hashCode ^
        intensity.hashCode ^
        valence.hashCode ^
        arousal.hashCode;
  }
}
