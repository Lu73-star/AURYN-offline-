/// lib/auryn_core/runtime/auryn_runtime.dart
/// O runtime é o coração pulsante da AURYN.
/// Ele mantém ciclos, energia, pequenos ajustes emocionais
/// e prepara terreno para o módulo AurynPulse visual.
/// Integrado com o sistema de eventos para comunicação entre módulos.

import 'dart:async';
import 'package:auryn_offline/auryn_core/interfaces/i_auryn_module.dart';
import 'package:auryn_offline/auryn_core/states/auryn_states.dart';
import 'package:auryn_offline/auryn_core/emotion/auryn_emotion.dart';
import 'package:auryn_offline/auryn_core/events/event_bus.dart';
import 'package:auryn_offline/auryn_core/events/auryn_event.dart';

class AurynRuntime implements IAurynModule {
  static final AurynRuntime _instance = AurynRuntime._internal();
  factory AurynRuntime() => _instance;
  AurynRuntime._internal();

  Timer? _pulseTimer;
  final AurynStates _states = AurynStates();
  final AurynEmotion _emotion = AurynEmotion();
  final EventBus _eventBus = EventBus();

  /// Estado do módulo
  String _state = 'stopped';

  /// Contador de pulsos
  int _pulseCount = 0;

  /// Intervalo entre pulsos internos (em milissegundos)
  final int pulseIntervalMs = 5000;

  @override
  String get moduleName => 'AurynRuntime';

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
    _pulseCount = 0;
  }

  /// Inicia o ciclo vital da IA
  void start() {
    if (isRunning) return;
    stop(); // garante que não existem timers duplicados

    _state = 'running';
    _pulseTimer = Timer.periodic(
      Duration(milliseconds: pulseIntervalMs),
      (timer) => _pulse(),
    );

    // Publica evento de início
    _eventBus.publish(AurynEvent(
      type: AurynEventType.runtimePulse,
      source: moduleName,
      data: {'action': 'start'},
    ));
  }

  /// Para o runtime
  void stop() {
    _pulseTimer?.cancel();
    _pulseTimer = null;
    _state = 'stopped';

    // Publica evento de parada
    _eventBus.publish(AurynEvent(
      type: AurynEventType.runtimePulse,
      source: moduleName,
      data: {'action': 'stop', 'total_pulses': _pulseCount},
    ));
  }

  @override
  Future<void> shutdown() async {
    stop();
    _state = 'shutdown';
  }

  bool get isRunning => _pulseTimer != null && _pulseTimer!.isActive;

  /// A cada pulso, pequenos ajustes são feitos
  void _pulse() {
    _pulseCount++;

    // Recuperar energia e humor
    String mood = _states.get("mood") ?? "neutral";
    int energy = _states.get("energy") ?? 70;
    int oldEnergy = energy;

    // Regeneração leve de energia
    energy = (energy + 1).clamp(0, 100);
    _states.set("energy", energy);

    // Publicar mudança de energia se houver
    if (energy != oldEnergy) {
      _eventBus.publish(AurynEvent(
        type: AurynEventType.energyChange,
        source: moduleName,
        data: {
          'old_energy': oldEnergy,
          'new_energy': energy,
        },
      ));
    }

    // Pequena suavização emocional ao longo do tempo
    String oldMood = mood;
    if (mood == "sad" || mood == "irritated") {
      _states.set("mood", "calm");
      mood = "calm";

      // Publicar mudança de humor
      _eventBus.publish(AurynEvent(
        type: AurynEventType.moodChange,
        source: moduleName,
        data: {
          'old_mood': oldMood,
          'new_mood': mood,
          'reason': 'automatic_stabilization',
        },
        priority: 7,
      ));
    }

    // Publicar pulso emocional a cada 2 pulsos
    if (_pulseCount % 2 == 0) {
      _eventBus.publish(AurynEvent(
        type: AurynEventType.emotionalPulse,
        source: moduleName,
        data: {
          'mood': mood,
          'energy': energy,
          'intensity': _emotion.intensity,
          'pulse_count': _pulseCount,
        },
        priority: 6,
      ));
    }

    // No futuro: alimentar o AurynPulse visual
  }

  @override
  Map<String, dynamic> getStatus() {
    return {
      'state': _state,
      'is_running': isRunning,
      'pulse_count': _pulseCount,
      'pulse_interval_ms': pulseIntervalMs,
      'current_mood': _states.get("mood"),
      'current_energy': _states.get("energy"),
    };
  }
}
