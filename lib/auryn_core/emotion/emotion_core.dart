/// lib/auryn_core/emotion/emotion_core.dart
/// EmotionCore - Sistema unificado de gerenciamento emocional da AURYN.
/// 
/// O EmotionCore integra todos os componentes do sistema emocional:
/// - EmotionState: Estado emocional momentâneo
/// - EmotionProfile: Perfil e histórico emocional persistente
/// - EmotionRegulator: Lógica de regulação e modulação
/// - EmotionHooks: Sistema de eventos e notificações
/// 
/// Esta é a interface principal que outros módulos devem usar para
/// interagir com o sistema emocional da AURYN.

import 'emotion_state.dart';
import 'emotion_profile.dart';
import 'emotion_regulator.dart';
import 'emotion_hooks.dart';

class EmotionCore {
  /// Singleton instance
  static final EmotionCore _instance = EmotionCore._internal();
  factory EmotionCore() => _instance;
  EmotionCore._internal();

  /// Perfil emocional da AURYN
  late EmotionProfile _profile;

  /// Regulador emocional
  late EmotionRegulator _regulator;

  /// Sistema de hooks
  final EmotionHooks _hooks = EmotionHooks();

  /// Estado emocional atual
  EmotionState? _currentState;

  /// Indica se o sistema foi inicializado
  bool _isInitialized = false;

  /// Inicializa o sistema emocional
  Future<void> initialize({
    EmotionProfile? profile,
    double decayRate = 0.3,
  }) async {
    _profile = profile ?? EmotionProfile.defaultProfile();
    _regulator = EmotionRegulator(profile: _profile, decayRate: decayRate);
    _currentState = _profile.baseline;
    _isInitialized = true;

    print('[EmotionCore] Sistema emocional inicializado com baseline: ${_profile.baseline.mood}');
  }

  /// Garante que o sistema está inicializado
  void _ensureInitialized() {
    if (!_isInitialized) {
      throw StateError('EmotionCore não foi inicializado. Chame initialize() primeiro.');
    }
  }

  /// Processa input do usuário e atualiza estado emocional
  void processInput(String input) {
    _ensureInitialized();

    final previousState = _currentState!;

    // Interpreta input e determina novo estado emocional
    final targetState = _regulator.interpretInput(input);

    // Regula transição para evitar mudanças bruscas
    final newState = _regulator.regulateTransition(previousState, targetState);

    // Atualiza estado atual
    _updateState(newState);
  }

  /// Atualiza o estado emocional manualmente
  void setState(EmotionState state) {
    _ensureInitialized();
    _updateState(state);
  }

  /// Atualiza estado e dispara eventos
  void _updateState(EmotionState newState) {
    final previousState = _currentState!;

    // Adiciona ao histórico do perfil
    _profile.addState(newState);

    // Atualiza estado atual
    _currentState = newState;

    // Notifica hooks
    _hooks.notifyStateChange(previousState, newState);
  }

  /// Retorna o estado emocional atual
  EmotionState get currentState {
    _ensureInitialized();
    return _currentState!;
  }

  /// Retorna o perfil emocional
  EmotionProfile get profile {
    _ensureInitialized();
    return _profile;
  }

  /// Retorna o sistema de hooks
  EmotionHooks get hooks => _hooks;

  /// Retorna o regulador emocional
  EmotionRegulator get regulator {
    _ensureInitialized();
    return _regulator;
  }

  /// Modula resposta textual baseada no estado emocional atual
  String modulateResponse(String text) {
    _ensureInitialized();
    return _regulator.modulateResponse(text, _currentState!);
  }

  /// Aplica decaimento emocional (retorna ao baseline)
  void applyDecay() {
    _ensureInitialized();
    final decayedState = _regulator.applyDecay(_currentState!);
    if (decayedState != _currentState) {
      _updateState(decayedState);
    }
  }

  /// Retorna ao estado baseline
  void resetToBaseline() {
    _ensureInitialized();
    _updateState(_profile.baseline);
  }

  /// Atualiza o baseline emocional
  void updateBaseline(EmotionState newBaseline) {
    _ensureInitialized();
    _profile.updateBaseline(newBaseline);
  }

  /// Obtém estatísticas do perfil emocional
  Map<String, dynamic> getStatistics() {
    _ensureInitialized();
    return _profile.getStatistics();
  }

  /// Obtém histórico recente de estados emocionais
  List<EmotionState> getRecentHistory({int count = 10}) {
    _ensureInitialized();
    return _profile.getRecentHistory(count: count);
  }

  /// Analisa sentimento de um texto
  Map<String, dynamic> analyzeSentiment(String text) {
    _ensureInitialized();
    return _regulator.analyzeSentiment(text);
  }

  /// Ajusta intensidade do estado atual
  void adjustIntensity({int delta = 0}) {
    _ensureInitialized();
    final adjusted = _regulator.adjustIntensity(_currentState!, delta: delta);
    _updateState(adjusted);
  }

  /// Cria e aplica estado emocional customizado
  void setCustomEmotion({
    required String mood,
    int intensity = 1,
    int valence = 0,
    int arousal = 1,
  }) {
    _ensureInitialized();
    final customState = _regulator.createCustomState(
      mood: mood,
      intensity: intensity,
      valence: valence,
      arousal: arousal,
    );
    _updateState(customState);
  }

  /// Limpa o histórico emocional (mantém baseline e estado atual)
  void clearHistory() {
    _ensureInitialized();
    _profile.clearHistory();
  }

  /// Exporta perfil emocional para persistência
  Map<String, dynamic> exportProfile() {
    _ensureInitialized();
    return _profile.toMap();
  }

  /// Importa perfil emocional de dados persistidos
  Future<void> importProfile(Map<String, dynamic> data) async {
    _profile = EmotionProfile.fromMap(data);
    _regulator = EmotionRegulator(profile: _profile, decayRate: _regulator.decayRate);
    _currentState = _profile.currentState ?? _profile.baseline;
    _isInitialized = true;
  }

  /// Registra hook para mudanças de estado
  void onStateChange(EmotionChangeCallback callback) {
    _hooks.onStateChange(callback);
  }

  /// Registra hook para alta intensidade
  void onHighIntensity(HighIntensityCallback callback) {
    _hooks.onHighIntensity(callback);
  }

  /// Registra hook para mudanças de humor
  void onMoodChange(MoodChangeCallback callback) {
    _hooks.onMoodChange(callback);
  }

  /// Registra hook para emoções positivas
  void onPositiveEmotion(EmotionChangeCallback callback) {
    _hooks.onPositiveEmotion(callback);
  }

  /// Registra hook para emoções negativas
  void onNegativeEmotion(EmotionChangeCallback callback) {
    _hooks.onNegativeEmotion(callback);
  }

  /// Verifica se o sistema está inicializado
  bool get isInitialized => _isInitialized;

  /// Retorna informações de debug
  Map<String, dynamic> getDebugInfo() {
    if (!_isInitialized) {
      return {'initialized': false};
    }

    return {
      'initialized': true,
      'currentState': _currentState?.toMap(),
      'baseline': _profile.baseline.toMap(),
      'historySize': _profile.history.length,
      'dominantMood': _profile.dominantMood,
      'overallValence': _profile.overallValence,
      'hookCallbacks': _hooks.callbackCounts,
    };
  }

  /// Reset completo do sistema emocional
  Future<void> reset() async {
    await initialize();
    _hooks.clearAllCallbacks();
  }

  @override
  String toString() {
    if (!_isInitialized) {
      return 'EmotionCore(not initialized)';
    }
    return 'EmotionCore(current: ${_currentState!.mood}, '
        'baseline: ${_profile.baseline.mood}, '
        'historySize: ${_profile.history.length})';
  }
}
