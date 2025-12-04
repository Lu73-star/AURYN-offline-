import 'package:auryn_offline/auryn_core/auryn_core.dart';

/// AurynVoice
/// Ponte entre: voz -> texto -> núcleo -> resposta
class AurynVoice {
  final AURYNCore _core = AURYNCore();

  /// Processa fala transcrita
  Future<String> processSpeech(String transcript) async {
    final trimmed = transcript.trim();

    if (trimmed.isEmpty) {
      return "Não consegui te ouvir, meu irmão.";
    }

    final response = _core.think(trimmed);
    return response;
  }

  /// Processa texto digitado
  String processText(String input) {
    final cleaned = input.trim();
    return _core.think(cleaned);
  }

  /// Simulação TTS (temporário)
  Future<String> synthesize(String text) async {
    return text;
  }
}
