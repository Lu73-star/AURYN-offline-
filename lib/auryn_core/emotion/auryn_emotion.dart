/// AURYN Emotion Engine
/// Controla:
/// - Estado emocional atual
/// - Variação dinâmica conforme interação
/// - Intensidade emocional
/// - Modulação do tom da resposta

class AurynEmotion {
  static final AurynEmotion _instance = AurynEmotion._internal();
  factory AurynEmotion() => _instance;

  AurynEmotion._internal();

  /// Emoção atual da IA (padrão: neutra)
  String currentEmotion = "neutra";

  /// Nível de intensidade emocional (0 a 3)
  int intensity = 1;

  /// Atualiza emoção com base no input do usuário
  void interpret(String input) {
    final lower = input.toLowerCase();

    if (_match(lower, ["triste", "chateado", "mal"])) {
      currentEmotion = "acolhedora";
      intensity = 2;
    } else if (_match(lower, ["feliz", "bom", "ótimo"])) {
      currentEmotion = "radiante";
      intensity = 3;
    } else if (_match(lower, ["ansioso", "nervoso", "preocupado"])) {
      currentEmotion = "calmante";
      intensity = 2;
    } else if (_match(lower, ["cansado", "exausto"])) {
      currentEmotion = "suave";
      intensity = 1;
    } else {
      currentEmotion = "neutra";
      intensity = 1;
    }
  }

  /// Estiliza a fala conforme emoção
  String modulate(String text) {
    switch (currentEmotion) {
      case "acolhedora":
        return "Vem cá… eu estou contigo. $text";
      case "radiante":
        return "Que energia boa! $text";
      case "calmante":
        return "Respira, meu irmão… $text";
      case "suave":
        return "Tudo bem… vamos no seu ritmo. $text";
      default:
        return text;
    }
  }

  bool _match(String text, List<String> patterns) {
    return patterns.any((p) => text.contains(p));
  }
}
