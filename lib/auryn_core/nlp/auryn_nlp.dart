/// lib/auryn_core/nlp/auryn_nlp.dart
/// Módulo simples de NLP para o AURYN — detecção de intenção e entidades básicas.
/// Projetado como stub local, sem dependências externas, fácil de expandir.

import 'package:auryn_offline/auryn_core/states/auryn_states.dart';

class AurynNLP {
  static final AurynNLP _instance = AurynNLP._internal();
  factory AurynNLP() => _instance;
  AurynNLP._internal();

  final AurynStates _states = AurynStates();

  /// Resultado padronizado do parser
  /// { "intent": "greeting", "entities": {...}, "text": "raw input" }
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

  // Aplicação direta: interpreta e aplica mudanças simples nos estados quando aplicável.
  Map<String, dynamic> interpretAndApply(String input) {
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
}
