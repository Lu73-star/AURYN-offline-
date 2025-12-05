/// lib/auryn_core/interfaces/i_emotion_module.dart
/// Interface para módulos emocionais.
/// Define o contrato para módulos que gerenciam estados emocionais.

import 'package:auryn_offline/auryn_core/interfaces/i_auryn_module.dart';

abstract class IEmotionModule extends IAurynModule {
  /// Interpreta emoção a partir de texto
  void interpret(String input);

  /// Modula uma resposta com base no estado emocional
  String modulate(String response);

  /// Retorna o humor/mood atual
  String get currentMood;

  /// Define o humor/mood
  void setMood(String mood);

  /// Retorna a intensidade emocional atual (0-3)
  int get intensity;

  /// Define a intensidade emocional
  void setIntensity(int intensity);
}
