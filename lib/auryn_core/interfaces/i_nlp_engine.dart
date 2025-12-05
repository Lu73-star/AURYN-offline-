/// lib/auryn_core/interfaces/i_nlp_engine.dart
/// Interface para engines de NLP.
/// Define o contrato para módulos de processamento de linguagem natural.

import 'package:auryn_offline/auryn_core/interfaces/i_auryn_module.dart';

abstract class INLPEngine extends IAurynModule {
  /// Faz parse de texto e retorna intenção + entidades
  Map<String, dynamic> parse(String text);

  /// Interpreta e aplica mudanças baseadas no input
  Map<String, dynamic> interpretAndApply(String input);

  /// Extrai entidades do texto
  Map<String, dynamic> extractEntities(String text);

  /// Detecta a intenção principal do texto
  String detectIntent(String text);
}
