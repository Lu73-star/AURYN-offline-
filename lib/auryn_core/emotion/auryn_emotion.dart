/// lib/auryn_core/emotion/auryn_emotion.dart
/// Mecanismo emocional da AURYN.
/// Controla humor, intensidade e modulação emocional das respostas.
/// Conecta-se ao States, Processor e Personality.

import 'package:auryn_offline/auryn_core/states/auryn_states.dart';

class AurynEmotion {
  static final AurynEmotion _instance = AurynEmotion._internal();
  factory AurynEmotion() => _instance;
  AurynEmotion._internal();

  final AurynStates _states = AurynStates();

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
  int intensity = 1;

  /// Define emoção baseada no input do usuário
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
}
