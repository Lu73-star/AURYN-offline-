/// lib/auryn_core/processor/auryn_processor.dart
/// O módulo mais importante: integra NLP + Emotion + Personality + Insight
/// + Security + States + MemDart para produzir a resposta final da AURYN.
/// Implementa pipeline de processamento com eventos e tracking de contexto.

import 'package:auryn_offline/auryn_core/interfaces/i_processor.dart';
import 'package:auryn_offline/auryn_core/nlp/auryn_nlp.dart';
import 'package:auryn_offline/auryn_core/emotion/auryn_emotion.dart';
import 'package:auryn_offline/auryn_core/emotion/insight/auryn_insight.dart';
import 'package:auryn_offline/auryn_core/personality/auryn_personality.dart';
import 'package:auryn_offline/auryn_core/security/auryn_security.dart';
import 'package:auryn_offline/auryn_core/states/auryn_states.dart';
import 'package:auryn_offline/auryn_core/events/event_bus.dart';
import 'package:auryn_offline/auryn_core/events/auryn_event.dart';
import 'package:auryn_offline/auryn_core/models/processing_context.dart';
import 'package:auryn_offline/memdart/memdart.dart';

class AurynProcessor implements IProcessor {
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
  final EventBus _eventBus = EventBus();

  /// Estado do módulo
  String _state = 'stopped';

  /// Contexto de processamento atual
  ProcessingContext? _currentContext;

  @override
  String get moduleName => 'AurynProcessor';

  @override
  String get version => '1.0.0';

  @override
  String get state => _state;

  @override
  bool get isReady => _state == 'running' || _state == 'initialized';

  @override
  Future<void> init({Map<String, dynamic>? config}) async {
    if (_state == 'running' || _state == 'initialized') return;
    _state = 'initialized';
  }

  @override
  Future<void> shutdown() async {
    _state = 'shutdown';
    _currentContext = null;
  }

  /// Valida se a entrada pode ser processada
  @override
  bool validateInput(String input) {
    final sanitized = _security.sanitize(input);
    return _security.validateInput(sanitized);
  }

  /// Retorna o contexto atual do processamento
  @override
  Map<String, dynamic> getCurrentContext() {
    if (_currentContext == null) {
      return {'status': 'no_active_context'};
    }
    return _currentContext!.toMap();
  }

  /// Processo principal: entrada → análise → resposta final (síncrono)
  @override
  String processInput(String inputRaw) {
    // Publica evento de início
    _eventBus.publish(AurynEvent(
      type: AurynEventType.inputReceived,
      source: moduleName,
      data: {'input_length': inputRaw.length},
      priority: 8,
    ));

    _eventBus.publish(AurynEvent(
      type: AurynEventType.processingStart,
      source: moduleName,
      data: {'timestamp': DateTime.now().toIso8601String()},
      priority: 7,
    ));

    // 1. Sanitizar entrada
    final sanitized = _security.sanitize(inputRaw);
    if (!_security.validateInput(sanitized)) {
      _publishProcessingEnd(false, 'validation_failed');
      return "Fala comigo de outro jeito… esse não deu certo.";
    }

    // Criar contexto de processamento
    _currentContext = ProcessingContext(
      rawInput: inputRaw,
      sanitizedInput: sanitized,
    );

    // 2. Guardar "last_input"
    _states.set("last_input", sanitized);

    // 3. Aplicar NLP + extrair entidades
    final parsed = _nlp.interpretAndApply(sanitized);
    final intent = parsed["intent"] ?? "unknown";
    _currentContext!.intent = intent;
    _currentContext!.entities = parsed["entities"] ?? {};

    // 4. Interpretar emoção
    _emotion.interpret(sanitized);
    _currentContext!.mood = _states.get("mood");
    _currentContext!.energy = _states.get("energy");

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
    _memory.save("last_response", styled);
    _currentContext!.response = styled;
    _currentContext!.markComplete();

    // Publicar evento de conclusão
    _publishProcessingEnd(true, 'success');

    _eventBus.publish(AurynEvent(
      type: AurynEventType.outputGenerated,
      source: moduleName,
      data: {
        'intent': intent,
        'output_length': styled.length,
        'mood': _currentContext!.mood,
      },
      priority: 8,
    ));

    return styled;
  }

  /// Processo assíncrono de entrada
  @override
  Future<String> processInputAsync(String input) async {
    // Para este módulo, o processamento é rápido o suficiente para ser síncrono
    // Mas a interface permite implementação assíncrona futura
    return processInput(input);
  }

  /// Publica evento de fim de processamento
  void _publishProcessingEnd(bool success, String reason) {
    _eventBus.publish(AurynEvent(
      type: AurynEventType.processingEnd,
      source: moduleName,
      data: {
        'success': success,
        'reason': reason,
        'timestamp': DateTime.now().toIso8601String(),
      },
      priority: 7,
    ));
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

  @override
  Map<String, dynamic> getStatus() {
    return {
      'state': _state,
      'is_ready': isReady,
      'has_active_context': _currentContext != null,
      'current_context': getCurrentContext(),
    };
  }
}
