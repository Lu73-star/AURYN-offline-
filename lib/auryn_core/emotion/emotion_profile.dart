/// lib/auryn_core/emotion/emotion_profile.dart
/// Perfil emocional persistente da AURYN.
/// 
/// O EmotionProfile mantém o histórico e as tendências emocionais da IA ao longo do tempo,
/// permitindo que ela desenvolva uma "personalidade emocional" consistente.
/// 
/// Características:
/// - Baseline emocional (humor padrão)
/// - Histórico de estados emocionais
/// - Tendências e padrões
/// - Persistência via storage local

import 'emotion_state.dart';

class EmotionProfile {
  /// Baseline emocional - estado padrão de retorno
  EmotionState baseline;

  /// Histórico dos últimos N estados emocionais
  final List<EmotionState> history;

  /// Capacidade máxima do histórico
  final int maxHistorySize;

  /// Contador de transições por humor
  final Map<String, int> moodFrequency;

  /// Tempo médio em cada humor (em segundos)
  final Map<String, double> moodDuration;

  /// Tendência emocional geral (média de valência ao longo do tempo)
  double _overallValence;

  /// Construtor
  EmotionProfile({
    EmotionState? baseline,
    List<EmotionState>? history,
    this.maxHistorySize = 50,
    Map<String, int>? moodFrequency,
    Map<String, double>? moodDuration,
    double? overallValence,
  })  : baseline = baseline ?? EmotionState.neutral(),
        history = history ?? [],
        moodFrequency = moodFrequency ?? {},
        moodDuration = moodDuration ?? {},
        _overallValence = overallValence ?? 0.0;

  /// Factory: cria perfil padrão
  factory EmotionProfile.defaultProfile() {
    return EmotionProfile(
      baseline: EmotionState.neutral(),
      maxHistorySize: 50,
    );
  }

  /// Factory: cria a partir de mapa (deserialização)
  factory EmotionProfile.fromMap(Map<String, dynamic> map) {
    final historyList = map['history'] as List<dynamic>? ?? [];
    final history = historyList
        .map((item) => EmotionState.fromMap(item as Map<String, dynamic>))
        .toList();

    return EmotionProfile(
      baseline: map['baseline'] != null
          ? EmotionState.fromMap(map['baseline'] as Map<String, dynamic>)
          : EmotionState.neutral(),
      history: history,
      maxHistorySize: map['maxHistorySize'] as int? ?? 50,
      moodFrequency: Map<String, int>.from(map['moodFrequency'] as Map? ?? {}),
      moodDuration:
          Map<String, double>.from(map['moodDuration'] as Map? ?? {}),
      overallValence: map['overallValence'] as double? ?? 0.0,
    );
  }

  /// Converte para mapa (serialização)
  Map<String, dynamic> toMap() {
    return {
      'baseline': baseline.toMap(),
      'history': history.map((state) => state.toMap()).toList(),
      'maxHistorySize': maxHistorySize,
      'moodFrequency': moodFrequency,
      'moodDuration': moodDuration,
      'overallValence': _overallValence,
    };
  }

  /// Adiciona um novo estado ao histórico
  void addState(EmotionState state) {
    history.add(state);

    // Atualiza frequência do humor
    moodFrequency[state.mood] = (moodFrequency[state.mood] ?? 0) + 1;

    // Calcula duração se houver estado anterior
    if (history.length > 1) {
      final previousState = history[history.length - 2];
      final duration =
          state.timestamp.difference(previousState.timestamp).inSeconds;

      final currentDuration = moodDuration[previousState.mood] ?? 0.0;
      final count = moodFrequency[previousState.mood] ?? 1;

      // Média móvel ponderada
      moodDuration[previousState.mood] =
          (currentDuration * (count - 1) + duration) / count;
    }

    // Atualiza valência geral
    _updateOverallValence();

    // Limita tamanho do histórico
    if (history.length > maxHistorySize) {
      history.removeAt(0);
    }
  }

  /// Retorna o estado emocional mais recente
  EmotionState? get currentState {
    return history.isNotEmpty ? history.last : null;
  }

  /// Retorna o humor mais frequente
  String get dominantMood {
    if (moodFrequency.isEmpty) return baseline.mood;

    return moodFrequency.entries
        .reduce((a, b) => a.value > b.value ? a : b)
        .key;
  }

  /// Retorna a valência emocional geral
  double get overallValence => _overallValence;

  /// Indica se a tendência geral é positiva
  bool get isTrendingPositive => _overallValence > 0.2;

  /// Indica se a tendência geral é negativa
  bool get isTrendingNegative => _overallValence < -0.2;

  /// Indica se a tendência é neutra
  bool get isTrendingNeutral =>
      _overallValence >= -0.2 && _overallValence <= 0.2;

  /// Retorna histórico dos últimos N estados
  List<EmotionState> getRecentHistory({int count = 10}) {
    if (history.length <= count) return List.from(history);
    return history.sublist(history.length - count);
  }

  /// Limpa o histórico (mantém baseline)
  void clearHistory() {
    history.clear();
    moodFrequency.clear();
    moodDuration.clear();
    _overallValence = 0.0;
  }

  /// Atualiza o baseline emocional
  void updateBaseline(EmotionState newBaseline) {
    baseline = newBaseline;
  }

  /// Calcula estatísticas do perfil
  Map<String, dynamic> getStatistics() {
    return {
      'totalStates': history.length,
      'dominantMood': dominantMood,
      'overallValence': _overallValence,
      'moodFrequency': Map.from(moodFrequency),
      'moodDuration': Map.from(moodDuration),
      'currentMood': currentState?.mood ?? baseline.mood,
      'isTrendingPositive': isTrendingPositive,
      'isTrendingNegative': isTrendingNegative,
    };
  }

  /// Atualiza a valência geral baseada no histórico recente
  void _updateOverallValence() {
    if (history.isEmpty) {
      _overallValence = 0.0;
      return;
    }

    // Calcula média ponderada das últimas 20 valências
    // (estados mais recentes têm mais peso)
    final recentStates = getRecentHistory(count: 20);
    double weightedSum = 0.0;
    double totalWeight = 0.0;

    for (int i = 0; i < recentStates.length; i++) {
      final weight = (i + 1).toDouble(); // Peso crescente para estados recentes
      weightedSum += recentStates[i].valence * weight;
      totalWeight += weight;
    }

    _overallValence = totalWeight > 0 ? weightedSum / totalWeight : 0.0;
  }

  @override
  String toString() {
    return 'EmotionProfile(baseline: ${baseline.mood}, '
        'historySize: ${history.length}, '
        'dominantMood: $dominantMood, '
        'overallValence: ${_overallValence.toStringAsFixed(2)})';
  }
}
