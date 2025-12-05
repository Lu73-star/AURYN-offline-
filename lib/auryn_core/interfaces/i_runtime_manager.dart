/// lib/auryn_core/interfaces/i_runtime_manager.dart
/// Interface para gerenciadores de runtime.
/// Define o contrato para módulos que controlam o ciclo de vida interno.

import 'package:auryn_offline/auryn_core/interfaces/i_auryn_module.dart';

abstract class IRuntimeManager extends IAurynModule {
  /// Inicia o runtime loop
  void start();

  /// Para o runtime loop
  void stop();

  /// Verifica se o runtime está ativo
  bool get isRunning;

  /// Define o intervalo entre pulsos (em milissegundos)
  int get pulseIntervalMs;

  /// Registra um callback para executar a cada pulso
  void onPulse(Function callback);

  /// Remove um callback registrado
  void removePulseCallback(Function callback);
}
