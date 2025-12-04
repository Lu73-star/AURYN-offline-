/// lib/auryn_core/runtime/auryn_runtime.dart
/// O runtime é o coração pulsante da AURYN.
/// Ele mantém ciclos, energia, pequenos ajustes emocionais
/// e prepara terreno para o módulo AurynPulse visual.

import 'dart:async';
import 'package:auryn_offline/auryn_core/states/auryn_states.dart';
import 'package:auryn_offline/auryn_core/emotion/auryn_emotion.dart';

class AurynRuntime {
  static final AurynRuntime _instance = AurynRuntime._internal();
  factory AurynRuntime() => _instance;
  AurynRuntime._internal();

  Timer? _pulseTimer;
  final AurynStates _states = AurynStates();
  final AurynEmotion _emotion = AurynEmotion();

  /// Intervalo entre pulsos internos (em milissegundos)
  final int pulseIntervalMs = 5000;

  /// Inicia o ciclo vital da IA
  void start() {
    stop(); // garante que não existem timers duplicados

    _pulseTimer = Timer.periodic(
      Duration(milliseconds: pulseIntervalMs),
      (timer) => _pulse(),
    );
  }

  /// Para o runtime
  void stop() {
    _pulseTimer?.cancel();
    _pulseTimer = null;
  }

  bool get isRunning => _pulseTimer != null;

  /// A cada pulso, pequenos ajustes são feitos
  void _pulse() {
    // Recuperar energia e humor
    String mood = _states.get("mood") ?? "neutral";
    int energy = _states.get("energy") ?? 70;

    // Regeneração leve de energia
    energy = (energy + 1).clamp(0, 100);
    _states.set("energy", energy);

    // Pequena suavização emocional ao longo do tempo
    if (mood == "sad" || mood == "irritated") {
      _states.set("mood", "calm");
    }

    // No futuro: alimentar o AurynPulse visual
  }
}
