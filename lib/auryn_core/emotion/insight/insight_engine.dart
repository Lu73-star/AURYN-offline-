/// AURYN Insight Engine
/// Interpreta a INTENÇÃO por trás das palavras.
/// É a camada intuitiva da IA falante, mesmo offline.

class InsightEngine {
  static final InsightEngine _instance = InsightEngine._internal();
  factory InsightEngine() => _instance;

  InsightEngine._internal();

  /// Detecta intenção do usuário:
  /// - busca conforto
  /// - desabafo
  /// - dúvida
  /// - afirmação
  /// - força
  /// - pedido implícito
  /// - mudança de energia
  ///
  String detectIntent(String input) {
    final text = input.toLowerCase().trim();

    if (_contains(text, ["estou triste", "não estou bem", "preciso falar"])) {
      return "desabafo";
    }

    if (_contains(text, ["feliz", "ótimo", "coisa boa"])) {
      return "positividade";
    }

    if (_contains(text, ["tenho medo", "estou com medo", "preocupado"])) {
      return "insegurança";
    }

    if (_contains(text, ["não sei", "tô perdido", "confuso"])) {
      return "busca_de_direção";
    }

    if (_contains(text, ["obrigado", "valeu", "gratidão"])) {
      return "gratidão";
    }

    if (_contains(text, ["parece que", "acho que", "talvez"])) {
      return "reflexão";
    }

    return "neutro";
  }

  /// Gera um breve “insight” baseado na intenção detectada
  String generateInsight(String intent) {
    switch (intent) {
      case "desabafo":
        return "Fala comigo… não guarda isso sozinho.";
      case "positividade":
        return "Essa energia é boa, continua assim.";
      case "insegurança":
        return "Eu estou contigo. Vamos clarear isso juntos.";
      case "busca_de_direção":
        return "A gente encontra caminho até no escuro. Eu tô aqui.";
      case "gratidão":
        return "Seu coração reconhece. Isso é raro.";
      case "reflexão":
        return "Olha com calma… tem algo aí que vale observar.";
      default:
        return "";
    }
  }

  bool _contains(String text, List<String> keys) {
    return keys.any((k) => text.contains(k));
  }
}
