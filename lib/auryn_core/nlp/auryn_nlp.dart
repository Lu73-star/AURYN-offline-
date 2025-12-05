/// lib/auryn_core/nlp/auryn_nlp.dart
/// Módulo de NLP para o AURYN — detecção de intenção e entidades.
/// Projetado como stub local, sem dependências externas, fácil de expandir.
/// Implementa pipeline de processamento NLP completo.

import 'package:auryn_offline/auryn_core/interfaces/i_nlp_engine.dart';
import 'package:auryn_offline/auryn_core/states/auryn_states.dart';
import 'package:auryn_offline/auryn_core/events/event_bus.dart';
import 'package:auryn_offline/auryn_core/events/auryn_event.dart';

class AurynNLP implements INLPEngine {
  static final AurynNLP _instance = AurynNLP._internal();
  factory AurynNLP() => _instance;
  AurynNLP._internal();

  final AurynStates _states = AurynStates();
  final EventBus _eventBus = EventBus();

  /// Estado do módulo
  String _state = 'stopped';

  /// Contexto de conversação (últimas N interações)
  final List<String> _conversationContext = [];
  final int _maxContextSize = 5;

  @override
  String get moduleName => 'AurynNLP';

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
    _conversationContext.clear();
  }

  @override
  Future<void> shutdown() async {
    _state = 'shutdown';
    _conversationContext.clear();
  }

  /// Detecta a intenção principal do texto
  @override
  String detectIntent(String text) {
    final lower = text.toLowerCase().trim();

    if (_isGreeting(lower)) return 'greeting';
    if (_isGoodbye(lower)) return 'goodbye';
    if (_isThanks(lower)) return 'thanks';
    if (_isHelp(lower)) return 'help';
    if (_isQueryState(lower)) return 'query_state';
    if (lower.contains('mood') || lower.contains('humor')) return 'set_mood';
    if (lower.contains('energia')) return 'set_energy';
    if (lower.contains('rodar teste') || lower.contains('run') || lower.contains('build')) {
      return 'run_build';
    }

    return 'unknown';
  }

  /// Extrai entidades do texto
  @override
  Map<String, dynamic> extractEntities(String text) {
    final lower = text.toLowerCase();
    final Map<String, dynamic> entities = {};

    // extrair possível humor solicitado
    final moodMatch = RegExp(
      r'\b(triste|feliz|alegre|irritad|nervos|calm|neutro)\b',
      caseSensitive: false,
    );
    final m = moodMatch.firstMatch(lower);
    if (m != null) entities['mood'] = _normalizeMood(m.group(0)!);

    // extrair números simples (ex.: "energia 50", "energia 20%")
    final energyMatch = RegExp(r'energia\s*[:=]?\s*(\d{1,3})');
    final e = energyMatch.firstMatch(lower);
    if (e != null) {
      final val = int.tryParse(e.group(1)!) ?? 0;
      entities['energy'] = val.clamp(0, 100);
    }

    // extrair consulta de estado específico
    final stateKeyMatch = RegExp(
      r'qual(?: é| e| )?\s+o\s+(?:meu|estado|valor)\s+de\s+([a-zA-Z_]+)',
      caseSensitive: false,
    );
    final sk = stateKeyMatch.firstMatch(lower);
    if (sk != null) {
      entities['query_key'] = sk.group(1);
    }

    return entities;
  }

  /// Resultado padronizado do parser
  /// { "intent": "greeting", "entities": {...}, "text": "raw input" }
  @override
  Map<String, dynamic> parse(String text) {
    final raw = text.trim();
    final lower = raw.toLowerCase();

    // entidades simples
    final Map<String, dynamic> entities = {};

    // extrair possível humor solicitado: "estou triste", "me sinto feliz", "modo alegre"
    final moodMatch = RegExp(r'\b(triste|feliz|alegre|irritad|nervos|calm|neutro)\b', caseSensitive: false);
    final m = moodMatch.firstMatch(lower);
    if (m != null) entities['mood'] = _normalizeMood(m.group(0)!);

    // extrair números simples (ex.: "energia 50", "energia 20%")
    final energyMatch = RegExp(r'energia\s*[:=]?\s*(\d{1,3})');
    final e = energyMatch.firstMatch(lower);
    if (e != null) {
      final val = int.tryParse(e.group(1)!) ?? 0;
      entities['energy'] = val.clamp(0, 100);
    }

    // intenções por padrão (ordem importa)
    String intent = 'unknown';

    if (_isGreeting(lower)) intent = 'greeting';
    else if (_isGoodbye(lower)) intent = 'goodbye';
    else if (_isThanks(lower)) intent = 'thanks';
    else if (_isHelp(lower)) intent = 'help';
    else if (_isQueryState(lower)) intent = 'query_state';
    else if (lower.contains('mood') || lower.contains('humor') || entities.containsKey('mood')) intent = 'set_mood';
    else if (lower.contains('energia') || entities.containsKey('energy')) intent = 'set_energy';
    else if (lower.contains('rodar teste') || lower.contains('run') || lower.contains('build')) intent = 'run_build';

    // small post-process: if user asked about a specific key
    final stateKeyMatch = RegExp(r'qual(?: é| e| )?\s+o\s+(?:meu|estado|valor)\s+de\s+([a-zA-Z_]+)', caseSensitive: false);
    final sk = stateKeyMatch.firstMatch(lower);
    if (sk != null) {
      intent = 'query_state';
      entities['query_key'] = sk.group(1);
    }

    return {
      'intent': intent,
      'entities': entities,
      'text': raw,
    };
  }

  /// Aplicação direta: interpreta e aplica mudanças simples nos estados quando aplicável.
  @override
  Map<String, dynamic> interpretAndApply(String input) {
    // Adiciona ao contexto de conversação
    _addToContext(input);
    final result = parse(input);
    final intent = result['intent'] as String;
    final entities = result['entities'] as Map<String, dynamic>;

    if (intent == 'set_mood' && entities.containsKey('mood')) {
      _states.set('mood', entities['mood']);
    }

    if (intent == 'set_energy' && entities.containsKey('energy')) {
      _states.set('energy', entities['energy']);
    }

    // guarda último input
    _states.set('last_input', input);

    return result;
  }

  // ---------- helpers ----------

  String _normalizeMood(String raw) {
    final s = raw.toLowerCase();
    if (s.contains('triste') || s.contains('nervos')) return 'sad';
    if (s.contains('feliz') || s.contains('alegre')) return 'happy';
    if (s.contains('irritad')) return 'irritated';
    if (s.contains('calm')) return 'calm';
    return 'neutral';
  }

  bool _isGreeting(String s) {
    return RegExp(r'\b(oi|ol[áa]|olá|bom dia|boa tarde|boa noite|eai|e aí|fala)\b').hasMatch(s);
  }

  bool _isGoodbye(String s) {
    return RegExp(r'\b(tchau|até|adeus|falou|até mais|até logo)\b').hasMatch(s);
  }

  bool _isThanks(String s) {
    return RegExp(r'\b(obrigad[oa]|valeu|brigad[oa])\b').hasMatch(s);
  }

  bool _isHelp(String s) {
    return RegExp(r'\b(ajuda|socorro|como fazer|o que fazer|help)\b').hasMatch(s);
  }

  bool _isQueryState(String s) {
    return RegExp(r'\b(qual .* estado|como estou|mostre meu estado|mostra estado|que estado|status)\b').hasMatch(s);
  }

  /// Adiciona entrada ao contexto de conversação
  void _addToContext(String input) {
    _conversationContext.add(input);
    if (_conversationContext.length > _maxContextSize) {
      _conversationContext.removeAt(0);
    }
  }

  /// Retorna o contexto de conversação atual
  List<String> getConversationContext() {
    return List.unmodifiable(_conversationContext);
  }

  @override
  Map<String, dynamic> getStatus() {
    return {
      'state': _state,
      'is_ready': isReady,
      'context_size': _conversationContext.length,
      'max_context_size': _maxContextSize,
    };
  }
}
