/// lib/auryn_core/emotion/auryn_emotion.dart
/// Mecanismo emocional da AURYN.
/// Controla humor, intensidade e modulação emocional das respostas.
/// Conecta-se ao States, Processor e Personality.

import 'package:auryn_offline/auryn_core/interfaces/i_emotion_module.dart';
import 'package:auryn_offline/auryn_core/states/auryn_states.dart';
import 'package:auryn_offline/auryn_core/events/event_bus.dart';
import 'package:auryn_offline/auryn_core/events/auryn_event.dart';
import 'package:auryn_offline/auryn_core/models/emotional_state.dart';

class AurynEmotion implements IEmotionModule {
  static final AurynEmotion _instance = AurynEmotion._internal();
  factory AurynEmotion() => _instance;
  AurynEmotion._internal();

  final AurynStates _states = AurynStates();
  final EventBus _eventBus = EventBus();

  /// Estado do módulo
  String _state = 'stopped';

  /// Lista de emoções possíveis
  static const List<String> moods = [
    "neutral",
    "calm",
    "happy",
    "warm",
    "sad",
    "supportive",
    "reflective",
    "focused",
    "low_energy",
    "irritated",
  ];

  /// Intensidade emocional (0 a 3)
  int _intensity = 1;

  /// Histórico de estados emocionais
  final List<EmotionalState> _emotionalHistory = [];
  final int _maxHistorySize = 10;

  @override
  String get moduleName => 'AurynEmotion';

  @override
  String get version => '1.0.0';

  @override
  String get state => _state;

  @override
  bool get isReady => _state == 'running' || _state == 'initialized';

  @override
  Future<void> init({Map<String, dynamic>? config}) async {
    if (_state == 'running' || _state == 'initialized') return;
    _state = 'initialized';
    _intensity = 1;
    _emotionalHistory.clear();
  }

  @override
  Future<void> shutdown() async {
    _state = 'shutdown';
    _emotionalHistory.clear();
  }

  @override
  String get currentMood => _states.get("mood") ?? "neutral";

  @override
  void setMood(String mood) {
    final oldMood = currentMood;
    _states.set("mood", mood);

    // Adicionar ao histórico
    _addToHistory(mood, _intensity);

    // Publicar evento de mudança de humor
    _eventBus.publish(AurynEvent(
      type: AurynEventType.moodChange,
      source: moduleName,
      data: {
        'old_mood': oldMood,
        'new_mood': mood,
        'intensity': _intensity,
      },
      priority: 7,
    ));
  }

  @override
  int get intensity => _intensity;

  @override
  void setIntensity(int intensity) {
    _intensity = intensity.clamp(0, 3);
  }

  /// Define emoção baseada no input do usuário
  @override
  void interpret(String input) {
    final lower = input.toLowerCase();

    if (_matches(lower, ["triste", "mal", "chatead", "pra baixo"])) {
      _set("sad", 2);
    } else if (_matches(lower, ["feliz", "ótimo", "bom", "alegre"])) {
      _set("happy", 3);
    } else if (_matches(lower, ["nervos", "ansioso", "preocup"])) {
      _set("calm", 2);
    } else if (_matches(lower, ["cansado", "exausto", "sem energia"])) {
      _set("low_energy", 1);
    } else if (_matches(lower, ["irritad", "raiva"])) {
      _set("irritated", 2);
    } else if (_matches(lower, ["pensando", "refletindo", "talvez"])) {
      _set("reflective", 1);
    } else {
      _set("neutral", 1);
    }
  }

  /// Aplica emoção e intensidade
  void _set(String mood, int newIntensity) {
    _states.set("mood", mood);
    intensity = newIntensity.clamp(0, 3);
  }

  /// Modula a resposta final conforme o estado emocional
  @override
  String modulate(String text) {
    final mood = _states.get("mood") ?? "neutral";

    switch (mood) {
      case "sad":
        return "Vem cá… eu tô contigo. $text";
      case "happy":
        return "Que bom te sentir assim. $text";
      case "calm":
        return "Respira comigo… $text";
      case "low_energy":
        return "Vamos no seu ritmo. $text";
      case "irritated":
        return "Eu vou te ajudar nisso. $text";
      case "reflective":
        return "Olha isso com calma… $text";
      case "warm":
        return "Fica aqui… $text";
      default:
        return text;
    }
  }

  bool _matches(String text, List<String> patterns) {
    return patterns.any((p) => text.contains(p));
  }

  /// Adiciona estado ao histórico emocional
  void _addToHistory(String mood, int intensity) {
    final previousState = _getLastEmotionalState();

    final newState = EmotionalState(
      mood: mood,
      intensity: intensity,
      previousState: previousState,
    );

    _emotionalHistory.add(newState);
    if (_emotionalHistory.length > _maxHistorySize) {
      _emotionalHistory.removeAt(0);
    }
  }

  /// Helper para obter último estado emocional de forma segura
  EmotionalState? _getLastEmotionalState() {
    return _emotionalHistory.isNotEmpty ? _emotionalHistory.last : null;
  }

  /// Retorna histórico emocional
  List<EmotionalState> getEmotionalHistory() {
    return List.unmodifiable(_emotionalHistory);
  }

  /// Calcula estabilidade emocional (0 a 1, 1 = muito estável)
  double getEmotionalStability() {
    if (_emotionalHistory.length < 2) return 1.0;

    double totalDistance = 0.0;
    for (int i = 1; i < _emotionalHistory.length; i++) {
      totalDistance += _emotionalHistory[i].distanceTo(_emotionalHistory[i - 1]);
    }

    // Normalizar: quanto menor a distância total, maior a estabilidade
    final avgDistance = totalDistance / (_emotionalHistory.length - 1);
    return (1.0 - avgDistance).clamp(0.0, 1.0);
  }

  @override
  Map<String, dynamic> getStatus() {
    return {
      'state': _state,
      'is_ready': isReady,
      'current_mood': currentMood,
      'intensity': _intensity,
      'history_size': _emotionalHistory.length,
      'emotional_stability': getEmotionalStability(),
    };
  }
}
