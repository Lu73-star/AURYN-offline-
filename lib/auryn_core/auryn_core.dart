/// lib/auryn_core/auryn_core.dart
/// Núcleo da IA AURYN Falante.
/// Responsável por inicializar módulos, gerenciar ciclo de vida,
/// manter estados internos e fornecer a função principal de resposta.

import 'package:auryn_offline/auryn_core/states/auryn_states.dart';
import 'package:auryn_offline/auryn_core/emotion/auryn_emotion.dart';
import 'package:auryn_offline/auryn_core/personality/auryn_personality.dart';
import 'package:auryn_offline/auryn_core/processor/auryn_processor.dart';
import 'package:auryn_offline/auryn_core/runtime/auryn_runtime.dart';
import 'package:auryn_offline/memdart/memdart.dart';

class AURYNCore {
  static final AURYNCore _instance = AURYNCore._internal();
  factory AURYNCore() => _instance;
  AURYNCore._internal();

  final AurynStates _states = AurynStates();
  final AurynEmotion _emotion = AurynEmotion();
  final AurynPersonality _personality = AurynPersonality();
  final AurynProcessor _processor = AurynProcessor();
  final AurynRuntime _runtime = AurynRuntime();
  final MemDart _memory = MemDart();

  bool _initialized = false;
  bool get isInitialized => _initialized;

  /// Inicialização do núcleo — chamada no main()
  Future<void> init() async {
    if (_initialized) return;

    // 1. Inicializar estados padrão
    _states.initializeDefaults();

    // 2. Inicializar memória (persistência)
    await _memory.init();

    // 3. Carregar humor inicial da AURYN
    _states.set("mood", "calm");
    _states.set("energy", 80);

    // 4. Aplicar identidade base
    _personality.generateResponseStyle();

    // 5. Iniciar o runtime pulsante
    _runtime.start();

    _initialized = true;
  }

  /// Entrada principal utilizada pela UI e pelo sistema de voz
  String respond(String text) {
    if (!_initialized) {
      return "AURYN ainda está despertando… tenta de novo em alguns segundos.";
    }

    return _processor.processInput(text);
  }

  /// Desliga o núcleo (raro de usar)
  void shutdown() {
    _runtime.stop();
    _initialized = false;
  }
}
