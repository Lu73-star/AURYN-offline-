/// lib/auryn_core/auryn_core.dart
/// Núcleo da IA AURYN Falante.
/// Responsável por inicializar módulos, gerenciar ciclo de vida,
/// manter estados internos e fornecer a função principal de resposta.
/// Integrado com sistema de eventos para comunicação entre módulos.

import 'dart:async';
import 'package:auryn_offline/auryn_core/states/auryn_states.dart';
import 'package:auryn_offline/auryn_core/emotion/auryn_emotion.dart';
import 'package:auryn_offline/auryn_core/personality/auryn_personality.dart';
import 'package:auryn_offline/auryn_core/processor/auryn_processor.dart';
import 'package:auryn_offline/auryn_core/runtime/auryn_runtime.dart';
import 'package:auryn_offline/auryn_core/runtime/runtime_manager.dart';
import 'package:auryn_offline/auryn_core/nlp/auryn_nlp.dart';
import 'package:auryn_offline/auryn_core/events/event_bus.dart';
import 'package:auryn_offline/auryn_core/events/auryn_event.dart';
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
  final RuntimeManager _runtimeManager = RuntimeManager();
  final AurynNLP _nlp = AurynNLP();
  final MemDart _memory = MemDart();
  final EventBus _eventBus = EventBus();

  bool _initialized = false;
  bool get isInitialized => _initialized;

  /// Subscriptions para eventos
  final List<StreamSubscription> _subscriptions = [];

  /// Inicialização do núcleo — chamada no main()
  Future<void> init() async {
    if (_initialized) return;

    // 1. Inicializar módulos base
    await _initializeModules();

    // 2. Configurar subscriptions de eventos
    _setupEventListeners();

    // 3. Inicializar estados padrão
    _states.initializeDefaults();

    // 4. Inicializar memória (persistência)
    await _memory.init();

    // 5. Carregar humor inicial da AURYN
    _states.set("mood", "calm");
    _states.set("energy", 80);

    // 6. Aplicar identidade base
    _personality.generateResponseStyle();

    // 7. Iniciar os runtime loops
    _runtime.start();
    _runtimeManager.start();

    // 8. Publicar evento de inicialização
    _eventBus.publish(AurynEvent(
      type: AurynEventType.stateChange,
      source: 'AURYNCore',
      data: {'action': 'initialized'},
      priority: 10,
    ));

    _initialized = true;
  }

  /// Inicializa todos os módulos
  Future<void> _initializeModules() async {
    await _emotion.init();
    await _nlp.init();
    await _processor.init();
    await _runtime.init();
    await _runtimeManager.init();
  }

  /// Configura listeners de eventos para comunicação entre módulos
  void _setupEventListeners() {
    // Listener para mudanças de humor
    final moodSub = _eventBus.subscribe(
      AurynEventType.moodChange,
      (event) {
        // Pode disparar ações adicionais quando o humor muda
        final newMood = event.data['new_mood'];
        // Lógica adicional aqui, se necessário
      },
    );
    _subscriptions.add(moodSub);

    // Listener para mudanças de energia
    final energySub = _eventBus.subscribe(
      AurynEventType.energyChange,
      (event) {
        final newEnergy = event.data['new_energy'];
        // Pode ajustar comportamento baseado na energia
      },
    );
    _subscriptions.add(energySub);

    // Listener para pulsos emocionais
    final pulseSub = _eventBus.subscribe(
      AurynEventType.emotionalPulse,
      (event) {
        // Pode ser usado para atualizar UI visual (AurynPulse)
      },
    );
    _subscriptions.add(pulseSub);

    // Listener para erros
    final errorSub = _eventBus.subscribe(
      AurynEventType.error,
      (event) {
        // Log de erros para análise
        _memory.save('error_log_${DateTime.now().millisecondsSinceEpoch}', event.toMap());
      },
    );
    _subscriptions.add(errorSub);
  }

  /// Entrada principal utilizada pela UI e pelo sistema de voz
  String respond(String text) {
    if (!_initialized) {
      return "AURYN ainda está despertando… tenta de novo em alguns segundos.";
    }

    return _processor.processInput(text);
  }

  /// Desliga o núcleo (raro de usar)
  Future<void> shutdown() async {
    if (!_initialized) return;

    // Publicar evento de shutdown
    _eventBus.publish(AurynEvent(
      type: AurynEventType.stateChange,
      source: 'AURYNCore',
      data: {'action': 'shutdown'},
      priority: 10,
    ));

    // Cancelar todas as subscriptions
    for (final sub in _subscriptions) {
      await sub.cancel();
    }
    _subscriptions.clear();

    // Parar runtimes
    _runtime.stop();
    _runtimeManager.stop();

    // Shutdown de módulos
    await _emotion.shutdown();
    await _nlp.shutdown();
    await _processor.shutdown();
    await _runtime.shutdown();
    await _runtimeManager.shutdown();

    // Fechar memória
    await _memory.close();

    // Fechar event bus
    await _eventBus.close();

    _initialized = false;
  }

  /// Retorna estatísticas do sistema
  Map<String, dynamic> getSystemStats() {
    return {
      'initialized': _initialized,
      'modules': {
        'emotion': _emotion.getStatus(),
        'nlp': _nlp.getStatus(),
        'processor': _processor.getStatus(),
        'runtime': _runtime.getStatus(),
        'runtime_manager': _runtimeManager.getStatus(),
      },
      'event_bus': _eventBus.getStats(),
      'states': _states.all,
    };
  }

  /// Retorna o event bus (para uso externo se necessário)
  EventBus get eventBus => _eventBus;
}
