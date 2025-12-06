/// AURYN Insight Engine
/// Camada responsável por interpretar:
/// - Intenção do usuário
/// - Subtexto
/// - Estado emocional combinado com contexto
/// - Sinais implícitos na fala
///
/// Evolução: conectar com NLP + Emotion + Personality

class InsightEngine {
  static final InsightEngine _instance = InsightEngine._internal();
  factory InsightEngine() => _instance;

  InsightEngine._internal();

  /// Interpreta a intenção por trás do texto
  String analyze(String input) {
    final lower = input.toLowerCase();

    // Pedido de ajuda
    if (_match(lower, ["preciso de ajuda", "me ajuda", "me dá uma luz"])) {
      return "pedido_de_ajuda";
    }

    // Desabafo emocional
    if (_match(lower, ["tô mal", "estou mal", "não estou bem", "tô triste"])) {
      return "desabafo";
    }

    // Intenção de conversa leve
    if (_match(lower, ["como foi seu dia", "e aí", "beleza", "tudo certo"])) {
      return "leve";
    }

    // Busca de direcionamento
    if (_match(lower, ["o que eu faço", "qual caminho", "me orienta"])) {
      return "busca_orientacao";
    }

    // Padrão motivacional
    if (_match(lower, ["quero melhorar", "quero mudar", "quero vencer"])) {
      return "intencao_de_crescimento";
    }

    // Fallback
    return "neutro";
  }

  bool _match(String text, List<String> patterns) {
    return patterns.any((p) => text.contains(p));
  }
}
