/// AURYN Runtime Manager
/// Controla o ciclo de vida interno da IA (LWM Loop):
/// - Rotinas periódicas (pulsos internos)
/// - Atualização de humor e energia
/// - Execução de tarefas paralelas
/// - Comunicação com MemDart e AurynCore
/// - Event dispatcher integration

import 'dart:async';
import 'package:auryn_offline/auryn_core/interfaces/i_runtime_manager.dart';
import 'package:auryn_offline/auryn_core/events/event_bus.dart';
import 'package:auryn_offline/auryn_core/events/auryn_event.dart';
import 'package:auryn_offline/auryn_core/states/auryn_states.dart';
import 'package:auryn_offline/auryn_core/emotion/auryn_emotion.dart';

class RuntimeManager implements IRuntimeManager {
  static final RuntimeManager _instance = RuntimeManager._internal();
  factory RuntimeManager() => _instance;

  RuntimeManager._internal();

  /// Timer interno que simula "pulsos" da IA (LWM Loop)
  Timer? _pulseTimer;

  /// Intervalo entre pulsos internos (em ms)
  @override
  final int pulseIntervalMs = 5000; // 5 segundos

  /// Event bus para comunicação entre módulos
  final EventBus _eventBus = EventBus();

  /// Estados internos
  final AurynStates _states = AurynStates();

  /// Módulo emocional
  final AurynEmotion _emotion = AurynEmotion();

  /// Estado do módulo
  String _state = 'stopped';

  /// Callbacks registrados para executar a cada pulso
  final List<Function> _pulseCallbacks = [];

  /// Contador de pulsos
  int _pulseCount = 0;

  @override
  String get moduleName => 'RuntimeManager';

  @override
  String get version => '1.0.0';

  @override
  String get state => _state;

  @override
  bool get isReady => _state == 'running' || _state == 'initialized';

  @override
  bool get isRunning => _pulseTimer != null && _pulseTimer!.isActive;

  @override
  Future<void> init({Map<String, dynamic>? config}) async {
    if (_state == 'running' || _state == 'initialized') return;
    _state = 'initialized';
    _pulseCount = 0;
  }

  /// Inicia o runtime da IA (LWM Loop)
  @override
  void start() {
    if (isRunning) return;

    stop(); // evita duplicações

    _state = 'running';
    _pulseTimer = Timer.periodic(
      Duration(milliseconds: pulseIntervalMs),
      (timer) => _onPulse(),
    );

    // Publica evento de início
    _eventBus.publish(AurynEvent(
      type: AurynEventType.runtimePulse,
      source: moduleName,
      data: {'action': 'start', 'pulse_interval_ms': pulseIntervalMs},
    ));
  }

  /// Para o runtime
  @override
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
    _pulseCallbacks.clear();
    _state = 'shutdown';
  }

  /// Evento executado a cada pulso interno (LWM Loop cycle)
  void _onPulse() {
    _pulseCount++;

    // Recuperar estado atual
    final mood = _states.get("mood") ?? "neutral";
    final energy = _states.get("energy") ?? 70;

    // 1. Regeneração gradual de energia
    final newEnergy = (energy + 1).clamp(0, 100);
    if (newEnergy != energy) {
      _states.set("energy", newEnergy);
      _publishEnergyChange(energy, newEnergy);
    }

    // 2. Estabilização emocional gradual
    _stabilizeEmotionalState(mood);

    // 3. Executar callbacks registrados
    for (final callback in _pulseCallbacks) {
      try {
        callback();
      } catch (e) {
        // Log erro mas não quebra o loop
        _eventBus.publish(AurynEvent(
          type: AurynEventType.error,
          source: moduleName,
          data: {
            'error': 'Callback error in runtime loop',
            'details': e.toString(),
          },
          priority: 9,
        ));
      }
    }

    // 4. Publicar evento de pulso
    _eventBus.publish(AurynEvent(
      type: AurynEventType.runtimePulse,
      source: moduleName,
      data: {
        'pulse_count': _pulseCount,
        'mood': mood,
        'energy': newEnergy,
        'timestamp': DateTime.now().toIso8601String(),
      },
      priority: 3,
    ));

    // 5. Publicar pulso emocional se necessário
    if (_pulseCount % 3 == 0) {
      _publishEmotionalPulse();
    }
  }

  /// Estabiliza o estado emocional gradualmente
  void _stabilizeEmotionalState(String mood) {
    // Estados negativos tendem a se estabilizar com o tempo
    if (mood == "sad" || mood == "irritated" || mood == "low_energy") {
      // A cada 3 pulsos, tendência a voltar ao neutro
      if (_pulseCount % 3 == 0) {
        _states.set("mood", "calm");
        _publishMoodChange(mood, "calm");
      }
    }
  }

  /// Publica evento de mudança de humor
  void _publishMoodChange(String oldMood, String newMood) {
    _eventBus.publish(AurynEvent(
      type: AurynEventType.moodChange,
      source: moduleName,
      data: {
        'old_mood': oldMood,
        'new_mood': newMood,
        'pulse_count': _pulseCount,
      },
      priority: 7,
    ));
  }

  /// Publica evento de mudança de energia
  void _publishEnergyChange(int oldEnergy, int newEnergy) {
    _eventBus.publish(AurynEvent(
      type: AurynEventType.energyChange,
      source: moduleName,
      data: {
        'old_energy': oldEnergy,
        'new_energy': newEnergy,
        'delta': newEnergy - oldEnergy,
      },
      priority: 5,
    ));
  }

  /// Publica pulso emocional periódico
  void _publishEmotionalPulse() {
    final mood = _states.get("mood") ?? "neutral";
    final energy = _states.get("energy") ?? 70;

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

  /// Registra um callback para executar a cada pulso
  @override
  void onPulse(Function callback) {
    if (!_pulseCallbacks.contains(callback)) {
      _pulseCallbacks.add(callback);
    }
  }

  /// Remove um callback registrado
  @override
  void removePulseCallback(Function callback) {
    _pulseCallbacks.remove(callback);
  }

  /// Retorna estatísticas do runtime
  @override
  Map<String, dynamic> getStatus() {
    return {
      'state': _state,
      'is_running': isRunning,
      'pulse_count': _pulseCount,
      'pulse_interval_ms': pulseIntervalMs,
      'registered_callbacks': _pulseCallbacks.length,
      'current_mood': _states.get("mood"),
      'current_energy': _states.get("energy"),
    };
  }
}
