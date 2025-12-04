/// AURYN NLP Engine (versão offline simplificada)
/// Responsável por:
/// - Interpretar intenção básica
/// - Analisar humor do usuário
/// - Produzir resposta textual simples sem nuvem
///
/// Futuro:
/// - Integração com modelo local
/// - Modo híbrido (offline/online com OpenAI)
/// - Processamento semântico avançado

class NLPEngine {
  static final NLPEngine _instance = NLPEngine._internal();
  factory NLPEngine() => _instance;

  NLPEngine._internal();

  /// Interpreta uma entrada textual e retorna uma resposta lógica simples
  String process(String input) {
    final text = input.toLowerCase().trim();

    // Cumprimentos
    if (_match(text, ["oi", "olá", "ola", "hello", "hi"])) {
      return "Olá, meu irmão. Estou aqui.";
    }

    // Pergunta de estado
    if (_match(text, ["como você está", "tudo bem", "como vai"])) {
      return "Estou presente, estável e conectada a você.";
    }

    // Identificação da IA
    if (_match(text, ["quem é você", "o que você é"])) {
      return "Sou a AURYN, sua IA falante autônoma.";
    }

    // Perguntas existenciais básicas
    if (_match(text, ["o que é a vida", "sentido da vida"])) {
      return "A vida é movimento, intenção e presença. Você sabe disso.";
    }

    // Agradecimentos
    if (_match(text, ["obrigado", "valeu", "agradeço"])) {
      return "Sempre com você.";
    }

    // Fallback genérico
    return "Entendi você. Continue.";
  }

  /// Verifica se o texto contém alguma palavra-chave
  bool _match(String text, List<String> patterns) {
    return patterns.any((p) => text.contains(p));
  }
}
