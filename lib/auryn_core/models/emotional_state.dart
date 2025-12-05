/// lib/auryn_core/models/emotional_state.dart
/// Modelo que representa o estado emocional da AURYN.

class EmotionalState {
  /// Humor/mood atual
  final String mood;

  /// Intensidade emocional (0-3)
  final int intensity;

  /// Timestamp do estado
  final DateTime timestamp;

  /// Valência emocional (-1 a 1: negativo a positivo)
  final double valence;

  /// Nível de ativação (0 a 1: calmo a agitado)
  final double arousal;

  /// Estado anterior (para transições)
  final EmotionalState? previousState;

  EmotionalState({
    required this.mood,
    required this.intensity,
    DateTime? timestamp,
    this.valence = 0.0,
    this.arousal = 0.5,
    this.previousState,
  }) : timestamp = timestamp ?? DateTime.now();

  /// Cria uma cópia com modificações
  EmotionalState copyWith({
    String? mood,
    int? intensity,
    DateTime? timestamp,
    double? valence,
    double? arousal,
    EmotionalState? previousState,
  }) {
    return EmotionalState(
      mood: mood ?? this.mood,
      intensity: intensity ?? this.intensity,
      timestamp: timestamp ?? this.timestamp,
      valence: valence ?? this.valence,
      arousal: arousal ?? this.arousal,
      previousState: previousState ?? this.previousState,
    );
  }

  /// Converte para Map
  Map<String, dynamic> toMap() {
    return {
      'mood': mood,
      'intensity': intensity,
      'timestamp': timestamp.toIso8601String(),
      'valence': valence,
      'arousal': arousal,
      'hasPrevious': previousState != null,
    };
  }

  @override
  String toString() {
    return 'EmotionalState(mood: $mood, intensity: $intensity, valence: $valence, arousal: $arousal)';
  }

  /// Calcula a diferença entre dois estados emocionais
  double distanceTo(EmotionalState other) {
    final moodDiff = mood == other.mood ? 0.0 : 1.0;
    final intensityDiff = (intensity - other.intensity).abs() / 3.0;
    final valenceDiff = (valence - other.valence).abs();
    final arousalDiff = (arousal - other.arousal).abs();

    return (moodDiff + intensityDiff + valenceDiff + arousalDiff) / 4.0;
  }
}
