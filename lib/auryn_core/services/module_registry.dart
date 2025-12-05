/// lib/auryn_core/services/module_registry.dart
/// Registro centralizado de todos os módulos do sistema.
/// Permite gerenciamento uniforme de inicialização e shutdown.

import 'package:auryn_offline/auryn_core/interfaces/i_auryn_module.dart';

class ModuleRegistry {
  static final ModuleRegistry _instance = ModuleRegistry._internal();
  factory ModuleRegistry() => _instance;
  ModuleRegistry._internal();

  /// Mapa de módulos registrados
  final Map<String, IAurynModule> _modules = {};

  /// Ordem de inicialização dos módulos
  final List<String> _initOrder = [];

  /// Registra um módulo
  void register(IAurynModule module) {
    _modules[module.moduleName] = module;
    if (!_initOrder.contains(module.moduleName)) {
      _initOrder.add(module.moduleName);
    }
  }

  /// Remove um módulo do registro
  void unregister(String moduleName) {
    _modules.remove(moduleName);
    _initOrder.remove(moduleName);
  }

  /// Retorna um módulo pelo nome
  IAurynModule? getModule(String moduleName) {
    return _modules[moduleName];
  }

  /// Retorna todos os módulos
  Map<String, IAurynModule> getAllModules() {
    return Map.unmodifiable(_modules);
  }

  /// Inicializa todos os módulos na ordem registrada
  Future<void> initializeAll({Map<String, dynamic>? config}) async {
    for (final moduleName in _initOrder) {
      final module = _modules[moduleName];
      if (module != null) {
        await module.init(config: config);
      }
    }
  }

  /// Faz shutdown de todos os módulos na ordem reversa
  Future<void> shutdownAll() async {
    final reverseOrder = _initOrder.reversed.toList();
    for (final moduleName in reverseOrder) {
      final module = _modules[moduleName];
      if (module != null) {
        await module.shutdown();
      }
    }
  }

  /// Retorna status de todos os módulos
  Map<String, Map<String, dynamic>> getModulesStatus() {
    final status = <String, Map<String, dynamic>>{};
    for (final entry in _modules.entries) {
      status[entry.key] = entry.value.getStatus();
    }
    return status;
  }

  /// Verifica se todos os módulos estão prontos
  bool areAllModulesReady() {
    return _modules.values.every((module) => module.isReady);
  }

  /// Lista módulos por estado
  Map<String, List<String>> getModulesByState() {
    final byState = <String, List<String>>{};
    for (final entry in _modules.entries) {
      final state = entry.value.state;
      byState.putIfAbsent(state, () => []);
      byState[state]!.add(entry.key);
    }
    return byState;
  }

  /// Limpa o registro
  void clear() {
    _modules.clear();
    _initOrder.clear();
  }

  /// Retorna estatísticas do registro
  Map<String, dynamic> getStats() {
    return {
      'total_modules': _modules.length,
      'modules_by_state': getModulesByState(),
      'all_ready': areAllModulesReady(),
      'init_order': _initOrder,
    };
  }
}
