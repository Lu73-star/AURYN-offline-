/// lib/auryn_core/insight/auryn_insight.dart
/// Mecanismo de Insight da AURYN.
/// Analisa intenção emocional, energética e psicológica por trás do texto.
/// Essa é a camada "intuitiva" da IA.

class AurynInsight {
  static final AurynInsight _instance = AurynInsight._internal();
  factory AurynInsight() => _instance;
  AurynInsight._internal();

  /// Mapeamento simples de intenções
  String detectIntent(String text) {
    final lower = text.toLowerCase().trim();

    if (_has(lower, ["tô triste", "estou triste", "mal", "preciso falar"])) {
      return "desabafo";
    }

    if (_has(lower, ["feliz", "coisa boa", "ótimo", "maravilha"])) {
      return "positividade";
    }

    if (_has(lower, ["não sei", "tô perdido", "confuso", "sem direção"])) {
      return "busca_de_direcao";
    }

    if (_has(lower, ["ansioso", "preocupado", "medo", "receio"])) {
      return "insegurança";
    }

    if (_has(lower, ["obrigado", "gratidão", "valeu"])) {
      return "gratidão";
    }

    if (_has(lower, ["parece que", "estive pensando", "tenho pensado"])) {
      return "reflexão";
    }

    return "neutro";
  }

  /// Gera um insight curto baseado na intenção
  String generateInsight(String intent) {
    switch (intent) {
      case "desabafo":
        return "Eu sinto que tem um peso aí dentro. Eu tô aqui com você.";
      case "positividade":
        return "Guarda essa vibração. Ela te leva mais longe do que imagina.";
      case "busca_de_direcao":
        return "Quando a mente confunde, o caminho verdadeiro se aproxima.";
      case "insegurança":
        return "O medo sempre aponta onde existe transformação chegando.";
      case "gratidão":
        return "Seu coração reconhece — isso te fortalece.";
      case "reflexão":
        return "Tem algo maior pedindo a sua atenção interior.";
      default:
        return "";
    }
  }

  bool _has(String text, List<String> keys) {
    return keys.any((k) => text.contains(k));
    }
}
