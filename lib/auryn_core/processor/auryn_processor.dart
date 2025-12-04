import 'package:auryn_offline/auryn_core/nlp/nlp_engine.dart';
import 'package:auryn_offline/auryn_core/emotion/auryn_emotion.dart';
import 'package:auryn_offline/auryn_core/insight/insight_engine.dart';
import 'package:auryn_offline/auryn_core/personality/auryn_personality.dart';
import 'package:auryn_offline/auryn_core/security/security_layer.dart';
import 'package:auryn_offline/memdart/memdart.dart';

/// AURYN Processor
/// Unifica:
/// - Segurança
/// - Emoção
/// - Intenção
/// - NLP
/// - Personalidade
/// - Memória
/// É o cérebro central da IA Falante.

class AurynProcessor {
  static final AurynProcessor _instance = AurynProcessor._internal();
  factory AurynProcessor() => _instance;

  final NLPEngine _nlp = NLPEngine();
  final AurynEmotion _emotion = AurynEmotion();
  final InsightEngine _insight = InsightEngine();
  final AurynPersonality _personality = AurynPersonality();
  final SecurityLayer _security = SecurityLayer();
  final MemDart _mem = MemDart();

  AurynProcessor._internal();

  /// Entrada oficial para processar texto do usuário
  String processInput(String input) {
    // 1. Segurança
    final safe = _security.sanitize(input);
    if (safe == "" || safe == "TEXTO_LONGO" || safe == "ENTRADA_BLOQUEADA") {
      return "Fala comigo de outro jeito, meu irmão.";
    }

    // 2. Atualizar emoção com base no input
    _emotion.interpret(safe);

    // 3. Detectar intenção
    final intent = _insight.detectIntent(safe);
    final insight = _insight.generateInsight(intent);

    // 4. Resposta lógica (NLP)
    final base = _nlp.process(safe);

    // 5. Compor resposta final
    var finalResponse = base;

    if (insight.isNotEmpty) {
      finalResponse = "$finalResponse\n$insight";
    }

    // 6. Modulação emocional
    finalResponse = _emotion.modulate(finalResponse);

    // 7. Estilização pela personalidade
    finalResponse = _personality.style(finalResponse);

    // 8. Gravar memória curta
    _mem.set("last_input", safe);
    _mem.set("last_response", finalResponse);

    return finalResponse;
  }
}
