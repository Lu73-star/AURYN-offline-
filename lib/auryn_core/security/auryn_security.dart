/// lib/auryn_core/security/auryn_security.dart
/// Módulo de segurança leve e offline da AURYN.
/// Não censura — apenas protege contra loops, entrada perigosa,
/// payloads estranhos ou strings que podem quebrar o processamento.

class AurynSecurity {
  static final AurynSecurity _instance = AurynSecurity._internal();
  factory AurynSecurity() => _instance;
  AurynSecurity._internal();

  /// Limite total para evitar loops infinitos
  final int maxInputLength = 5000;
  final int maxOutputLength = 5000;

  /// Detecta padrões perigosos que podem travar a IA no modo offline
  bool hasMaliciousPattern(String text) {
    final lower = text.toLowerCase();

    // Comandos shell perigosos
    final List<String> blacklist = [
      "rm -rf",
      "sudo",
      "chmod",
      "exec(",
      "system(",
      "forkbomb",
      ":(){:|:&};:",
    ];

    for (final b in blacklist) {
      if (lower.contains(b)) return true;
    }

    return false;
  }

  /// Sanitiza entradas para evitar quebra de pipeline
  String sanitize(String text) {
    if (text.trim().isEmpty) {
      return "";
    }

    // Remove caracteres invisíveis ou estranhos
    final sanitized = text
        .replaceAll("\u0000", "")
        .replaceAll("\u202E", "") // RTL override
        .replaceAll("\u202A", "")
        .replaceAll("\u202B", "")
        .replaceAll("\u202C", "");

    return sanitized;
  }

  /// Valida a entrada do usuário antes do NLP
  bool validateInput(String text) {
    if (text.isEmpty) return false;
    if (text.length > maxInputLength) return false;
    if (hasMaliciousPattern(text)) return false;
    return true;
  }

  /// Valida a saída antes de retornar para o usuário
  String enforceOutputLimits(String text) {
    if (text.length > maxOutputLength) {
      return text.substring(0, maxOutputLength) + "...";
    }
    return text;
  }
}
