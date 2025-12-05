/// AURYN Security Layer
/// Primeira camada de segurança da IA.
/// Protege contra entradas perigosas, loops e comandos inválidos.

class SecurityLayer {
  static final SecurityLayer _instance = SecurityLayer._internal();
  factory SecurityLayer() => _instance;

  SecurityLayer._internal();

  /// Verifica se a entrada do usuário é segura e válida
  String sanitize(String input) {
    final text = input.trim();

    // Bloquear strings vazias
    if (text.isEmpty) {
      return "";
    }

    // Bloquear entradas muito longas (prevenir loop offline)
    if (text.length > 500) {
      return "TEXTO_LONGO";
    }

    // Bloquear tentativas de código
    if (_containsCode(text)) {
      return "CODIGO_BLOQUEADO";
    }

    // Bloquear tentativas explícitas de travar a IA
    if (_containsAttack(text)) {
      return "ENTRADA_BLOQUEADA";
    }

    return text;
  }

  /// Verifica tentativas de injetar código
  bool _containsCode(String text) {
    final patterns = [
      "import ",
      "void main",
      "class ",
      "function",
      "script",
      "<html>",
      "<script>",
    ];
    return patterns.any((p) => text.toLowerCase().contains(p));
  }

  /// Verifica tentativas de "ataque" (loop, spam, testes maliciosos)
  bool _containsAttack(String text) {
    final patterns = [
      "loop infinito",
      "trav",
      "derrubar",
      "parar sistema",
      "destruir"
    ];
    return patterns.any((p) => text.toLowerCase().contains(p));
  }
}
