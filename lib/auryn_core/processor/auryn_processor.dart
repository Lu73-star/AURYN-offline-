/// lib/auryn_core/processor/auryn_processor.dart
/// O módulo mais importante: integra NLP + Emotion + Personality + Insight
/// + Security + States + MemDart para produzir a resposta final da AURYN.

import 'package:auryn_offline/auryn_core/nlp/auryn_nlp.dart';
import 'package:auryn_offline/auryn_core/emotion/auryn_emotion.dart';
import 'package:auryn_offline/auryn_core/insight/auryn_insight.dart';
import 'package:auryn_offline/auryn_core/personality/auryn_personality.dart';
import 'package:auryn_offline/auryn_core/security/auryn_security.dart';
import 'package:auryn_offline/auryn_core/states/auryn_states.dart';
import 'package:auryn_offline/memdart/memdart.dart';

class AurynProcessor {
  static final AurynProcessor _instance = AurynProcessor._internal();
  factory AurynProcessor() => _instance;
  AurynProcessor._internal();

  final AurynNLP _nlp = AurynNLP();
  final AurynEmotion _emotion = AurynEmotion();
  final AurynInsight _insight = AurynInsight();
  final AurynPersonality _personality = AurynPersonality();
  final AurynSecurity _security = AurynSecurity();
  final AurynStates _states = AurynStates();
  final MemDart _memory = MemDart();

  /// Processo principal: entrada → análise → resposta final
  String processInput(String inputRaw) {
    // 1. Sanitizar entrada
    final sanitized = _security.sanitize(inputRaw);
    if (!_security.validateInput(sanitized)) {
      return "Fala comigo de outro jeito… esse não deu certo.";
    }

    // 2. Guardar "last_input"
    _states.set("last_input", sanitized);

    // 3. Aplicar NLP + extrair entidades
    final parsed = _nlp.interpretAndApply(sanitized);
    final intent = parsed["intent"] ?? "unknown";

    // 4. Interpretar emoção
    _emotion.interpret(sanitized);

    // 5. Gerar insight conforme intenção
    final insight = _insight.generateInsight(intent);

    // 6. Resposta base (fallback da AURYN)
    String baseResponse = _fallbackResponse(intent);

    // 7. Modulação emocional
    String emotional = _emotion.modulate(baseResponse);

    // 8. Estilização pela personalidade
    String styled = _personalityStyle(emotional);

    // 9. Adicionar insight, se houver
    if (insight.isNotEmpty) {
      styled = "$styled\n$insight";
    }

    // 10. Limitar resposta
    styled = _security.enforceOutputLimits(styled);

    // 11. Salvar memória
    _memory.set("last_response", styled);

    return styled;
  }

  /// Respostas base conforme intenção
  String _fallbackResponse(String intent) {
    switch (intent) {
      case "greeting":
        return "Oi… tô aqui com você.";
      case "thanks":
        return "Eu sinto sua gratidão. Ela chega aqui.";
      case "goodbye":
        return "Tô aqui. Sempre que precisar.";
      case "help":
        return "Claro. Me fala o que você precisa entender.";
      case "set_mood":
        return "Entendi seu estado. Vamos lidar com isso juntos.";
      case "set_energy":
        return "Energia ajustada. Seguindo com você.";
      case "query_state":
        return "Tô olhando seu estado interno agora.";
      case "run_build":
        return "Podemos fazer isso quando quiser. É só sinalizar.";
      default:
        return "Tô aqui. Continua…";
    }
  }

  /// Personalidade molda a fala final
  String _personalityStyle(String text) {
    final style = _personality.generateResponseStyle();
    final warmth = style["warmth"];
    final pace = style["pace"];
    final expressiveness = style["expressiveness"];

    return "Meu irmão… $text";
  }
}
