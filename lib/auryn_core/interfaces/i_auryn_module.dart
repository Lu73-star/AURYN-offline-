/// lib/auryn_core/interfaces/i_auryn_module.dart
/// Interface base para todos os módulos do AURYN Core.
/// Define o contrato básico que todos os módulos devem seguir.

abstract class IAurynModule {
  /// Nome identificador do módulo
  String get moduleName;

  /// Versão do módulo
  String get version;

  /// Estado atual do módulo (initialized, running, stopped, error)
  String get state;

  /// Inicializa o módulo com configurações opcionais
  Future<void> init({Map<String, dynamic>? config});

  /// Para o módulo e libera recursos
  Future<void> shutdown();

  /// Verifica se o módulo está pronto para operação
  bool get isReady;

  /// Retorna estatísticas/status do módulo
  Map<String, dynamic> getStatus();
}
