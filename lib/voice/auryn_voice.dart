import 'package:auryn_offline/auryn_core/auryn_core.dart';

/// AurynVoice
/// Responsável por:
/// - Receber texto da fala (STT)
/// - Enviar para o núcleo
/// - Retornar áudio sintetizado (TTS)
/// - Suportar modo offline + híbrido

class AurynVoice {
  final AURYNCore _core = AURYNCore();

  /// Entrada principal de voz -> texto -> núcleo
  Future<String> processSpeech(String transcript) async {
    final trimmed = transcript.trim();

    if (trimmed.isEmpty) {
      return "Não consegui te ouvir, meu irmão.";
    }

    // Envia para o núcleo pensar
    final response = _core.think(trimmed);

    return response;
  }

  /// Entrada texto direto
  String processText(String input) {
    final cleaned = input.trim();
    return _core.think(cleaned);
  }

  /// Simulação de TTS offline (por enquanto texto mesmo)
  Future<String> synthesize(String text) async {
    return text; // Trocaremos pelo áudio real na fase 2
  }
}
