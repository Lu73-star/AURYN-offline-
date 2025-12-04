/// AURYNCore — Módulo Principal da IA Offline
/// Responsável por:
/// - Pipeline central
/// - Carregamento de memória
/// - Processamento emocional
/// - Raciocínio simbólico
/// - Gateway para módulos de Voz e MemDart

import 'package:auryn_offline/memdart/memdart.dart';

class AURYNCore {
  static final AURYNCore _instance = AURYNCore._internal();
  factory AURYNCore() => _instance;

  // Módulos internos
  late final MemDart mem;
  final Map<String, dynamic> _state = {};
  String _mood = "neutral";

  AURYNCore._internal() {
    mem = MemDart();
  }

  /// Inicializa a IA e carrega estados persistentes
  Future<void> init() async {
    await mem.init();
    _mood = mem.get("auryn_mood", defaultValue: "neutral");
  }

  /// Define o estado emocional atual
  void setMood(String mood) {
    _mood = mood;
    mem.set("auryn_mood", mood);
  }

  /// Retorna o humor atual
  String get mood => _mood;

  /// Atualiza variáveis internas acessíveis pelos módulos
  void setState(String key, dynamic value) {
    _state[key] = value;
    mem.set("state_$key", value);
  }

  /// Recupera variáveis internas
  dynamic getState(String key, {dynamic defaultValue}) {
    return _state[key] ?? mem.get("state_$key", defaultValue: defaultValue);
  }

  /// Núcleo de raciocínio local — funciona offline
  /// Responde perguntas com base em:
  /// - memória
  /// - estado emocional
  /// - padrões salvos
  String think(String input) {
    final memoryHint = mem.search(input);
    return _composeResponse(input, memoryHint);
  }

  /// Monta a resposta final conforme o humor
  String _composeResponse(String input, String? memoryHint) {
    final tone = {
      "neutral": "",
      "calm": "com suavidade",
      "focused": "de forma objetiva",
      "warm": "com acolhimento",
    }[_mood];

    if (memoryHint != null && memoryHint.isNotEmpty) {
      return "Respondendo $tone: $memoryHint";
    }

    return "Eu estou aqui, $tone. Você disse: $input";
  }
}
