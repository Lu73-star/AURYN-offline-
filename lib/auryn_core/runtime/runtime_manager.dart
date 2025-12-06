/// AURYN Runtime Manager
/// Controla o ciclo de vida interno da IA:
/// - Rotinas periódicas
/// - Atualização de humor
/// - Execução de tarefas paralelas
/// - Comunicação com MemDart e AurynCore

import 'package:auryn_offline/auryn_core/auryn_core.dart';

class RuntimeManager {
  static final RuntimeManager _instance = RuntimeManager._internal();
  factory /// AURYN Runtime Manager
/// Controla o ciclo de vida interno da IA de forma determinística.
/// NÃO depende de Timer nem de relógio real.
///
/// Responsabilidades:
/// - Orquestrar o avanço do runtime por ticks explícitos
/// - Integrar o runtime com o AURYNCore
/// - Permitir testes totalmente determinísticos

import 'package:auryn_offline/auryn_core/auryn_core.dart';

class RuntimeManager {
  static final RuntimeManager _instance = RuntimeManager._internal();
  factory RuntimeManager() => _instance;
  RuntimeManager._internal();

  bool _running = false;
  int _currentTick = 0;

  /// Inicia o runtime (sem Timer)
  void start() {
    _running = true;
  }

  /// Para o runtime
  void stop() {
    _running = false;
  }

  /// Executa um único tick determinístico
  void tick() {
    if (!_running) return;

    _currentTick++;
    _onTick(_currentTick);
  }

  /// Avança múltiplos ticks de forma explícita (ideal para testes)
  void advanceTicks(int count) {
    if (count <= 0) return;

    for (int i = 0; i < count; i++) {
      tick();
    }
  }

  /// Lógica executada a cada tick
  void _onTick(int tick) {
    final core = AURYNCore();

    // Exemplo simples de evolução de estado
    if (core.mood == "neutral") {
      core.setMood("stable");
    }

    // 🔮 Futuro:
    // - Integração com AurynRuntime (estado puro)
    // - Integração com AurynPulse
    // - Integração com fila de eventos
  }

  /// Tick atual do runtime
  int get currentTick => _currentTick;

  /// Indica se o runtime está ativo
  bool get isRunning => _running;
}
