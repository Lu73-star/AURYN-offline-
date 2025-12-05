/// lib/auryn_core/interfaces/i_processor.dart
/// Interface para processadores de entrada da AURYN.
/// Define o contrato para módulos que processam input do usuário.

import 'package:auryn_offline/auryn_core/interfaces/i_auryn_module.dart';

abstract class IProcessor extends IAurynModule {
  /// Processa entrada do usuário e retorna resposta
  String processInput(String input);

  /// Processa entrada de forma assíncrona
  Future<String> processInputAsync(String input);

  /// Valida se a entrada pode ser processada
  bool validateInput(String input);

  /// Retorna o contexto atual do processamento
  Map<String, dynamic> getCurrentContext();
}
